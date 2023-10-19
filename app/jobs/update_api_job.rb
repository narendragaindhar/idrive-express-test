class UpdateAPIJob < ApplicationJob
  queue_as :default

  def perform(order_state)
    return if UpdateService.perform(order_state)

    order_state.update!(is_public: false)
    Rails.logger.error "API update failed on #{order_state.order.order_type.product.name}"
  end
end
