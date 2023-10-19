require 'rails_helper'

RSpec.describe AdminPolicy do
  let(:user) { create(:user) }

  permissions :manage? do
    it 'denies access if user does not have any roles' do
      expect(described_class).not_to permit(user)
    end

    it 'denies access if user does not have the correct roles' do
      user.roles << create(:role, key: :model_other_create, name: 'Other create')
      expect(described_class).not_to permit(user)
    end

    it 'allows access if user has role `super_user`' do
      user.roles << create(:role_super_user)
      expect(described_class).to permit(user)
    end

    it 'allows access if user has role `idrive_employee`' do
      user.roles << create(:role_idrive_employee)
      expect(described_class).to permit(user)
    end

    it 'denies access if user has role `support_agent`' do
      user.roles << create(:role_support_agent)
      expect(described_class).not_to permit(user)
    end
  end
end
