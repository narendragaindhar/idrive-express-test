require 'rails_helper'

RSpec.describe OrderState do
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TimeHelpers

  describe '.after_create' do
    describe '#notify_customer' do
      it 'is not called if :did_notify is false' do
        expect_any_instance_of(Order).to receive(:set_initial_state)
        expect(CustomerMailer).not_to receive(:order_state_updated)
        create(:order_state, did_notify: false)
      end

      it 'is called if :did_notify is true' do
        expect_any_instance_of(Order).to receive(:set_initial_state)
        expect(CustomerMailer).to receive(:order_state_updated).and_call_original
        create(:order_state, did_notify: true)
      end

      it 'queues an email for delivery' do
        expect_any_instance_of(Order).to receive(:set_initial_state)
        expect do
          create(:order_state, did_notify: true)
        end.to have_enqueued_job.on_queue('mailers')
      end
    end

    describe '#notify_user' do
      let(:user) { create(:user) }

      it 'is not called if :notify_user_id is nil' do
        expect(UserMailer).not_to receive(:notify_user_of_order_state)
        create(:order_state, notify_user_id: nil)
      end

      it 'is called if :notify_user_id is present' do
        expect(UserMailer).to receive(:notify_user_of_order_state).and_call_original
        create(:order_state, notify_user_id: user.id)
      end

      it 'queues an email for delivery' do
        expect_any_instance_of(Order).to receive(:set_initial_state)
        expect do
          create(:order_state, notify_user_id: user.id)
        end.to have_enqueued_job.on_queue('mailers')
      end
    end

    describe '#update_api' do
      it 'is not called if :is_public is false' do
        expect_any_instance_of(Order).to receive(:set_initial_state)
        expect(UpdateAPIJob).not_to receive(:perform_later)
        create(:order_state, is_public: false)
      end

      it 'is called if :is_public is true' do
        expect_any_instance_of(Order).to receive(:set_initial_state)
        expect(UpdateAPIJob).to receive(:perform_later)
        create(:order_state, is_public: true)
      end

      it 'queues the job' do
        expect_any_instance_of(Order).to receive(:set_initial_state)
        expect do
          create(:order_state, is_public: true)
        end.to have_enqueued_job
      end
    end
  end

  describe '.latest_for_date' do
    let(:today) { Time.zone.now.middle_of_day }
    let(:yesterday) { today.yesterday.middle_of_day }
    let(:tomorrow) { today.tomorrow.middle_of_day }

    let(:state_shipping_fee) { create(:state_international_shipping_fee) }
    let(:state_on_hold_pre_shipped) { create(:state_on_hold_pre_shipped) }
    let(:state_drive_shipped) { create(:state_drive_shipped) }
    let(:state_drive_arrived_at_datacenter) { create(:state_drive_arrived_at_datacenter) }
    let(:state_upload_started) { create(:state_upload_started) }
    let(:state_upload_completed) { create(:state_upload_completed) }

    it 'returns the last state that happened on a given date' do
      order = nil
      os1 = nil
      os2 = nil
      os3 = nil
      travel_to yesterday do
        order = create(:order)
        order.order_states << create(:order_state, order: order, state: state_shipping_fee)
        order.order_states << create(:order_state, order: order, state: state_on_hold_pre_shipped)
        os1 = create(:order_state, order: order, state: state_drive_shipped)
        order.order_states << os1
      end
      travel_to today do
        os2 = create(:order_state, order: order, state: state_drive_arrived_at_datacenter)
        order.order_states << os2
      end
      travel_to tomorrow do
        order.order_states << create(:order_state, order: order, state: state_upload_started)
        os3 = create(:order_state, order: order, state: state_upload_completed)
        order.order_states << os3
      end
      expect(described_class.latest_for_date(order, yesterday.to_date)).to eq(os1)
      expect(described_class.latest_for_date(order, today.to_date)).to eq(os2)
      expect(described_class.latest_for_date(order, tomorrow.to_date)).to eq(os3)
    end

    it 'returns the latest state if no state happened on a given date' do
      order = nil
      order_state = nil
      travel_to yesterday do
        order = create(:order)
        order.order_states << create(:order_state, order: order, state: state_shipping_fee)
        order.order_states << create(:order_state, order: order, state: state_on_hold_pre_shipped)
        order_state = create(:order_state, order: order, state: state_drive_shipped)
        order.order_states << order_state
      end
      expect(described_class.latest_for_date(order, today.to_date)).to eq(order_state)
    end
  end

  describe '#private?' do
    it 'returns false if anything public happend during it' do
      state = create(:state_drive_shipped)
      [
        { is_public: true, did_notify: false },
        { is_public: false, did_notify: true },
        { is_public: true, did_notify: true }
      ].each do |attrs|
        order_state = create(:order_state, state: state, **attrs)
        expect(order_state.private?).to eq(false)
      end
    end

    it 'returns true if nothing public happend during it' do
      order_state = create(:order_state, state: create(:state_drive_shipped), is_public: false, did_notify: false)
      expect(order_state.private?).to eq(true)
    end
  end

  describe '#complete_order' do
    it 'does not complete orders when the state is not 100%' do
      order_state = create(:order_state, state: create(:state_drive_shipped))
      expect(order_state.order.completed_at).to eq(nil)
    end

    it 'completes orders when the state is 100%' do
      order_state = create(:order_state, state: create(:state_upload_completed))
      expect(order_state.order.completed_at).not_to eq(nil)
    end

    context 'with idrive upload order' do
      let(:order) { create(:order_with_drive) }

      it 'sets order.drive.in_use back to false' do
        expect(order.drive.in_use).to eq(true)
        create(:order_state, order: order, state: create(:state_upload_completed))
        expect(order.drive.in_use).to eq(false)
      end
    end

    context 'with idrive restore order' do
      let(:order) { create(:order_restore_with_drive) }

      it 'sets order.drive.in_use back to false' do
        expect(order.drive.in_use).to eq(true)
        create(:order_state, order: order, state: create(:state_restore_completed))
        expect(order.drive.in_use).to eq(false)
      end
    end

    context 'with idrive ones order' do
      let(:order) { create(:order_idrive_one_with_drive) }

      it 'does not set order.drive.in_use to false because the drive does not come back to us' do
        expect(order.drive.in_use).to eq(true)
        create(:order_state, order: order, state: create(:state_idrive_one_order_shipped))
        expect(order.drive.in_use).to eq(true)
      end
    end

    context 'with idrive bmr order' do
      let(:order) { create(:order_idrive_bmr_with_drive) }

      it 'does not set order.drive.in_use to false because the drive does not come back to us' do
        expect do
          create(:order_state, order: order, state: create(:state_idrive_bmr_order_shipped))
        end.not_to change { order.drive.in_use }.from(true)
      end
    end

    context 'with ibackup upload order' do
      let(:order) { create(:order_ibackup_upload_with_drive) }

      it 'sets order.drive.in_use back to false' do
        expect(order.drive.in_use).to eq(true)
        create(:order_state, order: order, state: create(:state_upload_completed))
        expect(order.drive.in_use).to eq(false)
      end
    end

    context 'with ibackup restore order' do
      let(:order) { create(:order_ibackup_restore_with_drive) }

      it 'sets order.drive.in_use back to false' do
        expect(order.drive.in_use).to eq(true)
        create(:order_state, order: order, state: create(:state_ibackup_restore_completed))
        expect(order.drive.in_use).to eq(false)
      end
    end
  end

  describe '#validate' do
    describe 'order' do
      it 'is required (nil)' do
        expect(build(:order_state, order: nil)).not_to be_valid
      end
    end

    describe 'state' do
      it 'is required (nil)' do
        expect(build(:order_state, state: nil)).not_to be_valid
      end
    end

    describe 'user' do
      it 'is optional' do
        expect(build(:order_state, user: nil)).to be_valid
      end
    end
  end

  describe '#reopen_completed_order' do
    context 'with idrive restore order' do
      let(:order) { create(:order_restore_with_drive) }

      it 'set order.completed_at back to nil' do
        create(:order_state, order: order, state: create(:state_restore_completed))
        expect(order.completed_at).not_to eq(nil)
        create(:order_state, order: order, state: create(:state_restore_drive_return_delayed))
        expect(order.reload.completed_at).to eq(nil)
      end

      it 'sets order.drive.in_use back to true' do
        create(:order_state, order: order, state: create(:state_restore_completed))
        expect(order.drive.in_use).to eq(false)
        create(:order_state, order: order, state: create(:state_restore_drive_return_delayed))
        expect(order.drive.in_use).to eq(true)
      end
    end

    context 'with idrive upload order' do
      let(:order) { create(:order_with_drive) }

      it 'set order.completed_at back to nil' do
        create(:order_state, order: order, state: create(:state_upload_completed))
        expect(order.completed_at).not_to eq(nil)
        create(:order_state, order: order, state: create(:state_drive_return_delayed))
        expect(order.reload.completed_at).to eq(nil)
      end

      it 'sets order.drive.in_use back to true' do
        create(:order_state, order: order, state: create(:state_upload_completed))
        expect(order.drive.in_use).to eq(false)
        create(:order_state, order: order, state: create(:state_drive_return_delayed))
        expect(order.drive.in_use).to eq(true)
      end
    end

    context 'with idrive ones order' do
      let(:order) { create(:order_idrive_one_with_drive) }

      it 'set order.completed_at back to nil' do
        create(:order_state, order: order, state: create(:state_idrive_one_order_shipped))
        expect(order.completed_at).not_to eq(nil)
        create(:order_state, order: order, state: create(:state_idrive_one_status_update))
        expect(order.reload.completed_at).to eq(nil)
      end
    end

    context 'with idrive bmr order' do
      let(:order) { create(:order_idrive_bmr_with_drive) }

      it 'set order.completed_at back to nil' do
        create(:order_state, order: order, state: create(:state_idrive_one_order_shipped))
        expect(order.completed_at).not_to eq(nil)
        create(:order_state, order: order, state: create(:state_idrive_one_status_update))
        expect(order.reload.completed_at).to eq(nil)
      end
    end

    context 'with ibackup upload order' do
      let(:order) { create(:order_ibackup_upload_with_drive) }

      it 'set order.completed_at back to nil' do
        create(:order_state, order: order, state: create(:state_ibackup_upload_completed))
        expect(order.completed_at).not_to eq(nil)
        create(:order_state, order: order, state: create(:state_ibackup_upload_drive_return_delayed))
        expect(order.reload.completed_at).to eq(nil)
      end

      it 'sets order.drive.in_use back to true' do
        create(:order_state, order: order, state: create(:state_ibackup_upload_completed))
        expect(order.drive.in_use).to eq(false)
        create(:order_state, order: order, state: create(:state_ibackup_upload_drive_return_delayed))
        expect(order.drive.in_use).to eq(true)
      end
    end

    context 'with ibackup restore order' do
      let(:order) { create(:order_ibackup_restore_with_drive) }

      it 'set order.completed_at back to nil' do
        create(:order_state, order: order, state: create(:state_ibackup_restore_completed))
        expect(order.completed_at).not_to eq(nil)
        create(:order_state, order: order, state: create(:state_ibackup_restore_drive_return_delayed))
        expect(order.reload.completed_at).to eq(nil)
      end

      it 'sets order.drive.in_use back to true' do
        create(:order_state, order: order, state: create(:state_ibackup_restore_completed))
        expect(order.drive.in_use).to eq(false)
        create(:order_state, order: order, state: create(:state_ibackup_restore_drive_return_delayed))
        expect(order.drive.in_use).to eq(true)
      end
    end
  end
end
