require 'rails_helper'

RSpec.describe 'orders/show.html.haml', type: :view do
  include Pundit
  helper ApplicationHelper, AutoLinksHelper, DayCountsHelper, FontAwesome::Rails::IconHelper, OrdersHelper

  let(:customer) { create(:customer, username: 'homer_simpson') }
  let(:order) { create(:order_upload, customer: customer) }
  let(:order_policy_update?) { false }
  let(:order_policy) { instance_double('OrderPolicy', edit?: order_policy_update?, update?: order_policy_update?) }

  before do
    assign(:order, order)
    assign(:address, order.address)
    assign(:customer, order.customer)
    assign(:destination, order.destination)
    assign(:order_state, OrderState.new)
    assign(:order_states, order.order_states)
    assign(:order_type, order.order_type)

    allow(view).to receive(:policy).with(order).and_return(order_policy)
    render
  end

  it 'shows the order label' do
    expect(rendered).to have_tag('h3', text: /Order #\d+ \| IDrive Express Upload for homer_simpson/)
  end

  it 'does not link to edit page' do
    expect(rendered).not_to have_tag('a', with: { href: edit_order_path(order) })
  end

  context 'with edit privileges' do
    let(:order_policy_update?) { true }

    it 'does not link to edit page' do
      expect(rendered).to have_tag('a', with: { href: edit_order_path(order) })
    end
  end
end
