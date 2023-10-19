require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) do
    user = create(:user, name: 'Tim')
    user.roles << create(:role_idrive_employee)
    user
  end
  let(:user2) { create(:user, name: 'Dave') }

  before do
    login_user user
  end

  describe 'POST #create' do
    let(:request) { post(:create, params: data) }

    context 'without an order' do
      context 'with invalid data' do
        let(:data) do
          attrs = attributes_for(:user)
          attrs.delete(:email)
          attrs.delete(:password)
          { user: attrs }
        end

        it 'is not successful' do
          expect(request).to have_http_status(:unprocessable_entity)
        end

        it 'renders the new template' do
          expect(request).to render_template(:new)
        end

        it 'shows a message to the user' do
          request
          expect(flash.now[:error]).to eq('User could not be created')
        end
      end

      context 'with valid data' do
        let(:data) do
          attrs = attributes_for(:user)
          attrs.delete(:password)
          { user: attrs }
        end

        it 'is creates a new user' do
          expect { request }.to change(User, :count).by(1)
        end

        it 'redirects to the newly created user' do
          expect(request).to redirect_to user_path User.last
        end

        it 'shows a message to the user' do
          request
          expect(flash[:notice]).to include('User was successfully created.')
        end

        context 'when user is a role manager' do
          let(:user) do
            u = create(:user)
            u.roles = [create(:role_idrive_employee), create(:role_role_manager)]
            u
          end

          it 'shows a message regarding adding roles' do
            request
            expect(flash[:notice]).to include(
              'New users have no roles and cannot perform many actions on the '\
              'site. Make sure you grant this user some roles before they use the site'
            )
          end
        end
      end
    end

    context 'with an order' do
      let(:order) { create(:order) }
      let(:user2) { create(:user, name: 'Joey Joe') }
      let(:data) { { order_id: order.id, user: { id: user2.id } } }

      it 'redirects back to the order' do
        expect(request).to redirect_to(order_path(order))
      end

      it 'adds the user to the watchlist' do
        request
        expect(order.reload.users).to eq([user2])
      end

      it 'shows a message to the user' do
        request
        expect(flash[:notice]).to eq('Joey Joe added to watchlist')
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:order) do
      order = create(:order)
      order.add_user_to_watchlist user2
      order
    end
    let(:data) { { order_id: order.id, id: user2.id } }
    let(:request) { delete(:destroy, params: data) }

    context 'with an order' do
      it 'redirects back to the order' do
        expect(request).to redirect_to(order_path(order))
      end

      it 'removes the user from the watchlist' do
        request
        expect(order.users.reload).to eq([])
      end
    end

    context 'without an order' do
      let(:data) { { id: user.id } }

      it 'is not allowed' do
        expect { request }.to raise_error ActionController::UrlGenerationError
      end
    end
  end

  describe 'GET #edit' do
    let(:request) { get(:edit, params: data) }

    context 'when a different user' do
      let(:data) { { id: user2.id } }

      it 'is not authorized' do
        expect(request).to redirect_to root_path
      end
    end

    context 'when the same user' do
      let(:data) { { id: user.id } }

      it 'is successful' do
        expect(request).to be_successful
      end

      it 'renders the edit template' do
        expect(request).to render_template(:edit)
      end
    end
  end

  describe 'GET #index' do
    let(:request) { get(:index) }

    it 'is successful' do
      expect(request).to be_successful
    end

    it 'renders the index template' do
      expect(request).to render_template(:index)
    end

    it 'assigns @users' do
      users = [user2, user]
      request
      expect(assigns[:users]).to eq(users)
    end

    it 'assigns @user' do
      request
      expect(assigns[:user]).to be_a_new(User)
    end
  end

  describe 'GET #new' do
    let(:request) { get(:new) }

    it 'is successful' do
      expect(request).to be_successful
    end

    it 'renders the index template' do
      expect(request).to render_template(:new)
    end

    it 'assigns @user' do
      request
      expect(assigns[:user]).to be_a_new(User)
    end
  end

  describe 'GET #show' do
    let(:request) { get(:show, params: { id: user2.id }) }

    it 'is successful' do
      expect(request).to be_successful
    end

    it 'renders the index template' do
      expect(request).to render_template(:show)
    end

    it 'assigns @user' do
      request
      expect(assigns[:user]).to eq(user2)
    end
  end

  describe 'PATCH #update' do
    let(:user_params) do
      {
        id: user.id,
        user: {
          email: user.email,
          name: user.name,
          password: '',
          password_confirmation: ''
        }
      }
    end

    context 'with invalid data' do
      let(:invalid_data) do
        data = user_params
        data[:user][:email] = 'no'
        data
      end

      it 'is not successful' do
        expect(patch(:update, params: invalid_data)).to have_http_status(:unprocessable_entity)
      end

      it 'rerenders the form' do
        expect(patch(:update, params: invalid_data)).to render_template(:edit)
      end

      it 'shows a message to the user' do
        patch :update, params: invalid_data
        expect(flash.now[:error]).to eq('Profile could not be updated')
      end

      it 'does not update password without confirmation' do
        data = user_params
        data[:user][:password] = 'new password'
        data[:user][:password_confirmation] = ''
        expect(patch(:update, params: data)).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with unchanged data' do
      it 'redirects back to user' do
        expect(patch(:update, params: user_params)).to redirect_to(user_path(user))
      end

      it 'shows a message to the user' do
        patch :update, params: user_params
        expect(flash[:notice]).to eq('Profile updated successfully')
      end
    end

    context 'with valid data' do
      context 'when a different user' do
        it 'is not authorized' do
          data = user_params
          data[:id] = user2.id
          expect(patch(:update, params: data)).to redirect_to root_path
        end
      end

      context 'when the same user' do
        it 'redirects back to user' do
          data = user_params
          data[:user][:email] = 'new@email.com'
          expect(patch(:update, params: data)).to redirect_to(user_path(user))
        end

        it 'shows a message to the user' do
          data = user_params
          data[:user][:email] = 'new@email.com'
          patch :update, params: data

          expect(flash[:notice]).to eq('Profile updated successfully')
        end

        it "can update the user's email" do
          data = user_params
          data[:user][:email] = 'new@email.com'
          patch :update, params: data

          expect(user.reload.email).to eq('new@email.com')
        end

        it "can update the user's name" do
          data = user_params
          data[:user][:name] = 'New Name'
          patch :update, params: data

          expect(user.reload.name).to eq('New Name')
        end

        it "can update the user's password" do
          old_password = user.crypted_password
          data = user_params
          data[:user][:password] = 'new password'
          data[:user][:password_confirmation] = 'new password'
          patch :update, params: data

          expect(user.reload.crypted_password).not_to eq(old_password)
        end
      end
    end
  end

  describe 'PATCH #disable' do
    context 'when disabling the user' do
      let(:user_disabling_params) do
        {
          id: user.id,
          user: {
            disabled_at: '1',
            disabled_reason: 'Some reason'
          }
        }
      end

      it 'is successful' do
        patch :disable, params: user_disabling_params
        user.reload
        expect(user.disabled_at).not_to be_nil
        expect(user.disabled_reason).to eq('Some reason')
      end

      it 'redirects back to user' do
        expect(patch(:disable, params: user_disabling_params)).to redirect_to(user_path(user))
      end
    end

    context 'when enabling the user' do
      let(:user_enabling_params) do
        {
          id: user.id,
          user: {
            disabled_at: '1'
          }
        }
      end

      before do
        user.update(disabled_at: Time.now, disabled_reason: 'Some reason')
      end

      it 'is successful' do
        patch :disable, params: user_enabling_params
        user.reload
        expect(user.disabled_at).to be_nil
        expect(user.disabled_reason).to be_nil
      end

      it 'redirects back to user' do
        expect(patch(:disable, params: user_enabling_params)).to redirect_to(user_path(user))
      end
    end
  end
end
