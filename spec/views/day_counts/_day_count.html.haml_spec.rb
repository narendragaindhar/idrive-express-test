require 'rails_helper'

RSpec.describe 'day_counts/_day_count.html.haml', type: :view do
  include ActiveSupport::Testing::TimeHelpers
  helper FontAwesome::Rails::IconHelper, OrdersHelper

  let(:monday) { Time.zone.parse('2016-03-28 12:00:00') }
  let(:monday_afternoon) { monday.advance(hours: 4) }
  let(:tuesday) { monday.advance(days: 1) }

  context 'when the order has an existing day count' do
    it 'shows the count when it is not stale' do
      travel_to monday do
        order = create(:order_with_day_count)
        order.day_count.recount
        render 'day_counts/day_count', order: order
      end

      expect(rendered).to match(/1 day/)
    end

    it 'shows "calculating" when it is stale' do
      order = nil
      travel_to monday do
        order = create(:order_with_day_count)
      end
      travel_to tuesday do
        render 'day_counts/day_count', order: order
      end

      expect(rendered).to match(/calculating/i)
    end
  end

  context 'when the order doesn\'t have an existing day count' do
    it 'shows "calculating" when it is stale' do
      order = nil
      travel_to monday do
        order = create(:order)
      end
      travel_to tuesday do
        render 'day_counts/day_count', order: order
      end

      expect(rendered).to match(/calculating/i)
    end
  end
end
