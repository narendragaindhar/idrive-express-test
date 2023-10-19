require 'rails_helper'

RSpec.shared_examples 'successful API v4 requests' do |name, factory_name, order_type_key|
  let(:params) { attributes_for(factory_name) }
  let(:api_request) { post :create, params: params }

  context "with valid #{name} data" do
    it 'is successful' do
      expect(api_request).to have_http_status(:created)
    end

    it 'returns json data regarding the order' do
      response_data = JSON.parse(api_request.body)

      expect(response_data).to have_key('id')
      expect(response_data).to have_key('comments')
      expect(response_data).to have_key('size')
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
      expect(response_data).to have_key('order_type')
      expect(response_data['order_type']).to have_key('id')
      expect(response_data['order_type']).to have_key('key')
      expect(response_data['order_type']).to have_key('name')
    end

    it "has an order type of #{name}" do
      response_data = JSON.parse(api_request.body)
      expect(response_data['order_type']['key']).to eq(order_type_key)
    end

    it 'creates a new order' do
      expect { api_request }.to change(Order, :count).by(1)
    end

    it 'creates a new address' do
      expect { api_request }.to change(Address, :count).by(1)
    end

    it 'creates a new customer' do
      expect { api_request }.to change(Customer, :count).by(1)
    end

    context 'with multiple requests from the same customer' do
      let(:params) { attributes_for(factory_name, username: 'user_name') }

      it 'reuses existing records' do
        expect do
          expect(api_request).to have_http_status(:created)

          # needed due to how the controller tracks the customer params
          controller.instance_variable_set(:@customer_params, nil)

          expect(api_request).to have_http_status(:created)
        end.to change(Customer, :count).by(1)
      end
    end
  end
end

RSpec.describe API::V4::OrdersController, type: :controller do
  describe 'POST #create' do
    before do
      create(:destination_viawest_1)
      create(:destination_alchemy)
      create(:destination_office)
      create(:destination_iron_mountain)
      create(:destination_viatel)
      create(:order_type_idrive_upload)
      create(:order_type_idrive_restore)
      create(:order_type_idrive_one)
      create(:order_type_idrive_bmr)
      create(:order_type_idrive_bmr_upload)
      create(:order_type_idrive_bmr_restore)
      create(:order_type_idrive360_upload)
      create(:order_type_idrive360_restore)
      create(:order_type_ibackup_upload)
      create(:order_type_ibackup_restore)
      create(:state_initial)
      create(:state_restore_initial)
      create(:state_idrive_one_initial)
      create(:state_idrive_bmr_order_created)
      create(:state_idrive_bmr_upload_order_created)
      create(:state_idrive_bmr_restore_order_created)
      create(:state_idrive360_upload_order_created)
      create(:state_idrive360_restore_order_created)
      create(:state_ibackup_upload_initial)
      create(:state_ibackup_restore_initial)
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
        data = attributes_for(:api_v4_order)
        data[:order].delete :customer
        post :create, params: data
        assert_response :bad_request
      end

      it 'rejects missing nested destination object' do
        data = attributes_for(:api_v4_order)
        data[:order].delete :destination
        post :create, params: data
        assert_response :bad_request
      end

      it 'rejects missing nested order_type object' do
        data = attributes_for(:api_v4_order)
        data[:order].delete :order_type
        post :create, params: data
        assert_response :bad_request
      end

      it 'rejects missing nested address object' do
        data = attributes_for(:api_v4_order)
        data[:order].delete :address
        post :create, params: data
        assert_response :bad_request
      end
    end

    context 'with invalid data' do
      it 'rejects invalid data' do
        post :create, params: attributes_for(:api_v4_order, size: -1, destination: { key: 'harblar' })
        assert_response :unprocessable_entity
      end
    end

    it_behaves_like 'successful API v4 requests', 'IDrive upload',
                    :api_v4_order_idrive_upload, 'idrive_upload'
    it_behaves_like 'successful API v4 requests', 'IDrive restore',
                    :api_v4_order_idrive_restore, 'idrive_restore'
    it_behaves_like 'successful API v4 requests', 'IDrive One',
                    :api_v4_order_idrive_one, 'idrive_one'
    it_behaves_like 'successful API v4 requests', 'IDrive BMR',
                    :api_v4_order_idrive_bmr, 'idrive_bmr'
    it_behaves_like 'successful API v4 requests', 'IDrive BMR upload',
                    :api_v4_order_idrive_bmr_upload, 'idrive_bmr_upload'
    it_behaves_like 'successful API v4 requests', 'IDrive BMR restore',
                    :api_v4_order_idrive_bmr_restore, 'idrive_bmr_restore'
    it_behaves_like 'successful API v4 requests', 'IDrive360 upload',
                    :api_v4_order_idrive360_upload, 'idrive360_upload'
    it_behaves_like 'successful API v4 requests', 'IDrive360 restore',
                    :api_v4_order_idrive360_restore, 'idrive360_restore'
    it_behaves_like 'successful API v4 requests', 'IBackup upload',
                    :api_v4_order_ibackup_upload, 'ibackup_upload'
    it_behaves_like 'successful API v4 requests', 'IBackup restore',
                    :api_v4_order_ibackup_restore, 'ibackup_restore'
  end
end
