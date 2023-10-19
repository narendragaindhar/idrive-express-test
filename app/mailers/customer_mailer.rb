class CustomerMailer < ApplicationMailer
  # any errors that happen while notifying the customer must record that the
  # notification failed
  rescue_from(*EMAIL_ERRORS) do
    @order_state.update!(did_notify: false)
  end

  # notify a customer about a change in their order
  def order_state_updated(order_state)
    @order_state = order_state
    @state = @order_state.state
    @order = @order_state.order
    @customer = @order.customer
    @subject = "Update for your #{@order.order_type.full_name} order (##{@order.id})"
    mail to: @customer.email, subject: @subject, **self.class.defaults_for(@order.order_type)
  end
end
