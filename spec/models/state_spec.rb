require 'rails_helper'

RSpec.describe State do
  let!(:order_type_upload) { create(:order_type_idrive_upload) }
  let(:state_initial) { create(:state_initial) }

  describe '.get_initial_state' do
    it 'returns the first state for an order type' do
      create(:state_international_shipping_fee, percentage: 5)
      create(:state_drive_shipped)
      state_initial

      expect(state_initial).to eq(described_class.get_initial_state(order_type_upload))
    end
  end

  describe 'scope' do
    let(:state2) { create(:state_international_shipping_fee, active: false) }
    let(:state3) { create(:state_drive_shipped) }
    let(:state4) { create(:state_upload_started) }
    let(:state5) { create(:state_upload_completed) }

    describe '.by_percentage' do
      let(:sorted_by_percentage) do
        d = state4
        b = state2
        e = state5
        c = state3
        a = state_initial
        [a, b, c, d, e]
      end

      it 'returns States sorted by percentage' do
        sorted_by_percentage # cache our values
        described_class.by_percentage.each_with_index do |s, i|
          expect(s).to eq(sorted_by_percentage[i])
        end
      end
    end

    describe '.usable' do
      let(:usable) do
        d = state4
        state2
        e = state5
        c = state3
        a = state_initial
        [a, c, d, e]
      end

      it 'returns active States sorted by percentage' do
        usable # cache our values
        described_class.usable(order_type_upload).each_with_index do |s, i|
          expect(s).to eq(usable[i])
        end
      end
    end
  end

  describe '.after_initialize' do
    it 'becomes active by default if nil is passed and it is a new record' do
      state = described_class.new(attributes_for(:state, active: nil))
      expect(state.active).to eq(true)
    end

    it 'active can be false if it is a new record' do
      state = described_class.new(attributes_for(:state, active: false))
      expect(state.active).to eq(false)
    end
  end

  describe '#completes_successfully?' do
    it 'returns false for unimportant states' do
      %i[
        state_initial
        state_upload_started
        state_drive_shipped
        state_restore_restore_started
        state_restore_initial
        state_idrive_one_initial
        state_idrive_one_assembled
        state_ibackup_upload_drive_shipped
        state_ibackup_upload_drive_return_delayed
        state_ibackup_upload_drive_arrived_at_datacenter
      ].each do |name|
        expect(create(name).completes_successfully?).to eq(false)
      end
    end

    it 'returns true for the states that complete an order successfully' do
      %i[
        state_upload_completed
        state_restore_completed
        state_idrive_one_order_shipped
        state_idrive_bmr_order_shipped
        state_idrive_bmr_upload_order_completed
        state_idrive_bmr_restore_order_completed
        state_idrive360_upload_order_completed
        state_idrive360_restore_order_completed
        state_ibackup_upload_completed
      ].each do |name|
        expect(create(name).completes_successfully?).to eq(true)
      end
    end
  end

  describe '#is_out_of_our_hands?' do
    it 'returns false for normal states' do
      %i[
        state_initial
        state_upload_started
        state_on_hold_pre_shipped
        state_drive_shipped
        state_restore_order_shipped
        state_restore_restore_started
        state_restore_initial
        state_idrive_one_initial
        state_idrive_one_assembled
        state_ibackup_upload_started
        state_ibackup_upload_international_shipping_fee
      ].each do |name|
        expect(create(name).is_out_of_our_hands?).to eq(false)
      end
    end

    it 'returns true for states that occur when the drive is out of our hands' do
      %i[
        state_drive_return_delayed
        state_restore_drive_return_delayed
        state_ibackup_upload_drive_return_delayed
      ].each do |name|
        expect(create(name).is_out_of_our_hands?).to eq(true)
      end
    end
  end

  describe '#key=' do
    it 'ensures the key is always lowercase' do
      expect(build(:state_initial, key: 'UPPER_CASE').key).to eq('upper_case')
    end
  end

  describe '#label_and_percentage' do
    it 'gives a nice string representation of itself' do
      expect(create(:state, label: 'Did some work', percentage: 15).label_and_percentage).to eq('Did some work - 15%')
      expect(create(:state, label: 'Started upload', percentage: 55).label_and_percentage).to eq('Started upload - 55%')
      expect(
        create(:state, label: 'Order completed', percentage: 100).label_and_percentage
      ).to eq('Order completed - 100% (Completes order)')
    end
  end

  describe '#leaves_us?' do
    it 'returns false for normal states' do
      %i[
        state_initial
        state_upload_started
        state_on_hold_pre_shipped
        state_drive_return_delayed
        state_restore_restore_started
        state_restore_initial
        state_ibackup_upload_initial
        state_ibackup_upload_on_hold_pre_shipped
      ].each do |name|
        expect(create(name).leaves_us?).to eq(false)
      end
    end

    it 'returns true for states that leave us' do
      %i[
        state_drive_shipped
        state_restore_order_shipped
        state_ibackup_upload_drive_shipped
      ].each do |name|
        expect(create(name).leaves_us?).to eq(true)
      end
    end
  end

  describe '#validate' do
    describe 'key' do
      it 'is optional (nil)' do
        expect(build(:state, key: nil)).to be_valid
      end

      it 'is optional (blank)' do
        expect(build(:state, key: '')).to be_valid
      end

      it 'looks like a key' do
        expect(build(:state, key: '#$%^&*')).not_to be_valid
      end

      it 'is <= 255 characters' do
        key = 'a' * 256
        expect(build(:state, key: key)).not_to be_valid
      end

      it 'is unique' do
        create(:state, key: 'dup_key')
        expect(build(:state, key: 'dup_key')).not_to be_valid
      end
    end

    describe 'label' do
      it 'is required (nil)' do
        expect(build(:state, label: nil)).not_to be_valid
      end

      it 'is required (blank)' do
        expect(build(:state, label: '')).not_to be_valid
      end

      it 'is <= 255 characters' do
        label = 'a' * 256
        expect(build(:state, label: label)).not_to be_valid
      end
    end

    describe 'percentage' do
      it 'is required (nil)' do
        expect(build(:state, percentage: nil)).not_to be_valid
      end

      it 'is required (blank)' do
        expect(build(:state, percentage: '')).not_to be_valid
      end

      it 'is >= 0' do
        expect(build(:state, percentage: -1)).not_to be_valid
      end

      it 'is <= 100' do
        expect(build(:state, percentage: 101)).not_to be_valid
      end

      it 'is an integer' do
        expect(build(:state, percentage: 50.1)).not_to be_valid
      end
    end
  end
end
