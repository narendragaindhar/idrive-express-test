require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
  let(:user) do
    user = create(:user)
    user.roles << create(:role_idrive_employee)
    user
  end
  let(:customer) { create(:customer) }
  let(:destination) { create(:destination_viawest_1) }
  let(:order) { create(:order) }
  let(:drive) { create(:drive) }
  let(:order_type) { create(:order_type) }
  let(:available_drives) do
    drive1 = create(:drive, in_use: true)
    drive2 = create(:drive, identification_number: 'HIJKLMN')
    drive3 = create(:drive, identification_number: 'ABCDEFG')
    create(:drive, active: false)
    [drive3, drive2, drive1]
  end

  before do
    login_user user
  end

  describe 'POST #create' do
    let(:state_initial) { create(:state_initial) }
    let(:request) { post(:create, params: data) }

    context 'with invalid data' do
      let(:data) do
        {
          order: {
            customer_id: customer.id
          },
          drive: {
            identification_number: ''
          }
        }
      end

      it 'is not successful' do
        expect(request).to have_http_status(:unprocessable_entity)
      end

      it 'rerenders new template' do
        expect(request).to render_template(:new)
      end

      it 'assigns @order' do
        request
        expect(assigns[:order]).to be_a_new(Order)
      end

      it 'assigns @drive' do
        request
        expect(assigns[:drive]).to be_a_new(Drive)
      end

      it 'shows the user a message' do
        request
        expect(flash[:alert]).to match(/Error creating Order /)
      end
    end

    context 'with valid data' do
      let(:data) do
        {
          order: {
            customer_id: customer.id,
            destination_id: destination.id,
            drive_id: drive.id,
            order_type_id: state_initial.order_type.id,
            needs_review: false,
            size_count: 1,
            size_units: 'TB',
            os: 'Windows',
            address_attributes: attributes_for(:address)
          },
          drive: {
            identification_number: '',
            serial: '',
            size_count: '',
            size_label: ''
          }
        }
      end

      it 'creates a new order' do
        expect { request }.to change(Order, :count).by(1)
      end

      it 'redirects to new order' do
        expect(request).to redirect_to order_path assigns[:order]
      end

      it 'shows the user a message' do
        request
        expect(flash[:notice]).to eq("Order ##{Order.last.id} created successfully")
      end

      context 'without a drive' do
        let(:data) do
          {
            order: {
              customer_id: customer.id,
              destination_id: destination.id,
              drive_id: nil,
              order_type_id: state_initial.order_type.id,
              needs_review: false,
              size_count: 1,
              size_units: 'TB',
              os: 'Windows',
              address_attributes: attributes_for(:address)
            },
            drive: {
              identification_number: '',
              serial: '',
              size_count: '',
              size_label: ''
            }
          }
        end

        it 'creates a new order' do
          expect { request }.to change(Order, :count).by(1)
        end

        it 'redirects to new order' do
          expect(request).to redirect_to order_path assigns[:order]
        end

        it 'does not have a drive associated with it' do
          request
          expect(assigns[:order].drive).to be_nil
        end
      end
    end

    context 'with new drive data' do
      let(:data) do
        {
          order: {
            customer_id: customer.id,
            destination_id: destination.id,
            drive_id: '',
            order_type_id: state_initial.order_type.id,
            needs_review: false,
            size_count: 1,
            size_units: 'TB',
            os: 'Windows',
            address_attributes: attributes_for(:address)
          },
          drive: {
            identification_number: '2047sjkfh948y',
            serial: '209idk28dj',
            size_count: '128',
            size_units: 'GB'
          }
        }
      end

      it 'redirects to new order' do
        expect(request).to redirect_to order_path assigns[:order]
      end

      it 'creates a new order' do
        expect { request }.to change(Order, :count).by(1)
      end

      it 'creates a new drive' do
        expect { request }.to change(Drive, :count).by(1)
      end

      it 'associates the new drive with the order' do
        request
        expect(Order.last.drive).to eq(Drive.last)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:request) { delete(:destroy, params: { id: order.id }) }

    it 'is not successful' do
      expect { request }.to raise_error ActionController::UrlGenerationError
    end
  end

  describe 'GET #index' do
    let(:data) { {} }
    let(:format) { nil }
    let(:request) { get(:index, params: data, format: format) }

    it 'is successful' do
      expect(request).to be_successful
    end

    it 'assigns @orders' do
      order1 = order
      order2 = create(:order)

      request
      expect(assigns(:orders)).to eq([order2, order1])
    end

    it 'renders the index template' do
      expect(request).to render_template(:index)
    end

    describe 'format :csv' do
      let(:format) { :csv }

      it 'is successful' do
        expect(request).to be_successful
      end

      it 'has text/plain content type' do
        request
        expect(response.header['Content-Type']).to match('text/plain')
      end

      context 'with download param' do
        let(:data) { { download: true } }

        it 'will try to download if :download param is passed' do
          request
          expect(response.header['Content-Type']).to match('text/csv')
        end

        it 'sets the filename with a timestamp' do
          request
          expect(response.header['Content-Disposition']).to match(/filename="orders_\d{4}-\d{2}-\d{2}\.csv"/)
        end
      end

      context 'with too many orders' do
        let(:orders) do
          orders = instance_double('ActiveRecord::Relation', size: 501)
          expect(orders).to receive(:reorder) { orders }
          orders
        end

        before do
          allow(controller).to receive(:policy_scope) do
            controller.instance_variable_set(:@_pundit_policy_scoped, true)
            orders
          end
        end

        it 'redirects back to the original page' do
          expect(request).to redirect_to orders_path
        end

        it 'shows an error message to the user' do
          request
          expect(flash[:alert]).to eq(
            'The system cannot process more than 500 records as CSV. Please filter your search and try again.'
          )
        end

        context 'with a search' do
          let(:data) { { q: 'searching...' } }

          it 'redirects back with original params' do
            expect(request).to redirect_to orders_path(q: 'searching...')
          end
        end
      end
    end

    context 'when searching' do
      context 'with a bad search query' do
        let(:data) { { q: 'order_type:"unclosed' } }

        before do
          order
          create(:order)
        end

        it 'returns an empty relation' do
          request
          expect(assigns(:orders)).to eq([])
        end

        it 'shows an alert message' do
          request
          expect(flash[:alert]).to match(/An error occurred while searching: /)
        end
      end

      context 'with a valid search query' do
        let(:data) { { q: 'order_type:idrive-restore' } }
        let(:order_restore) { create(:order_restore) }
        let(:order_restore2) { create(:order_restore) }

        before do
          order
          create(:order)
          order_restore
          order_restore2
          create(:order_idrive_one)
        end

        it 'returns the results' do
          request
          expect(assigns(:orders)).to eq([order_restore2, order_restore])
        end
      end
    end
  end

  describe 'GET #mine' do
    let(:request) { get(:mine) }
    let(:state_shipped) { create(:state_drive_shipped) }

    it 'is successful' do
      expect(request).to be_successful
    end

    it 'assigns @orders to be only orders the user interacted with' do
      order1 = order
      create(:order_state, order: order1, user: user, state: state_shipped)
      create(:order)
      order3 = create(:order)
      create(:order_state, order: order3, user: user, state: state_shipped)
      create(:order)

      request
      expect(assigns(:orders)).to eq([order3, order1])
    end

    it 'assigns @orders_path_sym' do
      request
      expect(assigns[:orders_path_sym]).to eq(:my_orders_path)
    end

    it 'renders the mine template' do
      expect(request).to render_template(:mine)
    end

    describe 'format :csv' do
      let(:data) { {} }
      let(:request) { get(:mine, params: data, format: :csv) }

      it 'is successful' do
        expect(request).to be_successful
      end

      it 'has text/plain content type' do
        request
        expect(response.header['Content-Type']).to match('text/plain')
      end

      context 'with download param' do
        let(:data) { { download: true } }

        it 'will try to download if :download param is passed' do
          request
          expect(response.header['Content-Type']).to match('text/csv')
        end

        it 'sets the filename with a timestamp' do
          request
          expect(response.header['Content-Disposition']).to match(/filename="orders_\d{4}-\d{2}-\d{2}\.csv"/)
        end
      end

      context 'with too many orders' do
        let(:orders) do
          orders = instance_double('ActiveRecord::Relation', size: 501)
          expect(orders).to receive(:reorder) { orders }
          orders
        end

        before do
          allow(controller).to receive(:policy_scope) do
            controller.instance_variable_set(:@_pundit_policy_scoped, true)
            orders
          end
        end

        it 'redirects back to the original page' do
          expect(request).to redirect_to my_orders_path
        end

        it 'shows an error message to the user' do
          request
          expect(flash[:alert]).to eq(
            'The system cannot process more than 500 records as CSV. Please '\
            'filter your search and try again.'
          )
        end

        context 'with a search' do
          let(:data) { { q: 'query' } }

          it 'redirects back with original params' do
            expect(request).to redirect_to my_orders_path(q: 'query')
          end
        end
      end
    end
  end

  describe 'GET #edit' do
    let(:request) { get(:edit, params: { id: order }) }

    it 'is successful' do
      expect(request).to be_successful
    end

    it 'renders the edit template' do
      expect(request).to render_template(:edit)
    end

    it 'assigns @order' do
      request
      expect(assigns[:order]).to eq(order)
    end
  end

  describe 'GET #new' do
    let(:request) { get(:new) }

    it 'is successful' do
      expect(request).to be_successful
    end

    it 'renders the new template' do
      expect(request).to render_template(:new)
    end

    it 'assigns @order' do
      request
      expect(assigns[:order]).to be_a_new(Order)
    end

    it 'builds an address' do
      request
      expect(assigns[:order].address).to be_a_new(Address)
    end
  end

  describe 'GET #show' do
    let(:data) { { id: order } }
    let(:request) { get(:show, params: data) }

    it 'is successful' do
      expect(request).to be_successful
    end

    it 'assigns @order' do
      request
      expect(assigns(:order)).to eq(order)
    end

    it 'assigns @address' do
      request
      expect(assigns(:address)).to eq(order.address)
    end

    it 'assigns @customer' do
      request
      expect(assigns(:customer)).to eq(order.customer)
    end

    it 'assigns @destination' do
      request
      expect(assigns(:destination)).to eq(order.destination)
    end

    it 'assigns @drive' do
      request
      expect(assigns(:drive)).to eq(order.drive)
    end

    it 'assigns @order_type' do
      request
      expect(assigns(:order_type)).to eq(order.order_type)
    end

    it 'assigns @order_states' do
      request
      expect(assigns(:order_states)).to eq(order.order_states.order(id: :asc))
    end

    it 'assigns @order_state' do
      request
      expect(assigns(:order_state)).to be_a_new(OrderState)
    end

    it 'renders the index template' do
      expect(request).to render_template(:show)
    end

    describe 'format :csv' do
      let(:request) { get(:show, params: data, format: :csv) }

      it 'is successful' do
        expect(request).to be_successful
      end

      it 'has text/plain content type' do
        request
        expect(response.header['Content-Type']).to match('text/plain')
      end

      context 'with download parameter' do
        let(:data) { { id: order, download: true } }

        it 'will try to download if :download param is passed' do
          request
          expect(response.header['Content-Type']).to match('text/csv')
        end

        it 'sets the filename with a specific format' do
          request
          expect(response.header['Content-Disposition']).to match(/filename="order-\d+\.csv"/)
        end
      end
    end
  end

  describe 'PATCH #update' do
    let(:request) { patch(:update, params: data) }

    context 'with bad data' do
      let(:data) do
        {
          id: order.id,
          order: {
            customer_id: order.customer_id,
            destination_id: order.destination.id
          },
          drive: {
            serial: ''
          }
        }
      end

      it 'is not successful if validation fails' do
        expect(request).to have_http_status(:unprocessable_entity)
      end

      it 'is rerenders form if validation fails' do
        expect(request).to render_template(:edit)
      end

      it 'assigns @order' do
        request
        expect(assigns[:order]).to eq(order)
      end

      it 'assigns @drive' do
        request
        expect(assigns[:drive]).to be_a_new(Drive)
      end

      it 'shows an error message if validation fails' do
        request
        expect(flash[:alert]).to match(/Error updating order: /)
      end

      it 'requires drive_id on update' do
        request
        expect(assigns[:order].errors.full_messages.to_sentence).to eq("Drive can't be blank")
      end

      context 'with invalid nested drive data' do
        let(:data) do
          {
            id: order.id,
            order: {
              customer_id: order.customer_id
            },
            drive: {
              serial: 'almostvalid'
            }
          }
        end

        it 'validates nested drive' do
          request
          expect(assigns[:order].drive.valid?).to be false
        end
      end
    end

    context 'with valid data' do
      let(:data) do
        {
          id: order.id,
          order: {
            customer_id: order.customer_id,
            destination_id: order.destination.id,
            drive_id: drive.id,
            order_type_id: order.order_type.id,
            needs_review: order.needs_review,
            size_count: order.size_count,
            size_units: order.size_units,
            os: order.os,
            address_attributes: {
              id: order.address.id,
              recipient: order.address.recipient,
              organization: order.address.organization,
              address: order.address.address,
              city: order.address.city,
              state: order.address.state,
              zip: order.address.zip,
              country: order.address.country
            }
          }
        }
      end

      it 'redirects back to the show page' do
        expect(request).to redirect_to order_path(order)
      end

      it 'updates the order' do
        request
        expect(order.reload.drive).to eq(drive)
      end

      it 'shows a message to the user' do
        request
        expect(flash[:notice]).to eq('Order updated successfully')
      end
    end

    context 'without drive_id set' do
      let(:data) do
        {
          id: order.id,
          order: {
            customer_id: order.customer_id,
            destination_id: order.destination.id,
            drive_id: '',
            order_type_id: order.order_type.id,
            needs_review: order.needs_review,
            size_count: order.size_count,
            size_units: order.size_units,
            os: order.os,
            address_attributes: {
              id: order.address.id,
              recipient: order.address.recipient,
              organization: order.address.organization,
              address: order.address.address,
              city: order.address.city,
              state: order.address.state,
              zip: order.address.zip,
              country: order.address.country
            }
          },
          drive: {
            identification_number: '66d172e15103ce214821a425abf5bb75',
            serial: '9734256ad8fdfb98784b1ec3dd0043f8',
            size_count: '2',
            size_units: 'TB'
          }
        }
      end

      it 'redirects back to #show' do
        expect(request).to redirect_to order_path(order)
      end

      it 'creates a new drive' do
        expect { request }.to change(Drive, :count).by(1)
      end
    end
  end
end
