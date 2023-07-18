# frozen_string_literal: true

Email.find_each do |email|
  email.send(:unwrap_cc_emails)
  email.save if email.changed?
end
