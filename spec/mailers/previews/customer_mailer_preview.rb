# Preview all emails at http://localhost:3000/rails/mailers/customer_mailer
class CustomerMailerPreview < ActionMailer::Preview
  def order_state_updated
    order_states = OrderState.pluck(:id)
    CustomerMailer.order_state_updated(OrderState.find(order_states.sample))
  end
end
