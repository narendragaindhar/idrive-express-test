require 'rails_helper'

RSpec.describe 'User login', type: :feature do
  let(:password) { 'my password' }
  let(:user) { create(:user, password: password) }

  context 'with valid credentials' do
    it 'shows a message' do
      visit login_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: password
      click_button 'Log in'

      expect(page).to have_content 'Logged in successfully'
    end
  end

  context 'with invalid credentials' do
    it 'shows an error message' do
      visit login_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: 'this is wrong'
      click_button 'Log in'

      expect(page).to have_content 'Email or password was invalid'
    end
  end
end
