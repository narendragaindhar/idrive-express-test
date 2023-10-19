require 'rails_helper'

RSpec.describe DayCountsHelper do
  describe '#day_count_stale_class' do
    it 'returns the class if no day count exists' do
      order = create(:order)
      expect(helper.day_count_stale_class(order)).to eq('js-order-day-count-is-stale')
    end

    it 'returns the class if it is stale' do
      order = create(:order_with_day_count)
      expect(helper.day_count_stale_class(order)).to eq('js-order-day-count-is-stale')
    end

    it 'returns nothing if it is not stale' do
      order = create(:order_with_day_count)
      order.day_count.recount
      expect(helper.day_count_stale_class(order)).to eq('')
    end
  end
end
