require 'rails_helper'
require 'support/features/path_helper'
require 'support/features/session_helper'

RSpec.describe 'Add new state to order', type: :feature do
  include SessionHelper

  let(:password) { 'my password' }
  let(:user) do
    u = create(:user, password: password)
    u.roles << create(:role_idrive_employee)
    u
  end
  let!(:order) { create(:order) }
  let!(:state_drive_shipped) { create(:state_drive_shipped) }

  context 'with valid state information' do
    it 'shows a success message' do
      login user.email, password
      ensure_path orders_path
      click_link "##{order.id}"
      select state_drive_shipped.label, from: 'What happened?'
      fill_in 'Comments', with: 'Your drive has been shipped! Your tracking '\
                                'number is ABCD1234. Please allow 2-3 days for delivery.'
      click_button 'Update'

      expect(page).to have_content 'Order state added successfully'
    end
  end

  context 'with invalid state information' do
    it 'shows an error message' do
      login user.email, password
      ensure_path orders_path
      click_link "##{order.id}"
      click_button 'Update'

      expect(page).to have_content 'Error updating order: State can\'t be blank'
    end
  end
end
