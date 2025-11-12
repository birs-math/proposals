# app/models/ability.rb
# frozen_string_literal: true
class Ability
  include CanCan::Ability

  # Whitelist of allowed model names for privileges
  # Only these classes can be used in authorization rules
  ALLOWED_PRIVILEGES = %w[
    Proposal
    ProposalType
    Location
    Schedule
    User
    Role
    Answer
    Email
    Review
    Subject
    Participant
  ].freeze

  def initialize(user)
    user&.roles&.each do |role|
      role.role_privileges.each do |privilege|
        check_privilege(privilege)
      end
    end

    # Staff members (birs.ca emails) can view demographic data
    if user&.staff_member?
      can :view, :demographic_data
    end
  end

  private

  def check_privilege(privilege)
    # Security fix: Only allow whitelisted privilege names
    # This prevents Remote Code Execution via constantize
    unless ALLOWED_PRIVILEGES.include?(privilege.privilege_name)
      Rails.logger.warn("Attempted to use non-whitelisted privilege: #{privilege.privilege_name}")
      return
    end

    case privilege.permission_type
    when 'Manage'
      can :manage, privilege.privilege_name.constantize
    when 'Read'
      can :read, privilege.privilege_name.constantize
    when 'Write'
      can :write, privilege.privilege_name.constantize
    end
  end
end
