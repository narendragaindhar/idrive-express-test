require 'rails_helper'

RSpec.describe CustomerMailer, type: :mailer do
  let(:order_state) { build_stubbed(:order_state, order: order, state: state, comments: state.description) }
  let(:mail) { described_class.order_state_updated(order_state).deliver_now }

  describe '.rescue_from' do
    describe 'email errors' do
      let!(:order_state) { create(:order_state, is_public: true) }

      it 'sets :is_public to false' do
        expect_any_instance_of(Mail::Message).to receive(:deliver).and_raise(Net::SMTPServerBusy.new('Server busy'))
        perform_enqueued_jobs do
          described_class.order_state_updated(order_state).deliver_later
        end
        expect(order_state.reload.did_notify).to eq(false)
      end
    end
  end

  describe '#order_state_updated' do
    context 'with an idrive express upload order' do
      let(:order) { build_stubbed(:order_upload) }
      let(:state) { build_stubbed(:state_upload_started) }

      it 'renders the subject' do
        expect(mail.subject).to match(/Update for your IDrive Express Upload order \(#\d+\)/)
      end

      it 'renders the receiver email' do
        expect(mail.to).to eq([order.customer.email])
      end

      it 'renders the sender email' do
        expect(mail.from).to eq(['noreply@idrive.com'])
      end

      it 'assigns @customer' do
        expect(mail.body.encoded).to match(order.customer.name)
      end

      it 'renders a message about the update' do
        expect(mail.body.encoded).to match(/Your IDrive Express Upload order \(#\d+\) was updated/)
      end
    end

    context 'with an idrive one order' do
      let(:order) { build_stubbed(:order_idrive_one) }
      let(:state) { build_stubbed(:state_idrive_one_order_shipped) }

      it 'renders the subject' do
        expect(mail.subject).to match(/Update for your IDrive One order \(#\d+\)/)
      end

      it 'renders the receiver email' do
        expect(mail.to).to eq([order.customer.email])
      end

      it 'renders the sender email' do
        expect(mail.from).to eq(['noreply@idrive.com'])
      end

      it 'assigns @customer' do
        expect(mail.body.encoded).to match(order.customer.name)
      end

      it 'renders a message about the update' do
        expect(mail.body.encoded).to match(/Your IDrive One order \(#\d+\) was updated/)
      end
    end

    context 'with an ibackup express upload order' do
      let(:order) { build_stubbed(:order_ibackup_upload) }
      let(:state) { build_stubbed(:state_ibackup_upload_started) }

      it 'renders the subject' do
        expect(mail.subject).to match(/Update for your IBackup Express Upload order \(#\d+\)/)
      end

      it 'renders the receiver email' do
        expect(mail.to).to eq([order.customer.email])
      end

      it 'renders the sender email' do
        expect(mail.from).to eq(['noreply@ibackup.com'])
      end

      it 'assigns @customer' do
        expect(mail.body.encoded).to match(order.customer.name)
      end

      it 'renders a message about the update' do
        expect(mail.body.encoded).to match(/Your IBackup Express Upload order \(#\d+\) was updated/)
      end
    end
  end
end
