require 'rails_helper'

RSpec.describe 'states/_list.html.haml', type: :view do
  include Pundit
  helper ApplicationHelper, AutoLinksHelper, FontAwesome::Rails::IconHelper

  let(:state_initial) { State.find_by(key: 'upload_order_created') || create(:state_initial) }
  let(:state_international_shipping_fee) { create(:state_international_shipping_fee) }
  let(:state_drive_shipped) { create(:state_drive_shipped) }
  let(:state_drive_arrived_at_datacenter) { create(:state_drive_arrived_at_datacenter) }
  let(:state_private) do
    create(:state, label: 'Drive mounted on server', percentage: 65,
                   description: 'Your drive was mounted on our servers')
  end
  let(:order) do
    o = create(:order)
    o.order_states << create(:order_state, order: o, state: state_international_shipping_fee, did_notify: true)
    o.order_states << create(:order_state, order: o, state: state_drive_shipped, did_notify: true, is_public: true)
    o.order_states << create(:order_state, order: o, state: state_drive_arrived_at_datacenter, did_notify: true)
    o.order_states << create(:order_state, order: o, state: state_private, comments: 'On evs123.idrive.com')
    return o
  end
  let(:order_policy_update?) { false }
  let(:order_policy) { instance_double('OrderPolicy', update?: order_policy_update?) }

  before do
    assign(:order, order)
    assign(:order_states, order.order_states)
    assign(:order_state, OrderState.new(order: order))

    allow(view).to receive(:policy).with(order).and_return(order_policy)
  end

  context 'with no states' do
    before do
      order.order_states.delete_all
      assign(:order, order)
      assign(:order_states, order.order_states)
    end

    it 'has an empty messsage' do
      render

      expect(rendered).to include('No activity here...')
    end
  end

  context 'with some states' do
    it 'displays a count of how many have occurred' do
      render

      expect(rendered).to include('Order Updates (5)')
    end

    it 'renders all states' do
      render

      expect(rendered).to include(state_initial.label)
      expect(rendered).to include(state_international_shipping_fee.label)
      expect(rendered).to include(state_drive_shipped.label)
      expect(rendered).to include(state_drive_arrived_at_datacenter.label)
      expect(rendered).to include(state_private.label)
    end

    it 'does not render the state form' do
      render
      expect(rendered).not_to have_tag('form', with: { action: order_state_path(order) })
    end

    context 'with update privileges' do
      let(:order_policy_update?) { true }

      it 'renders the state form' do
        render
        expect(rendered).to have_tag('form', with: { action: order_state_path(order) })
      end
    end
  end
end
