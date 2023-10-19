require 'rails_helper'

RSpec.describe 'layouts/_nav.html.haml', type: :view do
  include Pundit

  let(:user) { nil }
  let(:orders_path_sym) { :orders_path }
  let(:order_policy_new?) { false }
  let(:order_policy) { instance_double('OrderPolicy', new?: order_policy_new?) }
  let(:admin_policy_manage?) { false }
  let(:admin_policy) { instance_double('AdminPolicy', manage?: admin_policy_manage?) }
  let(:report_policy_index?) { false }
  let(:report_policy) { instance_double('ReportPolicy', index?: report_policy_index?) }
  let(:user_policy_index?) { false }
  let(:user_policy) { instance_double('UserPolicy', index?: user_policy_index?) }

  before do
    allow(view).to receive(:logged_in?).at_least(1).and_return(user.present?)
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:policy).with(:order).and_return(order_policy)
    allow(view).to receive(:policy).with(:admin).and_return(admin_policy)
    allow(view).to receive(:policy).with(:report).and_return(report_policy)
    allow(view).to receive(:policy).with(:user).and_return(user_policy)
    assign(:orders_path_sym, orders_path_sym)
    render
  end

  it 'has a home link' do
    expect(rendered).to have_tag('a.navbar-brand', text: /Express/)
  end

  context 'when logged out' do
    it 'shows login link' do
      expect(rendered).to have_tag('a', with: { href: login_path })
    end

    it 'shows forgot password link' do
      expect(rendered).to have_tag('a', with: { href: new_password_path })
    end

    it 'does not show the search form' do
      expect(rendered).not_to have_tag('form', with: { action: orders_path })
    end
  end

  context 'when logged in' do
    let(:user) { build_stubbed(:user) }

    it 'shows orders link' do
      expect(rendered).to have_tag('a', with: { href: orders_path })
    end

    it 'shows my orders link' do
      expect(rendered).to have_tag('a', with: { href: my_orders_path })
    end

    it 'does not show new order link' do
      expect(rendered).not_to have_tag('a', with: { href: new_order_path })
    end

    it 'does not show admin link' do
      expect(rendered).not_to have_tag('a', with: { href: rails_admin.dashboard_path })
    end

    it 'does not show reports link' do
      expect(rendered).not_to have_tag('a', with: { href: reports_path })
    end

    it 'does not show users link' do
      expect(rendered).not_to have_tag('a', with: { href: users_path })
    end

    it 'shows profile link' do
      expect(rendered).to have_tag('a', with: { href: user_path(user) })
    end

    it 'shows log out link' do
      expect(rendered).to have_tag('a', with: { href: logout_path })
    end

    describe 'search form' do
      it 'is shown' do
        expect(rendered).to have_tag('form', with: { action: orders_path }) {
          with_tag('input', with: { name: 'q', placeholder: 'Search orders...' })
        }
      end

      it 'has predefined searches' do
        expect(rendered).to have_tag('.main-nav-predefined-searches') {
          with_tag('a', count: 6)
        }
      end
    end

    context 'with order policy :new? permission' do
      let(:order_policy_new?) { true }

      it 'shows new order link' do
        expect(rendered).to have_tag('a', with: { href: new_order_path })
      end
    end

    context 'with admin policy :manage? permission' do
      let(:admin_policy_manage?) { true }

      it 'shows admin link' do
        expect(rendered).to have_tag('a', with: { href: rails_admin.dashboard_path })
      end
    end

    context 'with report policy :index? permission' do
      let(:report_policy_index?) { true }

      it 'shows reports link' do
        expect(rendered).to have_tag('a', with: { href: reports_path })
      end
    end

    context 'with user policy :index? permission' do
      let(:user_policy_index?) { true }

      it 'shows users link' do
        expect(rendered).to have_tag('a', with: { href: users_path })
      end
    end

    context 'when browsing my orders' do
      let(:orders_path_sym) { :my_orders_path }

      it 'shows a slightly different search form' do
        expect(rendered).to have_tag('form', with: { action: my_orders_path }) {
          with_tag('input', with: { placeholder: 'Search my orders...' })
        }
      end
    end
  end
end
