class DayCountsController < ApplicationController
  # GET /orders/:id/day_count
  def show
    @order = Order.includes(:day_count).find(params[:order_id])
    authorize @order

    @order.create_day_count if @order.day_count.blank?
    @order.day_count.recount if @order.day_count.stale? || params.key?(:recount)
    render :show
  end
end
