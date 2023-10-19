require 'rails_helper'

RSpec.describe API::V2::OrdersController, type: :controller do
  describe 'POST #create' do
    before do
      create(:destination_viawest_1)
      create(:destination_alchemy)
      create(:destination_office)
      create(:order_type_idrive_upload)
      create(:order_type_idrive_restore)
      create(:state_initial)
      create(:state_restore_initial)
      request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(
        ENV['API_TOKEN']
      )
    end

    context 'with missing data' do
      it 'rejects empty request body' do
        post :create
        assert_response :bad_request
      end

      it 'rejects empty json object' do
        post :create, params: {}
        assert_response :bad_request
      end

      it 'rejects missing nested customer object' do
        data = attributes_for(:api_v2_order)
        data[:order].delete :customer
        post :create, params: data
        assert_response :bad_request
      end

      it 'rejects missing nested destination object' do
        data = attributes_for(:api_v2_order)
        data[:order].delete :destination
        post :create, params: data
        assert_response :bad_request
      end

      it 'rejects missing nested order_type object' do
        data = attributes_for(:api_v2_order)
        data[:order].delete :express_kind
        post :create, params: data
        assert_response :bad_request
      end

      it 'rejects missing nested address object' do
        data = attributes_for(:api_v2_order)
        data[:order].delete :address
        post :create, params: data
        assert_response :bad_request
      end
    end

    context 'with invalid data' do
      it 'rejects invalid data' do
        post :create, params: attributes_for(:api_v2_order, max_size: -1, destination: { key: 'harblar' })
        assert_response :unprocessable_entity
      end
    end

    context 'with valid "upload" data' do
      it 'is successful' do
        post :create, params: attributes_for(:api_v2_order_upload)
        assert_response :created
      end

      it 'returns json data regarding the order' do
        post :create, params: attributes_for(:api_v2_order_upload)

        response_data = JSON.parse(response.body)
        expect(response_data).to have_key('id')
        expect(response_data).to have_key('comments')
        expect(response_data).to have_key('max_size')
        expect(response_data).to have_key('needs_review')
        expect(response_data).to have_key('os')
        expect(response_data).to have_key('address')
        expect(response_data['address']).to have_key('id')
        expect(response_data['address']).to have_key('recipient')
        expect(response_data['address']).to have_key('organization')
        expect(response_data['address']).to have_key('address')
        expect(response_data['address']).to have_key('city')
        expect(response_data['address']).to have_key('state')
        expect(response_data['address']).to have_key('zip')
        expect(response_data['address']).to have_key('country')
        expect(response_data).to have_key('customer')
        expect(response_data['customer']).to have_key('id')
        expect(response_data['customer']).to have_key('username')
        expect(response_data['customer']).to have_key('email')
        expect(response_data['customer']).to have_key('name')
        expect(response_data['customer']).to have_key('phone')
        expect(response_data['customer']).to have_key('server')
        expect(response_data['customer']).to have_key('priority')
        expect(response_data['customer']).to have_key('quota')
        expect(response_data).to have_key('destination')
        expect(response_data['destination']).to have_key('id')
        expect(response_data['destination']).to have_key('key')
        expect(response_data['destination']).to have_key('name')
        expect(response_data['destination']).to have_key('active')
        expect(response_data).to have_key('express_kind')
        expect(response_data['express_kind']).to have_key('id')
        expect(response_data['express_kind']).to have_key('key')
        expect(response_data['express_kind']).to have_key('name')
      end

      it 'is an "upload" kind of order' do
        post :create, params: attributes_for(:api_v2_order_upload)
        response_data = JSON.parse(response.body)
        expect(response_data['express_kind']['key']).to eq('upload')
      end

      it 'creates a new order' do
        expect do
          post :create, params: attributes_for(:api_v2_order_upload)
        end.to change(Order, :count).by(1)
      end

      it 'creates a new address' do
        expect do
          post :create, params: attributes_for(:api_v2_order_upload)
        end.to change(Address, :count).by(1)
      end

      it 'creates a new customer' do
        expect do
          post :create, params: attributes_for(:api_v2_order_upload)
        end.to change(Customer, :count).by(1)
      end

      it 'reuses existing customers with same username' do
        expect do
          post :create, params: attributes_for(:api_v2_order_upload, username: 'user_name')
          assert_response :created

          # needed due to how the controller tracks the customer params
          controller.instance_variable_set(:@customer_params, nil)

          post :create, params: attributes_for(:api_v2_order_upload, username: 'user_name')
          assert_response :created
        end.to change(Customer, :count).by(1)
      end
    end

    context 'with valid "restore" data' do
      it 'is successful' do
        post :create, params: attributes_for(:api_v2_order_restore)
        assert_response :created
      end

      it 'returns json data regarding the order' do
        post :create, params: attributes_for(:api_v2_order_restore)

        response_data = JSON.parse(response.body)
        expect(response_data).to have_key('id')
        expect(response_data).to have_key('comments')
        expect(response_data).to have_key('max_size')
        expect(response_data).to have_key('needs_review')
        expect(response_data).to have_key('os')
        expect(response_data).to have_key('address')
        expect(response_data['address']).to have_key('id')
        expect(response_data['address']).to have_key('recipient')
        expect(response_data['address']).to have_key('organization')
        expect(response_data['address']).to have_key('address')
        expect(response_data['address']).to have_key('city')
        expect(response_data['address']).to have_key('state')
        expect(response_data['address']).to have_key('zip')
        expect(response_data['address']).to have_key('country')
        expect(response_data).to have_key('customer')
        expect(response_data['customer']).to have_key('id')
        expect(response_data['customer']).to have_key('username')
        expect(response_data['customer']).to have_key('email')
        expect(response_data['customer']).to have_key('name')
        expect(response_data['customer']).to have_key('phone')
        expect(response_data['customer']).to have_key('server')
        expect(response_data['customer']).to have_key('priority')
        expect(response_data['customer']).to have_key('quota')
        expect(response_data).to have_key('destination')
        expect(response_data['destination']).to have_key('id')
        expect(response_data['destination']).to have_key('key')
        expect(response_data['destination']).to have_key('name')
        expect(response_data['destination']).to have_key('active')
        expect(response_data).to have_key('express_kind')
        expect(response_data['express_kind']).to have_key('id')
        expect(response_data['express_kind']).to have_key('key')
        expect(response_data['express_kind']).to have_key('name')
      end

      it 'is an "restore" kind of order' do
        post :create, params: attributes_for(:api_v2_order_restore)
        response_data = JSON.parse(response.body)
        expect(response_data['express_kind']['key']).to eq('restore')
      end

      it 'creates a new order' do
        expect do
          post :create, params: attributes_for(:api_v2_order_restore)
        end.to change(Order, :count).by(1)
      end

      it 'creates a new address' do
        expect do
          post :create, params: attributes_for(:api_v2_order_restore)
        end.to change(Address, :count).by(1)
      end

      it 'creates a new customer' do
        expect do
          post :create, params: attributes_for(:api_v2_order_restore)
        end.to change(Customer, :count).by(1)
      end

      it 'reuses existing customers with same username' do
        expect do
          post :create, params: attributes_for(:api_v2_order_restore, username: 'user_name')
          assert_response :created

          # needed due to how the controller tracks the customer params
          controller.instance_variable_set(:@customer_params, nil)

          post :create, params: attributes_for(:api_v2_order_restore, username: 'user_name')
          assert_response :created
        end.to change(Customer, :count).by(1)
      end
    end
  end
end
