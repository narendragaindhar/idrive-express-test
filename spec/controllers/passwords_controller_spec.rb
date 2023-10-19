require 'rails_helper'

RSpec.describe PasswordsController, type: :controller do
  let(:password) { 'cool_pass' }
  let(:user_attrs) { attributes_for(:user, password: password) }
  let!(:user) { create(:user, user_attrs) }
  let(:token) do
    user.generate_reset_password_token!
    user.reset_password_token
  end

  describe 'GET #new' do
    let(:request) { get(:new) }

    it 'is successful' do
      expect(request).to be_successful
    end

    it 'assigns @user' do
      request
      expect(assigns(:user)).to be_a_new User
    end

    it 'renders the index template' do
      expect(request).to render_template(:new)
    end
  end

  describe 'POST #create' do
    let(:request) { post(:create, params: data) }

    context 'with invalid data' do
      let(:data) { { user: { email: 'nothereyo@user.com' } } }

      it 'rerenders the form if no user is found' do
        expect(request).to render_template :new
      end

      it 'shows an error if no user is found' do
        request
        expect(flash[:error]).to eq('No user was found with those details')
      end
    end

    context 'with valid data' do
      let(:data) { { user: { email: user_attrs[:email] } } }

      it 'generates a password reset token' do
        expect { request }.to change { user.reload.reset_password_token }.from(nil)
      end

      it 'redirects to login path' do
        expect(request).to redirect_to login_path
      end

      it 'shows instructions to the user' do
        request
        expect(flash[:notice]).to eq('Instructions have been sent to your email address.')
      end
    end
  end

  describe 'GET #edit' do
    let(:request) { get(:edit, params: data) }

    context 'with a bad token' do
      let(:data) { { id: 'dumbtoken' } }

      it 'redirects to the forgot password page' do
        expect(request).to redirect_to new_password_path
      end

      it 'shows a message to the user' do
        request
        expect(flash[:alert]).to eq('Could not find user with that reset link')
      end
    end

    context 'with a valid token' do
      let(:data) { { id: token } }

      it 'is successful' do
        expect(request).to be_successful
      end

      it 'shows the form' do
        expect(request).to render_template(:edit)
      end

      it 'assigns @token' do
        request
        expect(assigns[:token]).to eq(token)
      end

      it 'assigns @user' do
        request
        expect(assigns[:user]).to eq(user)
      end

      it 'shows instructions to the user' do
        get :edit, params: { id: token }
        expect(flash[:notice]).to eq('You can now reset your password')
      end
    end
  end

  describe 'PATCH #update' do
    let(:request) { patch(:update, params: data) }

    context 'with an invalid token' do
      let(:data) { { id: 'invalid' } }

      it 'redirects to the forgot password page' do
        expect(request).to redirect_to new_password_path
      end

      it 'shows an error message to the user' do
        request
        expect(flash[:alert]).to eq('Could not find user with that reset link')
      end
    end

    context 'with invalid password data' do
      let(:data) { { id: token, user: { password: 'newpass', password_confirmation: 'wrong' } } }

      it 'is not successful' do
        expect(request).to have_http_status(:unprocessable_entity)
      end

      it 'rerenders the form' do
        expect(request).to render_template(:edit)
      end

      it 'assigns @token' do
        request
        expect(assigns[:token]).to eq(token)
      end

      it 'assigns @user' do
        request
        expect(assigns[:user]).to eq(user)
      end

      it 'sets an error message' do
        request
        expect(flash[:error]).to eq('There was a problem resetting your password')
      end
    end

    context 'with valid password data' do
      let(:data) { { id: token, user: { password: 'newpass', password_confirmation: 'newpass' } } }

      it 'changes the password' do
        expect { request }.to(change { user.reload.crypted_password })
      end

      it 'redirects the user to the homepage' do
        expect(request).to redirect_to(root_path)
      end

      it 'assigns @token' do
        request
        expect(assigns[:token]).to eq(token)
      end

      it 'assigns @user' do
        request
        expect(assigns[:user]).to eq(user)
      end

      it 'alerts the user of the change' do
        request
        expect(flash[:notice]).to eq('Password was successfully updated and you have been logged in')
      end
    end
  end
end
