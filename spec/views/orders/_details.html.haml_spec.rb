require 'rails_helper'

RSpec.describe 'orders/_details.html.haml', type: :view do
  include Pundit
  include ActiveSupport::Testing::TimeHelpers
  helper AutoLinksHelper, DayCountsHelper, FontAwesome::Rails::IconHelper

  let(:order) { create(:order) }

  before do
    assign(:order, order)
    assign(:order_type, order.order_type)
    assign(:drive, order.drive)
    allow(view).to receive(:policy).and_return(instance_double('OrderPolicy', edit?: true))
    render
  end

  describe '#day_count' do
    it 'displays an order without a day count' do
      expect(rendered).to have_tag('li.js-order-day-count-is-stale')
    end

    context 'with a day count' do
      let(:order) do
        o = build_stubbed(:order)
        allow(o).to receive(:day_count).and_return(build_stubbed(:day_count, count: 1, updated_at: Time.zone.now))
        o
      end

      it 'displays an order with a day count' do
        expect(rendered).to have_tag('span.js-order-day-count', text: /\b1\b/)
      end
    end
  end

  describe '#order_type' do
    it 'displays the order type' do
      expect(rendered).to have_tag('li.list-group-item', text: /Order type\s+#{order.order_type.full_name}/i)
    end
  end

  context 'with an idrive one order' do
    let(:order) { create(:order_idrive_one) }

    it 'does not show :os information as it does not apply' do
      expect(rendered).not_to have_tag('li.list-group-item', text: /Operating system/i)
    end
  end
end
