require_relative 'path_helper'

module SessionHelper
  include PathHelper

  def login(email, password)
    ensure_path(login_path)
    fill_in 'Email', with: email
    fill_in 'Password', with: password
    click_button 'Log in'
  end
end
