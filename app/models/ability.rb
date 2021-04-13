# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user&.roles&.each do |role| 
      role.role_privileges.each do |privilege|
        if privilege.permission_type == 'write'
          can :manage, privilege.privilege_name.to_sym
        else
          can :read, privilege.privilege_name.to_sym
        end
      end
    end
  end
end
