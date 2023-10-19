require 'rails_helper'

RSpec.describe 'roles/edit.html.haml', type: :view do
  include Pundit
  helper FontAwesome::Rails::IconHelper

  let(:role_idrive_employee) { create(:role_idrive_employee) }
  let(:role_role_manager) { create(:role_role_manager) }
  let(:chosen_roles) { [role_idrive_employee] }
  let(:roles) { [role_idrive_employee, role_role_manager] }
  let(:user) do
    u = create(:user, name: 'Avery Alexander', email: 'avery@alexander.com')
    u.roles = chosen_roles
    u
  end

  before do
    assign(:user, user)
    assign(:chosen_roles, chosen_roles)
    assign(:roles, roles)
  end

  it 'displays a checkbox for all @roles' do
    render
    roles.each do |role|
      expect(rendered).to have_tag('input', with: { name: 'user[roles][]', value: role.id })
    end
  end

  it 'automatically prechecks the @chosen_roles checkboxes' do
    render
    chosen_roles.each do |role|
      expect(rendered).to have_tag('input', with: { checked: 'checked', name: 'user[roles][]', value: role.id })
    end
  end
end
