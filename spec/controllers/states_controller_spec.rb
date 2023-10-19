require 'rails_helper'

RSpec.describe StatesController, type: :controller do
  let(:user) do
    user = create(:user)
    user.roles << create(:role_idrive_employee)
    user
  end
  let!(:order) { create(:order) }
  let(:state) { create(:state) }

  before do
    login_user user
  end

  describe 'POST #create' do
    let(:request) { post(:create, params: data) }

    context 'with invalid data' do
      let(:data) do
        attrs = attributes_for(:order_state)
        {
          order_id: order.id,
          order_state: {
            did_notify: attrs[:did_notify],
            is_public: attrs[:is_public]
          }
        }
      end

      it 'is not successful' do
        expect(request).to have_http_status(:unprocessable_entity)
      end

      it 'renders the new template' do
        expect(request).to render_template(:new)
      end

      it 'shows the user a message' do
        request
        expect(flash[:error]).to match(/Error updating order: /)
      end
    end

    context 'with valid data' do
      let(:data) do
        attrs = attributes_for(:order_state)
        {
          order_id: order.id,
          order_state: {
            state_id: state.id,
            comments: attrs[:comments],
            did_notify: attrs[:did_notify],
            is_public: attrs[:is_public]
          }
        }
      end

      it 'creates a new order_state' do
        expect { request }.to change(OrderState, :count).by(1)
      end

      it 'adds a new order_state to the order' do
        expect { request }.to change(order.order_states, :count).by(1)
      end

      it 'redirects back to order' do
        expect(request).to redirect_to order_path order
      end

      it 'shows the user a message' do
        request
        expect(flash[:notice]).to eq('Order state added successfully')
      end

      it 'is associated with the user who added the order_state' do
        request
        expect(assigns[:order_state].user).to eq(user)
      end
    end
  end
end
