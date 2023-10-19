require 'rails_helper'

RSpec.describe OrdersHelper do
  include ActiveSupport::Testing::TimeHelpers
  let(:day_one) { Time.zone.parse('2016-03-28 12:00:00') }

  describe '#order_is_in_danger?' do
    let(:day_five) { day_one.advance(days: 4) }
    let(:day_six) { day_one.advance(days: 7) }

    before do
      allow(ENV).to receive(:[]).with('ORDERS_DANGER_DAYS').and_return('6')
    end

    it 'returns false if the order is completed' do
      order = nil
      travel_to day_one do
        order = create(:order)
        order.create_day_count
      end
      travel_to day_six do
        create(:order_state, order: order, state: create(:state_upload_completed))
        order.day_count.recount
        expect(helper.order_is_in_danger?(order)).to eq(false)
      end
    end

    it 'returns false if no day count exists' do
      order = nil
      travel_to day_one do
        order = create(:order)
      end
      travel_to day_six do
        expect(helper.order_is_in_danger?(order)).to eq(false)
      end
    end

    it 'returns false if the order\'s day count is stale' do
      order = nil
      travel_to day_one do
        order = create(:order)
        order.create_day_count
      end
      travel_to day_six do
        expect(helper.order_is_in_danger?(order)).to eq(false)
      end
    end

    it 'returns false if the order\'s days are < the specified danger cutoff' do
      order = nil
      travel_to day_one do
        order = create(:order)
        order.create_day_count
      end
      travel_to day_five do
        order.day_count.recount
        expect(helper.order_is_in_danger?(order)).to eq(false)
      end
    end

    it 'returns true if the order\'s days are >= the specified danger cutoff' do
      order = nil
      travel_to day_one do
        order = create(:order)
        order.create_day_count
      end
      travel_to day_six do
        order.day_count.recount
        expect(helper.order_is_in_danger?(order)).to eq(true)
      end
    end
  end

  describe '#order_is_in_warning?' do
    let(:day_three) { day_one.advance(days: 2) }
    let(:day_four) { day_one.advance(days: 3) }

    before do
      allow(ENV).to receive(:[]).with('ORDERS_WARNING_DAYS').and_return('4')
    end

    it 'returns false if the order is completed' do
      order = nil
      travel_to day_one do
        order = create(:order)
        order.create_day_count
      end
      travel_to day_four do
        create(:order_state, order: order, state: create(:state_upload_completed))
        order.day_count.recount
        expect(helper.order_is_in_warning?(order)).to eq(false)
      end
    end

    it 'returns false if no day count exists' do
      order = nil
      travel_to day_one do
        order = create(:order)
        expect(helper.order_is_in_warning?(order)).to eq(false)
      end
    end

    it 'returns false if the order\'s day count is stale' do
      order = nil
      travel_to day_one do
        order = create(:order)
      end
      travel_to day_four do
        expect(helper.order_is_in_warning?(order)).to eq(false)
      end
    end

    it 'returns false if the order\'s days are < the specified warning cutoff' do
      order = nil
      travel_to day_one do
        order = create(:order)
        order.create_day_count
      end
      travel_to day_three do
        order.day_count.recount
        expect(helper.order_is_in_warning?(order)).to eq(false)
      end
    end

    it 'returns true if the order\'s days are >= the specified warning cutoff' do
      order = nil
      travel_to day_one do
        order = create(:order)
        order.create_day_count
      end
      travel_to day_four do
        order.day_count.recount
        expect(helper.order_is_in_warning?(order)).to eq(true)
      end
    end
  end
end
