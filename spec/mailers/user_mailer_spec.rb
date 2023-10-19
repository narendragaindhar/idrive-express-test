require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  let(:to_user) { build_stubbed(:user, name: 'To To-er', email: 'to@user.com') }
  let(:from_user) { build_stubbed(:user, name: 'From From-er', email: 'from@user.com') }
  let(:order) { build_stubbed(:order_idrive_one) }
  let(:state) { build_stubbed(:state_idrive_one_account_verified) }
  let(:order_state) do
    build_stubbed(:order_state, order: order, state: state, user: from_user, comments: state.description)
  end

  describe '#notify_user_of_order_state' do
    let(:mail) { described_class.notify_user_of_order_state(to_user, order_state).deliver_now }

    it 'renders the subject' do
      expect(mail.subject).to eq("Notification update for order ##{order.id}: #{state.label}")
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq(['to@user.com'])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['noreply@idrive.com'])
    end

    it 'sets the reply to address as the sending user' do
      expect(mail.reply_to).to eq(['from@user.com'])
    end

    it 'assigns @user' do
      expect(mail.body.encoded).to match(to_user.name)
    end

    it 'renders a message about the update' do
      expect(mail.body.encoded).to match(
        "From From-er wanted to make you aware of a recent change to order ##{order.id}."
      )
      expect(mail.body.encoded).to match(state.label)
    end
  end

  describe '#reset_password_email' do
    let(:mail) do
      to_user.generate_reset_password_token!
      described_class.reset_password_email(to_user).deliver_now
    end

    it 'renders the subject' do
      expect(mail.subject).to eq('Reset your IDrive Express password')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq(['to@user.com'])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['noreply@idrive.com'])
    end

    it 'assigns @user' do
      expect(mail.body.encoded).to match(to_user.name)
    end

    it 'renders a link to the reset password' do
      expect(mail.body.encoded).to match(edit_password_url(to_user.reset_password_token))
    end
  end
end
