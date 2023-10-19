require 'rails_helper'

RSpec.describe DayCountsController, type: :controller do
  let(:user) do
    user = create(:user)
    user.roles << create(:role_idrive_employee)
    user
  end
  let(:order) { create(:order) }

  before do
    login_user user
  end

  describe 'GET #show' do
    let(:request) { get(:show, params: { order_id: order.id }, format: :json) }

    it 'is successful' do
      expect(request).to be_successful
    end

    it 'renders the show json' do
      expect(request).to render_template(:show)
    end

    it 'assigns @order' do
      request
      expect(assigns(:order)).to eq(order)
    end

    context 'without a day_count' do
      it 'creates a day_count' do
        request
        expect(assigns(:order).day_count).not_to be_nil
      end
    end
  end
end
