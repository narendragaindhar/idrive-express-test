require 'rails_helper'

RSpec.describe DayCount do
  include ActiveSupport::Testing::TimeHelpers

  describe '#initialize' do
    it 'is has a count of 0 default' do
      day_count = described_class.new(attributes_for(:day_count, count: nil))
      expect(day_count.count).to eq(0)
    end

    it 'is not "final" by default' do
      day_count = described_class.new(attributes_for(:day_count, is_final: nil))
      expect(day_count.is_final).to eq(false)
    end
  end

  describe '#recount' do
    let(:sunday) { Time.zone.parse('2016-03-27 12:00:00') }
    let(:monday) { sunday.advance(days: 1) }
    let(:tuesday) { sunday.advance(days: 2) }
    let(:wednesday) { sunday.advance(days: 3) }
    let(:thursday) { sunday.advance(days: 4) }
    let(:friday) { sunday.advance(days: 5) }
    let(:saturday) { sunday.advance(days: 6) }
    let(:next_wednesday) { sunday.advance(days: 10) }
    let(:next_friday) { sunday.advance(days: 12) }
    let(:next_next_monday) { sunday.advance(days: 15) }

    let(:state_shipping_fee) { create(:state_international_shipping_fee) }
    let(:state_on_hold_pre_shipped) { create(:state_on_hold_pre_shipped) }
    let(:state_drive_shipped) { create(:state_drive_shipped) }
    let(:state_return_delayed) { create(:state_drive_return_delayed) }
    let(:state_drive_arrived_at_datacenter) { create(:state_drive_arrived_at_datacenter) }
    let(:state_upload_started) { create(:state_upload_started) }
    let(:state_upload_completed) { create(:state_upload_completed) }

    it 'returns 0 until the first weekday occurs' do
      order = nil
      travel_to sunday do
        order = create(:order_with_day_count)
        expect(order.day_count.recount).to eq(0)
        order.order_states << create(:order_state, order: order, state: state_shipping_fee)
        expect(order.day_count.recount).to eq(0)
      end
      travel_to monday do
        expect(order.day_count.recount).to eq(1)
        order.order_states << create(:order_state, order: order, state: state_on_hold_pre_shipped)
        expect(order.day_count.recount).to eq(1)
      end
    end

    it 'only increments on weekdays' do
      order = nil
      travel_to thursday do
        order = create(:order_with_day_count)
        expect(order.day_count.recount).to eq(1)
        order.order_states << create(:order_state, order: order, state: state_shipping_fee)
        expect(order.day_count.recount).to eq(1)
      end
      travel_to friday do
        expect(order.day_count.recount).to eq(2)
        order.order_states << create(:order_state, order: order, state: state_on_hold_pre_shipped)
        expect(order.day_count.recount).to eq(2)
      end
      travel_to saturday do
        expect(order.day_count.recount).to eq(2)
        order.order_states << create(:order_state, order: order, state: state_drive_shipped)
        expect(order.day_count.recount).to eq(2)
      end
    end

    it 'only increments 1 day no matter how many states occur during it' do
      travel_to thursday do
        order = create(:order_with_day_count)
        expect(order.day_count.recount).to eq(1)
        order.order_states << create(:order_state, order: order, state: state_shipping_fee)
        order.order_states << create(:order_state, order: order, state: state_on_hold_pre_shipped)
        order.order_states << create(:order_state, order: order, state: state_drive_shipped)
        expect(order.day_count.recount).to eq(1)
      end
    end

    it 'becomes stale and needs recalculating whenever a new state is added' do
      order = nil
      travel_to monday do
        order = create(:order_with_day_count)
        order.order_states << create(:order_state, order: order, state: state_drive_shipped)
        expect(order.day_count.recount).to eq(1)
      end
      travel_to next_wednesday do
        expect(order.day_count.stale?).to eq(true)
        expect(order.day_count.recount).to eq(1)
        expect(order.day_count.stale?).to eq(false)

        order.order_states << create(:order_state, order: order, state: state_return_delayed)
        expect(order.day_count.stale?).to eq(true)
        expect(order.day_count.recount).to eq(1)
      end
      travel_to next_friday do
        expect(order.day_count.stale?).to eq(true)
        expect(order.day_count.recount).to eq(1)
        expect(order.day_count.stale?).to eq(false)

        order.order_states << create(:order_state, order: order, state: state_drive_arrived_at_datacenter)
        expect(order.day_count.stale?).to eq(true)
        expect(order.day_count.recount).to eq(2)
      end
    end

    it 'only increments while the drive is physically in our possesion' do
      order = nil
      travel_to monday do
        order = create(:order_with_day_count)
        order.order_states << create(:order_state, order: order, state: state_on_hold_pre_shipped)
        order.order_states << create(:order_state, order: order, state: state_drive_shipped)
        expect(order.day_count.recount).to eq(1)
      end
      travel_to tuesday do
        expect(order.day_count.recount).to eq(1)
      end
      travel_to wednesday do
        expect(order.day_count.recount).to eq(1)
      end
      travel_to thursday do
        order.order_states << create(:order_state, order: order, state: state_drive_arrived_at_datacenter)
        expect(order.day_count.recount).to eq(2)
      end
      travel_to friday do
        order.order_states << create(:order_state, order: order, state: state_upload_started)
        order.order_states << create(:order_state, order: order, state: state_upload_completed)
        expect(order.day_count.recount).to eq(3)
      end
    end

    it 'always updates the "updated_at" attribute even if day count is same' do
      order = nil
      travel_to monday do
        order = create(:order_with_day_count)
        order.order_states << create(:order_state, order: order, state: state_drive_shipped)
        expect(order.day_count.recount).to eq(1)
      end
      travel_to tuesday do
        expect(order.day_count.recount).to eq(1)
        expect(order.day_count.updated_at.to_date).to eq(tuesday.to_date)
      end
      travel_to wednesday do
        expect(order.day_count.recount).to eq(1)
        expect(order.day_count.updated_at.to_date).to eq(wednesday.to_date)
      end
      travel_to thursday do
        expect(order.day_count.recount).to eq(1)
        expect(order.day_count.updated_at.to_date).to eq(thursday.to_date)
      end
    end

    it 'handles complex/long order with numerous states' do
      order = nil
      travel_to sunday do
        order = create(:order_with_day_count)
        order.order_states << create(:order_state, order: order, state: state_shipping_fee)
        expect(order.day_count.recount).to eq(0)
      end
      travel_to monday do
        order.order_states << create(:order_state, order: order, state: state_on_hold_pre_shipped)
        expect(order.day_count.recount).to eq(1)
      end
      travel_to tuesday do
        order.order_states << create(:order_state, order: order, state: state_drive_shipped)
        expect(order.day_count.recount).to eq(2)
      end
      travel_to friday do
        expect(order.day_count.recount).to eq(2)
      end
      travel_to next_wednesday do
        order.order_states << create(:order_state, order: order, state: state_return_delayed)
        expect(order.day_count.recount).to eq(2)
      end
      travel_to next_friday do
        order.order_states << create(:order_state, order: order, state: state_drive_arrived_at_datacenter)
        order.order_states << create(:order_state, order: order, state: state_upload_started)
        expect(order.day_count.recount).to eq(3)
      end
      travel_to next_next_monday do
        order.order_states << create(:order_state, order: order, state: state_upload_completed)
        expect(order.day_count.recount).to eq(4)
      end
    end

    it 'only counts up till the completion date' do
      order = nil
      travel_to sunday do
        order = create(:order_with_day_count)
      end
      travel_to monday do
        order.order_states << create(:order_state, order: order, state: state_drive_shipped)
      end
      travel_to next_wednesday do
        order.order_states << create(:order_state, order: order, state: state_drive_arrived_at_datacenter)
        order.order_states << create(:order_state, order: order, state: state_upload_started)
        order.order_states << create(:order_state, order: order, state: state_upload_completed)
        expect(order.day_count.recount).to eq(2)
      end
      travel_to next_next_monday do
        expect(order.day_count.recount).to eq(2)
      end
    end

    it 'finalizes the count if the order is completed' do
      order = nil
      travel_to sunday do
        order = create(:order_with_day_count)
      end
      travel_to monday do
        order.order_states << create(:order_state, order: order, state: state_drive_shipped)
      end
      travel_to next_friday do
        expect(order.day_count.stale?).to eq(true)
        expect(order.day_count.is_final?).to eq(false)
        order.order_states << create(:order_state, order: order, state: state_drive_arrived_at_datacenter)
        order.order_states << create(:order_state, order: order, state: state_upload_started)
        order.order_states << create(:order_state, order: order, state: state_upload_completed)
        expect(order.day_count.recount).to eq(2)
        expect(order.day_count.stale?).to eq(false)
        expect(order.day_count.is_final?).to eq(true)
      end
      travel_to next_next_monday do
        expect(order.day_count.stale?).to eq(false)
      end
    end

    it 'counts correctly for even when it gets "shipped" twice' do
      order = nil
      travel_to monday do
        order = create(:order_with_day_count)
        order.order_states << create(:order_state, order: order, state: state_drive_shipped)
      end
      travel_to friday do
        order.order_states << create(
          :order_state,
          order: order,
          state: create(:state, label: 'Drive received in Calabasas', leaves_us: 1,
                                description: 'Drive received in Calabasas. Forwarding to Oregon.')
        )
        expect(order.day_count.recount).to eq(2)
      end
      travel_to next_wednesday do
        order.order_states << create(:order_state, order: order, state: state_drive_arrived_at_datacenter)
        order.order_states << create(:order_state, order: order, state: state_upload_started)
        order.order_states << create(:order_state, order: order, state: state_upload_completed)
        expect(order.day_count.recount).to eq(3)
      end
    end

    context 'with an idrive restore order' do
      let(:state_shipping_fee) { create(:state_restore_international_shipping_fee) }
      let(:state_restore_started) { create(:state_restore_restore_started) }
      let(:state_drive_shipped) { create(:state_restore_order_shipped) }
      let(:state_return_delayed) { create(:state_restore_drive_return_delayed) }
      let(:state_restore_completed) { create(:state_restore_completed) }

      it 'handles complex/long order with numerous states' do
        order = nil
        travel_to sunday do
          order = create(:order_restore_with_day_count)
          order.order_states << create(:order_state, order: order, state: state_shipping_fee)
          expect(order.day_count.recount).to eq(0)
        end
        travel_to monday do
          order.order_states << create(:order_state, order: order, state: state_restore_started)
          expect(order.day_count.recount).to eq(1)
        end
        travel_to tuesday do
          order.order_states << create(:order_state, order: order, state: state_drive_shipped)
          expect(order.day_count.recount).to eq(2)
        end
        travel_to friday do
          expect(order.day_count.recount).to eq(2)
        end
        travel_to next_wednesday do
          order.order_states << create(:order_state, order: order, state: state_return_delayed)
          expect(order.day_count.recount).to eq(2)
        end
        travel_to next_next_monday do
          order.order_states << create(:order_state, order: order, state: state_restore_completed)
          expect(order.day_count.recount).to eq(3)
        end
      end
    end
  end

  describe '#stale?' do
    let(:today) { Time.zone.now.beginning_of_day }
    let(:yesterday) do
      y = today.yesterday
      Time.zone.parse("#{y.year}-#{y.month}-#{y.day} 23:59:59")
    end

    it 'always returns true when it is a new record' do
      day_count = build(:day_count)
      expect(day_count.stale?).to eq(true)
    end

    it 'always returns false when it is final' do
      day_count = create(:day_count, count: 3, is_final: true)
      expect(day_count.stale?).to eq(false)
    end

    it 'returns true if it hasn\'t been updated today' do
      day_count = create(:day_count, count: 1, updated_at: yesterday)
      expect(day_count.stale?).to eq(true)
    end

    it 'returns false if it has been updated today' do
      day_count = create(:day_count, count: 1, updated_at: today)
      expect(day_count.stale?).to eq(false)
    end
  end

  describe '#validate' do
    describe 'count' do
      it 'only deals with positive day counts' do
        expect(build(:day_count, count: -2)).not_to be_valid
        expect(build(:day_count, count: -1)).not_to be_valid
        expect(build(:day_count, count: 0)).to be_valid
        expect(build(:day_count, count: 1)).to be_valid
      end
    end

    describe 'is_final' do
      it 'only deals in boolean values for is_final' do
        expect(build(:day_count, is_final: true)).to be_valid
        expect(build(:day_count, is_final: false)).to be_valid
      end
    end

    describe 'order' do
      it 'is required' do
        expect(build(:day_count, order: nil)).not_to be_valid
      end
    end
  end
end
