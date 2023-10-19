class OrdersController < ApplicationController
  MAX_CSV_RECORDS = 500

  after_action :verify_policy_scoped, only: %i[index mine]
  skip_after_action :verify_authorized, only: %i[index mine]

  # POST /orders
  def create
    @order = current_user.orders.new order_params
    authorize @order

    if @order.save
      redirect_to @order, notice: "Order ##{@order.id} created successfully"
    else
      flash.now[:alert] = "Error creating Order #{@order.errors.full_messages.to_sentence}"
      @drive = @order.drive || Drive.new
      setup_form
      render :new, status: :unprocessable_entity
    end
  end

  # GET /orders/:id/edit
  def edit
    @order = Order.includes(:drive).find params[:id]
    authorize @order
    @drive = Drive.new
    setup_form
  end

  # GET /orders
  def index
    index_common
  end

  # GET /orders/mine
  def mine
    @orders_path_sym = :my_orders_path
    index_common current_user
  end

  # GET /orders/new
  def new
    @order = Order.new
    authorize @order
    @drive = Drive.new
    setup_form
  end

  # GET /orders/:id
  def show
    @order = Order.references(:orders_users).includes(
      :address, :customer, :drive, :order_type, :users, orders_users: :user
    ).find params[:id]
    authorize @order
    setup_show
    respond_to do |format|
      format.html
      format.csv do
        if params.fetch(:download, false).present?
          send_data @order.to_csv, filename: "order-#{@order.id}.csv"
        else
          render plain: @order.to_csv, content_type: 'text/plain'
        end
      end
    end
  end

  # PATCH|PUT /orders/:id
  def update
    @order = Order.find params[:id]
    authorize @order

    if @order.update order_params
      redirect_to @order, notice: 'Order updated successfully'
    else
      flash.now[:alert] = "Error updating order: #{@order.errors.full_messages.to_sentence}"
      @drive = @order.drive || Drive.new
      setup_form
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def order_params
    return @order_params if @order_params

    @order_params = params.require(:order).permit(
      :customer_id,
      :destination_id,
      :drive_id,
      :order_type_id,
      :needs_review,
      :size_count,
      :size_units,
      :os,
      address_attributes: %i[id recipient organization address city state zip country]
    ).merge(
      current_user_id: current_user.id # associating the current user with various associations in callbacks
    )

    if @order_params[:drive_id].blank? && drive_params_present?
      @order_params.delete(:drive_id)
      @order_params[:drive_attributes] = drive_params
    end
    @order_params
  end

  def drive_params
    @drive_params ||= params.require(:drive).permit(
      :identification_number,
      :serial,
      :size_count,
      :size_units
    )
  end

  def drive_params_present?
    drive_params.values.any?(&:present?)
  end

  def setup_form
    @order.build_address unless @order.address
  end

  def setup_show
    @address = @order.address
    @customer = @order.customer
    @destination = @order.destination
    @drive = @order.drive
    @order_type = @order.order_type
    @order_states = @order.order_states.includes(:user, :state).order(id: :asc)
    @order_state = OrderState.new(order: @order)
  end

  def index_common(user = nil)
    if stale? Order.most_recently_updated user
      begin
        @orders = user.present? ? Order.where_user(user) : Order.all
        @orders = policy_scope(OrderQuery.resolve(params[:q], @orders))
      rescue KeywordSearch::ParseError => e
        logger.error "A search error occurred: #{e.inspect}"
        flash.now[:alert] = "An error occurred while searching: #{e.message}"
        skip_policy_scope
        @orders = Order.none
      end

      respond_to do |format|
        format.html do
          @orders = @orders.paginate(page: params[:page])
        end
        format.csv do
          @orders = @orders.reorder(nil)
          if @orders.size > MAX_CSV_RECORDS
            return_path = params[:action] == 'mine' ? :my_orders_path : :orders_path
            redirect_to send(return_path, params.permit(:q, :utf8)),
                        alert: "The system cannot process more than #{MAX_CSV_RECORDS} "\
                               'records as CSV. Please filter your search and try again.'
          elsif params.fetch(:download, false).present?
            filename = "orders_#{Time.zone.now.strftime('%Y-%m-%d')}.csv"
            send_data @orders.to_csv, filename: filename
          else
            render plain: @orders.to_csv, content_type: 'text/plain'
          end
        end
      end
    else
      skip_policy_scope
    end
  end
end
