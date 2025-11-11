# Security Review Report - Proposals Application

**Review Date:** 2025-11-11
**Application:** BIRS Proposals Management System
**Framework:** Ruby on Rails 6.1.7.3
**Review Scope:** Full application security audit

---

## Executive Summary

This security review identified **10 security vulnerabilities** ranging from Critical to Low severity. The most critical issue is a Remote Code Execution vulnerability in the authorization system. Additionally, the application is running on an outdated version of Rails with known CVEs that should be addressed immediately.

### Risk Overview
- **Critical:** 1 vulnerability
- **High:** 4 vulnerabilities
- **Medium:** 3 vulnerabilities
- **Low:** 2 vulnerabilities

---

## Critical Vulnerabilities

### 1. Remote Code Execution via `constantize` (CRITICAL)

**Location:** `app/models/ability.rb:23`

**Description:**
The authorization system uses `constantize` on user-controlled data without proper validation, potentially allowing arbitrary code execution.

```ruby
def check_privilege(privilege)
  case privilege.permission_type
  when 'Manage'
    can :manage, privilege.privilege_name.constantize  # VULNERABLE
  when 'Read'
    can :read, privilege.privilege_name.constantize    # VULNERABLE
  when 'Write'
    can :write, privilege.privilege_name.constantize   # VULNERABLE
  end
end
```

**Attack Vector:**
An attacker with access to the roles management interface (`app/controllers/roles_controller.rb:63`) can set `privilege_name` to arbitrary class names, potentially executing code when the ability is initialized.

**Impact:**
- Remote code execution
- Complete system compromise
- Data breach
- Privilege escalation

**Recommendation:**
1. Create a whitelist of allowed privilege names:
   ```ruby
   ALLOWED_PRIVILEGES = %w[
     Proposal ProposalType Location Schedule User Role
   ].freeze

   def check_privilege(privilege)
     return unless ALLOWED_PRIVILEGES.include?(privilege.privilege_name)
     # ... rest of code
   end
   ```
2. Add validation to `RolePrivilege` model:
   ```ruby
   validates :privilege_name, inclusion: {
     in: ALLOWED_PRIVILEGES,
     message: "%{value} is not a valid privilege"
   }
   ```

---

## High Vulnerabilities

### 2. Outdated Rails Version with Known CVEs (HIGH)

**Location:** `Gemfile.lock:234`

**Description:**
Application runs Rails 6.1.7.3, which has multiple known security vulnerabilities from 2024:

- **CVE-2024-26143:** XSS vulnerability in Action Controller
- **CVE-2024-26142:** ReDoS vulnerability in Accept header parsing
- **CVE-2024-28103:** Sensitive session information leak in Active Storage
- **Multiple ReDoS vulnerabilities:** In HTTP Token authentication, Action Mailer block_format helper, Action Text plain_text_for_blockquote_node helper, and query parameter filtering

**Impact:**
- Cross-site scripting attacks
- Denial of service via regex attacks
- Session hijacking
- Information disclosure

**Recommendation:**
Upgrade to Rails 6.1.7.9 or later immediately:
```ruby
gem 'rails', '~> 6.1.7', '>= 6.1.7.9'
```

### 3. Weak Password Hashing Algorithm (HIGH)

**Location:** `config/initializers/devise.rb:242`

**Description:**
The application uses SHA-512 for password hashing instead of bcrypt:

```ruby
config.encryptor = :sha512
```

**Impact:**
SHA-512 without proper key stretching is significantly weaker than bcrypt and more vulnerable to brute-force attacks. Modern GPUs can compute billions of SHA-512 hashes per second.

**Recommendation:**
1. Switch to bcrypt (Devise default):
   ```ruby
   # Remove or comment out:
   # config.encryptor = :sha512
   ```
2. Implement a password migration strategy for existing users
3. Force password resets for high-privilege accounts

### 4. SSL/TLS Not Enforced in Production (HIGH)

**Location:** `config/environments/production.rb:54`

**Description:**
SSL enforcement is disabled in production:

```ruby
# config.force_ssl = true
```

**Impact:**
- Man-in-the-middle attacks
- Session hijacking
- Credential theft
- No HTTP Strict Transport Security (HSTS)

**Recommendation:**
Enable SSL enforcement:
```ruby
config.force_ssl = true
```

### 5. CSRF Protection Disabled for API Endpoint (HIGH)

**Location:** `app/controllers/schedules_controller.rb:4`

**Description:**
The schedules create action disables CSRF protection:

```ruby
skip_before_action :verify_authenticity_token, only: %i[create]
```

While API key authentication is used, the implementation has weaknesses:
- No rate limiting
- API key passed in request body instead of header
- No request origin validation

**Impact:**
- Cross-site request forgery attacks
- Unauthorized schedule manipulation
- API abuse

**Recommendation:**
1. Implement proper API authentication using headers:
   ```ruby
   def authenticate_api_key
     api_key = request.headers['X-API-Key']
     # ... validation logic
   end
   ```
2. Add rate limiting using rack-attack gem
3. Implement request origin validation
4. Consider using JWT tokens for API authentication

---

## Medium Vulnerabilities

### 6. Content Security Policy Disabled (MEDIUM)

**Location:** `config/initializers/content_security_policy.rb`

**Description:**
Content Security Policy (CSP) is completely disabled, reducing defense against XSS attacks.

**Impact:**
- Reduced protection against XSS
- No mitigation for clickjacking
- Increased attack surface for code injection

**Recommendation:**
Enable CSP with appropriate directives:
```ruby
Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data
  policy.object_src  :none
  policy.script_src  :self, :https
  policy.style_src   :self, :https, :unsafe_inline
  policy.connect_src :self, :https
end

Rails.application.config.content_security_policy_nonce_generator =
  -> request { SecureRandom.base64(16) }
```

### 7. No Rate Limiting (MEDIUM)

**Location:** Application-wide

**Description:**
The application lacks rate limiting on authentication endpoints and API endpoints, making it vulnerable to brute-force and DoS attacks.

**Impact:**
- Brute-force password attacks
- Account enumeration
- Denial of service
- Resource exhaustion

**Recommendation:**
Implement rack-attack gem for rate limiting:
```ruby
# Gemfile
gem 'rack-attack'

# config/initializers/rack_attack.rb
Rack::Attack.throttle('logins/email', limit: 5, period: 60) do |req|
  if req.path == '/users/sign_in' && req.post?
    req.params['user']['email']
  end
end

Rack::Attack.throttle('api/schedules', limit: 10, period: 60) do |req|
  if req.path == '/schedules' && req.post?
    req.ip
  end
end
```

### 8. Potential XSS via `html_safe` Usage (MEDIUM)

**Location:** Multiple locations

**Description:**
Several instances of `html_safe` usage with potentially user-controlled data:

1. `app/helpers/email_templates_helper.rb:56` - Uses `html_safe` on concatenated strings
2. `app/helpers/proposal_types_helper.rb:10` - Joins location names with HTML
3. `app/javascript/controllers/proposal_form_controller.js:83,92` - Sets innerHTML with fetched data

**Impact:**
- Cross-site scripting attacks
- Session hijacking
- Credential theft

**Recommendation:**
1. For email_templates_helper.rb:56, use `content_tag` or `sanitize`:
   ```ruby
   def show_context
     InviteMailerContext.placeholders.map do |k, v|
       wrapped_key = "{{ #{k} }}"
       entry = v.present? ? "#{wrapped_key} - #{v}" : wrapped_key
       content_tag(:span, entry, class: 'fw-bold') + tag.br
     end.join.html_safe
   end
   ```
2. For JavaScript innerHTML, ensure server responses are properly sanitized
3. Consider using Turbo Frames for dynamic content updates

---

## Low Vulnerabilities

### 9. Missing File Upload Validation (LOW)

**Location:** `app/models/answer.rb`, `app/models/email.rb`, `app/models/proposal.rb`

**Description:**
While file type validation exists for some models (PDF validation in `proposal.rb:229` and `review.rb:14`), there's no validation for:
- File size limits
- Filename sanitization
- Virus scanning
- Storage quota enforcement

**Impact:**
- Storage exhaustion
- Malicious file uploads
- Path traversal attacks

**Recommendation:**
1. Add comprehensive file validations:
   ```ruby
   validates :file, content_type: ['application/pdf'],
                    size: { less_than: 10.megabytes },
                    attached: true
   ```
2. Sanitize filenames before storage
3. Implement virus scanning for uploaded files
4. Set per-user storage quotas

### 10. Insufficient Security Headers (LOW)

**Location:** Production configuration

**Description:**
Missing security headers:
- X-Frame-Options
- X-Content-Type-Options
- Referrer-Policy
- Permissions-Policy

**Impact:**
- Clickjacking attacks
- MIME-sniffing attacks
- Privacy leaks

**Recommendation:**
Add security headers in production configuration:
```ruby
# config/environments/production.rb
config.action_dispatch.default_headers.merge!({
  'X-Frame-Options' => 'SAMEORIGIN',
  'X-Content-Type-Options' => 'nosniff',
  'X-XSS-Protection' => '1; mode=block',
  'Referrer-Policy' => 'strict-origin-when-cross-origin',
  'Permissions-Policy' => 'geolocation=(), microphone=(), camera=()'
})
```

---

## Positive Security Findings

The following security controls are properly implemented:

1. **Authentication:** Devise properly configured with:
   - 12-character minimum password length
   - Account lockout after 10 failed attempts
   - Email confirmation required
   - Secure cookie settings (`secure: true`)

2. **Authorization:** CanCanCan implemented for role-based access control (except for the constantize issue)

3. **Secrets Management:**
   - Environment variables used for secrets
   - `.env.rb` properly excluded in `.gitignore`
   - No hardcoded credentials found

4. **SQL Injection Protection:** Parameterized queries used throughout (no SQL injection vulnerabilities found)

5. **Session Security:**
   - Secure session configuration
   - HTTP-only cookies
   - Session timeout configured

---

## Remediation Priority

### Immediate (Within 24 hours)
1. Fix Remote Code Execution vulnerability (#1)
2. Upgrade Rails to 6.1.7.9+ (#2)
3. Enable SSL enforcement (#4)

### Short-term (Within 1 week)
1. Change password hashing to bcrypt (#3)
2. Strengthen CSRF protection for API (#5)
3. Enable Content Security Policy (#6)
4. Implement rate limiting (#7)

### Medium-term (Within 1 month)
1. Fix XSS vulnerabilities (#8)
2. Improve file upload security (#9)
3. Add security headers (#10)

---

## Additional Recommendations

1. **Security Testing:** Implement automated security testing in CI/CD pipeline
2. **Dependency Monitoring:** Use tools like Dependabot or Snyk for dependency vulnerability tracking
3. **Security Training:** Provide secure coding training for development team
4. **Penetration Testing:** Conduct professional penetration testing after fixes
5. **Security Audit Schedule:** Establish quarterly security review process
6. **Logging and Monitoring:** Implement comprehensive security event logging
7. **Incident Response Plan:** Develop and document security incident response procedures

---

## Testing Performed

- Static code analysis
- Dependency vulnerability scanning
- Authentication and authorization review
- Input validation testing
- Configuration review
- Secrets management audit
- XSS vulnerability assessment
- SQL injection testing
- CSRF protection review

---

## Conclusion

The Proposals application has a solid foundation with proper authentication, authorization framework, and secrets management. However, the critical remote code execution vulnerability must be addressed immediately, along with upgrading the Rails version to patch known CVEs. The high-priority security improvements (SSL enforcement, password hashing, CSRF hardening) should be implemented as soon as possible to significantly improve the application's security posture.

After addressing the critical and high-priority issues, the application will have a much stronger security profile suitable for handling sensitive proposal and researcher data.

---

**Reviewed by:** Claude (AI Security Analyst)
**Review Methodology:** OWASP Top 10, SANS Top 25, CWE Analysis
**Tools Used:** Static code analysis, dependency scanning, manual code review
