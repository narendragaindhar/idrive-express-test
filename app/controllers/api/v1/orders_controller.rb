module API
  module V1
    class OrdersController < API::APIController
      # POST /api/v1/orders (JSON) accepts the following params:
      # {
      #   address: {address, city, country, organization, recipient, state, zip},
      #   customer: {created_at, email, name, phone, priority, quota, server, username}
      #   datacenter: {key}
      #   express_kind: {key},
      #   order: {comments, max_upload_size, needs_review, os}
      # }
      #
      # Create an Order and associate it with an existing customer (or create a new one if necessary)
      #
      # Success:
      # Order JSON including nested address, customer, datacenter and express_kind returned
      #
      # Errors:
      # Bad Request (400) if address | customer | datacenter | express_kind | order params are missing
      #   eg {"address": "blank"}
      # Unprocessable Entity (422) if the address | customer | datacenter | express_kind | order are invalid upon saving
      #   eg {"datacenter": "cannot be blank", "address.city": "cannot be blank"}
      def create
        order_type = OrderType.includes(:product).find_by key: order_type_params[:key]
        # customer could exist in the system already, matching by username and
        # product
        customer = Customer.where(
          username: customer_params.delete(:username),
          product: order_type.product
        ).first_or_initialize
        customer.record_timestamps = false
        customer_params[:updated_at] = Time.zone.now
        customer.update(customer_params)

        @order = Order.new order_params
        # address is created fresh for each order so updating one order will
        # not overwrite all other past orders to a particular address
        @order.address = Address.new address_params
        @order.customer = customer
        # destination and order type must exist in the system already
        @order.destination = Destination.find_by key: destination_params[:key], active: true
        @order.order_type = order_type

        if @order.save
          json = @order.as_json
          json[:datacenter] = json.delete(:destination)
          json[:max_upload_size] = json.delete(:size)
          json[:order_type][:key] = 'upload' if json[:order_type][:key] == OrderType::IDRIVE_UPLOAD
          json[:express_kind] = json.delete(:order_type)
          render json: json, status: :created, location: @order
        else
          logger.error "API::V1 422 Error: Could not save order because: #{@order.errors.full_messages}"
          render json: @order.errors, status: :unprocessable_entity
        end
      rescue ActionController::ParameterMissing => e
        logger.error "API::V1 400 Error: Could not save order because: #{e}"
        render json: { e.param => 'blank' }, status: :bad_request
      end

      private

      def address_params
        params.require(:address).permit(:address, :city, :country, :organization, :recipient, :state, :zip)
      end

      def customer_params
        # instantiating to avoid multiple calls as we delete email and username
        # from the hash when finding the customer
        @customer_params ||= params.require(:customer).permit(
          :created_at, :email, :name, :phone, :priority, :quota, :server, :username
        )
      end

      def destination_params
        params.require(:datacenter).permit(:key)
      end

      def order_type_params
        p = params.require(:express_kind).permit(:key)
        p[:key] = OrderType::IDRIVE_UPLOAD if p[:key] == 'upload'
        p
      end

      def order_params
        p = params.require(:order).permit(:comments, :max_upload_size, :needs_review, :os)
        p[:size] = p.delete(:max_upload_size)
        p
      end
    end
  end
end
