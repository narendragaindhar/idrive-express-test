class UserRolePolicy < ApplicationPolicy
  # Is the user allowed to view role editor for the given user?
  #
  # @param user [Object] the user that initiated the action
  # @param record [Object] the user role context whose role(s) we want to edit
  def edit?
    if user.role? :super_user
      can_do_super_user_changes?
    elsif user.role? :role_manager
      # role managers can edit all except super users
      !record.user.role? :super_user
    else
      false
    end
  end

  # Is the user allowed to update roles for the given user?
  #
  # @param user [Object] the user that initiated the action
  # @param record [Object] the user role context showing the desired changes
  def update?
    if user.role? :super_user
      can_do_super_user_changes?
    elsif user.role? :role_manager
      # first check if we can edit the user's roles
      return false if record.user.role? :super_user

      # then check the roles we want to assign
      record.roles.each do |role|
        return false if role.key.to_sym == :super_user
      end
      true
    else
      false
    end
  end

  private

  # super users can't change each other, only themselves
  def can_do_super_user_changes?
    !record.user.role?(:super_user) || user.id == record.user.id
  end
end
