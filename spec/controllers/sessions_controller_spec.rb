require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:password) { 'cool_pass' }
  let(:user_attrs) { attributes_for(:user, password: password) }
  let(:login_attrs) { { user: { email: user_attrs[:email], password: password } } }
  let(:user) { create(:user, user_attrs) }

  context 'when user is logged out' do
    describe 'GET #new' do
      it 'is successful' do
        get :new
        expect(response).to be_successful
        expect(response).to render_template 'sessions/new'
      end
    end

    describe 'POST #create' do
      before do
        user
      end

      it 'logs the user in with valid credentials' do
        post :create, params: login_attrs
        expect(controller.logged_in?).to be true
        expect(response).to redirect_to root_path
      end

      it 'rerenders the login form with invalid credentials' do
        data = login_attrs
        data[:user][:password] = 'not right'
        post :create, params: data

        expect(response).to be_successful
        expect(response).to render_template 'sessions/new'
      end

      it 'does not allow disabled user to log in' do
        user.update(disabled_at: Time.now)
        user.reload
        post :create, params: login_attrs

        expect(controller.logged_in?).to be false
        expect(flash[:error]).to eq('Your account has been deactivated, and login is no longer possible.')
        expect(response).to render_template 'sessions/new'
      end
    end
  end

  context 'when user is logged in' do
    before do
      login_user user
    end

    describe 'DELETE #destroy' do
      it 'logs the user out' do
        get :destroy
        expect(response).to redirect_to login_path
      end
    end
  end
end
