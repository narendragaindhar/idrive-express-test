require 'rails_helper'

RSpec.describe RolesController, type: :controller do
  let(:role_role_manager) { create(:role_role_manager) }
  let(:role_idrive_employee) { create(:role_idrive_employee) }
  let(:new_role) { create(:role, name: 'Sweet role', description: 'Amazing role', key: :cool_role) }
  let(:current_user) do
    user = create(:user)
    user.roles << role_role_manager
    user
  end
  let(:user) do
    user = create(:user)
    user.roles << role_idrive_employee
    user
  end

  before do
    login_user current_user
  end

  describe 'GET #edit' do
    let(:request) { get(:edit, params: { user_id: user.id }) }

    it 'is successful' do
      expect(response).to be_successful
    end

    it 'renders the edit template' do
      expect(request).to render_template(:edit)
    end

    it 'assigns @user' do
      request
      expect(assigns(:user)).to eq(user)
    end

    it 'assigns @roles' do
      request
      expect(assigns(:roles)).to eq([role_idrive_employee, role_role_manager])
    end

    it 'assigns @chosen_roles' do
      request
      expect(assigns(:chosen_roles)).to eq([role_idrive_employee])
    end
  end

  describe 'PATCH #update' do
    let(:data) do
      {
        user_id: user.id,
        user: {
          roles: [role_idrive_employee.id, new_role.id]
        }
      }
    end
    let(:request) { patch(:update, params: data) }

    context 'without proper permissions' do
      before do
        login_user create(:user)
      end

      it 'redirects to homepage' do
        expect(request).to redirect_to(root_path)
      end

      it 'sets an error message' do
        request
        expect(flash[:error]).to eq('You are not authorized to perform this action')
      end
    end

    context 'with invalid data' do
      let(:data) { { user_id: user.id } }

      it 'rejects empty POST data' do
        expect { request }.to raise_error ActionController::ParameterMissing
      end
    end

    context 'with valid data' do
      context 'when updating succeeds' do
        it 'redirects back to the user' do
          expect(request).to redirect_to user_path(user)
        end

        it 'shows a success message' do
          request
          expect(flash[:notice]).to eq('Roles updated successfully')
        end

        it 'changes the roles of the user' do
          expect do
            request
          end.to change { user.roles.count }.from(1).to(2)
        end
      end

      context 'when updating fails' do
        before do
          allow_any_instance_of(User).to receive(:roles=).and_raise(ActiveRecord::RecordNotSaved.new('not saved'))
        end

        it 'rerenders the edit form' do
          expect(request).to render_template :edit
        end

        it 'shows an error message' do
          request
          expect(flash[:error]).to eq('Role update failed')
        end
      end
    end
  end
end
