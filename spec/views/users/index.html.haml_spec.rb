require 'rails_helper'

RSpec.describe 'users/index.html.haml', type: :view do
  include Pundit
  helper FontAwesome::Rails::IconHelper

  let(:role_idrive_employee) { create(:role_idrive_employee, name: 'Express agent', description: 'Normal stuff') }
  let(:user_a) do
    u = create(:user, name: 'Avery Alexander', email: 'avery@alexander.com')
    u.roles << create(:role_super_user, name: 'Super user', description: 'All permissions')
    u
  end
  let(:user_d) do
    u = create(:user, name: 'Dennis Donahue', email: 'dennis@donahue.com')
    u.roles << role_idrive_employee
    u
  end
  let(:user_p) do
    u = create(:user, name: 'Peter Patrick', email: 'peter@patrick.com')
    u.roles << role_idrive_employee
    u
  end
  let(:user_t) do
    u = create(:user, name: 'Tom Thompson', email: 'tom@thompson.com')
    u.roles << create(:role_idrive_one_contractor, name: 'IDrive One contractor',
                                                   description: 'Only IDrive One permissions')
    u
  end
  let(:users) do
    [
      user_a,
      user_d,
      user_p,
      user_t
    ]
  end

  before do
    assign(:users, users)
    assign(:user, User.new)
    allow(view).to receive(:policy) do |record|
      Pundit.policy(user_a, record)
    end
  end

  it 'displays the names of the users' do
    render
    expect(rendered).to include('Avery Alexander')
    expect(rendered).to include('Dennis Donahue')
    expect(rendered).to include('Peter Patrick')
    expect(rendered).to include('Tom Thompson')
  end

  it 'links to the email address of the users' do
    render
    expect(rendered).to have_tag('a', with: { href: "mailto:#{user_a.email}" }, text: user_a.email)
    expect(rendered).to have_tag('a', with: { href: "mailto:#{user_d.email}" }, text: user_d.email)
    expect(rendered).to have_tag('a', with: { href: "mailto:#{user_p.email}" }, text: user_p.email)
    expect(rendered).to have_tag('a', with: { href: "mailto:#{user_t.email}" }, text: user_t.email)
  end

  it 'shows the user roles' do
    users << create(:user, name: 'Mr. No Roles')
    assign(:users, users)
    render
    expect(rendered).to have_tag(
      'span', count: 1, text: 'Super user',
              with: { class: 'tag', title: 'All permissions' }
    )
    expect(rendered).to have_tag(
      'span', count: 2, text: 'Express agent',
              with: { class: 'tag', title: 'Normal stuff' }
    )
    expect(rendered).to have_tag(
      'span', count: 1, text: 'IDrive One contractor',
              with: { class: 'tag', title: 'Only IDrive One permissions' }
    )
    expect(rendered).to have_tag('span', count: 1, with: { class: 'text-muted' }, text: 'None')
  end

  it 'shows the user status' do
    users << create(:user, name: 'Mr. disabled', disabled_at: Time.now)
    assign(:users, users)
    render
    expect(rendered).to have_tag('span', with: { class: 'tag'}, text: 'Enabled')
    expect(rendered).to have_tag('span', with: { class: 'tag'}, text: 'Enabled')
    expect(rendered).to have_tag('span', with: { class: 'tag'}, text: 'Enabled')
    expect(rendered).to have_tag('span', with: { class: 'tag'}, text: 'Enabled')
    expect(rendered).to have_tag('span', with: { class: 'tag'}, text: 'Enabled')
    expect(rendered).to have_tag('span', with: { class: 'tag'}, text: 'Disabled')
  end

  it 'has a "new user" button' do
    expect(render).to have_tag('button', text: /New User/)
  end

  context 'without :show? permission' do
    let(:user_a) { create(:user, name: 'Avery Alexander') }

    it 'does not link to the users' do
      render
      expect(rendered).to have_tag('a', text: user_a.name)
      expect(rendered).not_to have_tag('a', text: user_d.name)
      expect(rendered).not_to have_tag('a', text: user_p.name)
      expect(rendered).not_to have_tag('a', text: user_t.name)
    end
  end

  context 'with :show? permission' do
    it 'links to the users' do
      render
      expect(rendered).to have_tag('a', text: user_a.name)
      expect(rendered).to have_tag('a', text: user_d.name)
      expect(rendered).to have_tag('a', text: user_p.name)
      expect(rendered).to have_tag('a', text: user_t.name)
    end
  end

  context 'with :update? permission' do
    it 'links to the edit page' do
      render
      expect(rendered).to have_tag('a', with: { href: edit_user_path(user_a) }, text: 'Edit')
    end
  end

  context 'without :update? permission' do
    it 'does not link to the edit page' do
      render
      expect(rendered).not_to have_tag('a', with: { href: edit_user_path(user_d) }, text: 'Edit')
      expect(rendered).not_to have_tag('a', with: { href: edit_user_path(user_p) }, text: 'Edit')
      expect(rendered).not_to have_tag('a', with: { href: edit_user_path(user_t) }, text: 'Edit')
    end
  end
end
