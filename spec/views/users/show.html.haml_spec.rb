require 'rails_helper'

RSpec.describe 'users/show.html.haml', type: :view do
  include Pundit
  helper FontAwesome::Rails::IconHelper

  let(:role_idrive_employee) { create(:role_idrive_employee, name: 'Express agent', description: 'Normal stuff') }
  let(:user) do
    u = create(:user, name: 'Avery Alexander', email: 'avery@alexander.com')
    u.roles << create(:role_super_user, name: 'Super user', description: 'All permissions')
    u
  end
  let(:other_user) do
    u = create(:user, name: 'Dennis Donahue', email: 'dennis@donahue.com')
    u.roles << role_idrive_employee
    u
  end

  before do
    assign(:user, other_user)
    allow(view).to receive(:policy) do |record|
      Pundit.policy(user, record)
    end
  end

  it 'displays the name of the user' do
    render
    expect(rendered).to include('Dennis Donahue')
  end

  it 'displays the email of the user' do
    render
    expect(rendered).to include('dennis@donahue.com')
  end

  it 'displays the roles of the user' do
    render
    expect(rendered).to have_tag('span', count: 1, text: 'Express agent',
                                         with: { class: 'tag', title: 'Normal stuff' })
  end

  it 'displays the status of the user' do
    disabled_user = create(:user, name: 'Mr. disabled', disabled_at: Time.now)
    assign(:user, disabled_user)
    render
    expect(rendered).to have_tag('span', text: 'Disabled',
                                         with: { class: 'tag' })
  end

  it 'does not show the "edit" link' do
    expect(render).not_to have_tag('a', with: { href: edit_user_path(other_user) }, text: /Edit/)
  end

  context 'with :edit? permission' do
    before do
      assign(:user, user)
    end

    it 'shows the "edit" link' do
      expect(render).to have_tag('a', with: { href: edit_user_path(user) }, text: /Edit/)
    end
  end

  context 'with :edit? permission for roles' do
    let(:user) do
      u = create(:user)
      u.roles << create(:role_role_manager)
      u
    end

    it 'shows a link to edit roles' do
      expect(render).to have_tag('a', with: { href: edit_user_roles_path(other_user) })
    end
  end
end
