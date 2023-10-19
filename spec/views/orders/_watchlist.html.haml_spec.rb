require 'rails_helper'

RSpec.describe 'orders/_watchlist.html.haml', type: :view do
  include Pundit
  helper FontAwesome::Rails::IconHelper

  let(:user) { create(:user) }
  let(:order) do
    o = create(:order)
    o.users << user
    o
  end
  let(:order_policy_update?) { false }
  let(:order_policy) { instance_double('OrderPolicy', update?: order_policy_update?) }

  before do
    assign(:order, order)

    allow(view).to receive(:policy).with(order).and_return(order_policy)
    render
  end

  it 'does not render form to add to watchlist' do
    expect(rendered).not_to have_tag('form', with: { action: order_users_path(order) })
  end

  it 'does not render buttons to remove users from the watchlist' do
    expect(rendered).not_to have_tag('a', with: { 'data-method' => 'delete', href: order_user_path(order, user) })
  end

  context 'with update privileges' do
    let(:order_policy_update?) { true }

    it 'renders form to add to watchlist' do
      expect(rendered).to have_tag('form', with: { action: order_users_path(order) })
    end

    it 'renders buttons to remove users from the watchlist' do
      expect(rendered).to have_tag('a', with: { 'data-method' => 'delete', href: order_user_path(order, user) })
    end
  end
end
