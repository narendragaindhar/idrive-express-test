require 'rails_helper'

RSpec.describe Contexts::UserRole do
  let(:user) { create(:user) }
  let(:role_idrive_employee) { create(:role_idrive_employee) }
  let(:role_role_manager) { create(:role_role_manager) }
  let(:roles) { [role_idrive_employee, role_role_manager] }

  it 'can be created with a user and roles' do
    urc = described_class.new(user, roles)
    expect(urc.user).to eq(user)
    expect(urc.roles).to eq(roles)
  end

  it 'sets role to nil if none provided' do
    urc = described_class.new(user)
    expect(urc.roles).to be_nil
  end

  it 'accepts a singular role and converts it to an array' do
    urc = described_class.new(user, role_idrive_employee)
    expect(urc.roles).to eq([role_idrive_employee])
  end

  it 'is associated with the user role policy' do
    expect(described_class.policy_class).to eq(UserRolePolicy)
  end
end
