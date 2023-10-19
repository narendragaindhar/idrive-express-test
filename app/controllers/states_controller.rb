class StatesController < ApplicationController
  before_action :find_order

  # POST /orders/:order_id/state
  # this is for the form at the bottom of the order page where a User can create an OrderState (not a State)
  # This triggers many possible callbacks:
  # Customer notification and IDrive API updating,
  # order completion, drive event creation, and auto-adding user to watchlist
  def create
    @order_state = @order.order_states.build order_state_params
    @order_state.user = User.find(current_user.id)
    if @order_state.save
      flash[:error] = @order_state.errors.full_messages.to_sentence if @order_state.errors.present?
      redirect_to @order, notice: 'Order state added successfully'
    else
      flash.now[:error] = "Error updating order: #{@order_state.errors.full_messages.to_sentence}"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def find_order
    @order = Order.find(params[:order_id])
    authorize @order, :update?
  end

  def order_state_params
    params.require(:order_state).permit(:comments, :did_notify, :is_public, :state_id, :notify_user_id)
  end
end
