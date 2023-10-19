module Contexts
  class UserRole
    attr_reader :user, :roles

    def self.policy_class
      UserRolePolicy
    end

    def initialize(user, roles = nil)
      @user = user
      @roles = if roles.nil?
                 nil
               elsif roles.respond_to? :each
                 roles
               else
                 [roles]
               end
    end
  end
end
