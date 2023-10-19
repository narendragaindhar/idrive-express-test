module API
  module V4
    class OrdersController < API::APIController
      # POST /api/v4/orders (JSON) accepts the following params:
      # {
      #   order: {
      #     address: {address, city, country, organization, recipient, state, zip},
      #     customer: {created_at, email, name, phone, priority, quota, server, username}
      #     destination: {key}
      #     order_type: {key},
      #     comments,
      #     size,
      #     needs_review,
      #     os
      # }
      #
      # Create an Order and associate it with an existing customer (or create a
      # new one if necessary)
      #
      # Success:
      # Order JSON including nested address, customer, destination and order_type
      # returned
      #
      # Errors:
      # Bad Request (400) if address | customer | destination | order_type |
      # order params are missing (eg {"address": "blank"})
      # Unprocessable Entity (422) if the address | customer | destination |
      # order_type | order are invalid upon saving (eg {"destination": "cannot be
      # blank", "address.city": "cannot be blank"})
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
          render json: @order, status: :created, location: @order
        else
          logger.error "API::V4 422 Error: Could not save order because: #{@order.errors.full_messages}"
          render json: @order.errors, status: :unprocessable_entity
        end
      rescue ActionController::ParameterMissing => e
        logger.error "API::V4 API 400 Error: Could not save order because: #{e}"
        render json: { e.param => 'blank' }, status: :bad_request
      end

      private

      def address_params
        params.require(:order)
              .require(:address)
              .permit(:address, :city, :country, :organization, :recipient,
                      :state, :zip)
      end

      def customer_params
        # instantiating to avoid multiple calls as we delete email and username
        # from the hash when finding the customer
        @customer_params ||=
          params.require(:order)
                .require(:customer)
                .permit(:created_at, :email, :name, :phone, :priority, :quota,
                        :server, :username)
      end

      def destination_params
        params.require(:order).require(:destination).permit(:key)
      end

      def order_type_params
        params.require(:order).require(:order_type).permit(:key)
      end

      def order_params
        params.require(:order).permit(:comments, :size, :needs_review, :os)
      end
    end
  end
end
