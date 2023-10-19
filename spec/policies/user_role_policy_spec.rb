require 'rails_helper'

RSpec.describe UserRolePolicy do
  let(:role_super_user) { create(:role_super_user) }
  let(:role_role_manager) { create(:role_role_manager) }
  let(:role_idrive_employee) { create(:role_idrive_employee) }
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:super_user) do
    u = create(:user)
    u.roles << role_super_user
    u
  end
  let(:role_manager_user) do
    u = create(:user)
    u.roles << role_role_manager
    u
  end

  permissions :edit? do
    it 'denies access if user does not have any roles' do
      expect(described_class).not_to permit(user, Contexts::UserRole.new(user2))
    end

    it 'denies access if user does not have the correct roles' do
      user.roles << create(:role, key: :model_other_show, name: 'Other show')
      expect(described_class).not_to permit(user, Contexts::UserRole.new(user2))
    end

    it 'denies access if other user has role `super_user`' do
      expect(described_class).not_to permit(role_manager_user, Contexts::UserRole.new(super_user))
    end

    it 'allows access to edit themselves as a super user' do
      expect(described_class).to permit(super_user, Contexts::UserRole.new(super_user))
    end

    it 'allows access if user has role `super_user`' do
      expect(described_class).to permit(super_user, Contexts::UserRole.new(user))
    end

    it 'allows access if user has role `role_manager`' do
      expect(described_class).to permit(role_manager_user, Contexts::UserRole.new(user))
    end
  end

  permissions :update? do
    let(:role_context) { Contexts::UserRole.new(user2, role_idrive_employee) }

    context 'with no roles' do
      let(:current_user) { user }

      it 'denies access to change roles' do
        expect(described_class).not_to permit(current_user, role_context)
      end
    end

    context 'with the wrong roles' do
      let(:current_user) do
        user.roles << create(:role, key: :other_role, name: 'Other role')
        user
      end

      it 'denies access to change roles' do
        expect(described_class).not_to permit(current_user, role_context)
      end
    end

    context 'with role `role_manager`' do
      it 'allows access to change normal roles' do
        expect(described_class).to permit(role_manager_user, role_context)
      end

      it 'allows access to promote to role manager' do
        expect(described_class).to permit(role_manager_user, Contexts::UserRole.new(user2, role_role_manager))
      end

      it 'denies access to promote to super user' do
        expect(described_class).not_to permit(role_manager_user, Contexts::UserRole.new(user2, role_super_user))
      end

      it 'denies access if other user is super user' do
        expect(described_class).not_to permit(
          role_manager_user, Contexts::UserRole.new(super_user, role_idrive_employee)
        )
      end
    end

    context 'with role `super_user`' do
      it 'allows access to change normal roles' do
        expect(described_class).to permit(super_user, role_context)
      end

      it 'allows access to promote to role manager' do
        expect(described_class).to permit(super_user, Contexts::UserRole.new(user2, role_role_manager))
      end

      it 'allows access to promote to super user' do
        expect(described_class).to permit(super_user, Contexts::UserRole.new(user2, role_super_user))
      end

      it 'denies access if other user is super user' do
        user2.roles << role_super_user
        expect(described_class).not_to permit(super_user, Contexts::UserRole.new(user2, role_idrive_employee))
      end

      it 'allows access if editing own roles' do
        expect(described_class).to permit(super_user, Contexts::UserRole.new(super_user, role_idrive_employee))
      end
    end
  end
end
