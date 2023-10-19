require 'rails_helper'

RSpec.describe 'customer_mailer/order_state_updated.text.haml', type: :view do
  let(:customer) { create(:customer, name: 'Анисимов Альберт Эдуардович') }
  let(:order) { create(:order_upload, customer: customer) }
  let(:state) { create(:state_upload_completed) }
  let(:order_state) { create(:order_state, order: order, state: state, comments: state.description) }

  before do
    assign(:customer, customer)
    assign(:order_state, order_state)
    assign(:order, order_state.order)
    assign(:state, order_state.state)
    render
  end

  it 'greets the customer by name' do
    expect(rendered).to match('Hello Анисимов Альберт Эдуардович,')
  end

  it 'shows the upload order type' do
    expect(rendered).to include("Your IDrive Express Upload order (##{order.id}) was updated")
  end

  it 'shows the comments' do
    expect(rendered).to match('Your IDrive Express order is complete. You can now access your data in your account!')
  end

  context 'with a restore order' do
    let(:order) { create(:order_restore, customer: customer) }
    let(:state) { create(:state_restore_order_shipped) }
    let(:order_state) do
      create(:order_state, order: order, state: state,
                           comments: 'A drive containing a copy of your data has '\
                                     'been shipped to you! Your tracking number '\
                                     'is 1234567890. Please allow 2-3 days for delivery.')
    end

    it 'shows the restore order type' do
      expect(rendered).to include("Your IDrive Express Restore order (##{order.id}) was updated")
    end
  end

  context 'with an idrive one order' do
    let(:order) { create(:order_idrive_one, customer: customer) }
    let(:state) { create(:state_idrive_one_assembled) }
    let(:order_state) { create(:order_state, order: order, state: state, comments: state.description) }

    it 'shows the restore order type' do
      expect(rendered).to include("Your IDrive One order (##{order.id}) was updated")
    end
  end

  context 'with an ibackup express upload order' do
    let(:order) { create(:order_ibackup_upload, customer: customer) }
    let(:state) { create(:state_ibackup_upload_drive_arrived_at_datacenter) }
    let(:order_state) { create(:order_state, order: order, state: state, comments: state.description) }

    it 'shows the ibackup upload type' do
      expect(rendered).to include("Your IBackup Express Upload order (##{order.id}) was updated")
    end
  end

  context 'with an ibackup express restore order' do
    let(:order) { create(:order_ibackup_restore, customer: customer) }
    let(:state) { create(:state_ibackup_restore_drive_return_delayed) }
    let(:order_state) { create(:order_state, order: order, state: state, comments: state.description) }

    it 'shows the ibackup restore type' do
      expect(rendered).to include("Your IBackup Express Restore order (##{order.id}) was updated")
    end
  end
end
