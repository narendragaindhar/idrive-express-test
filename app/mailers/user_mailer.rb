class UserMailer < ApplicationMailer
  def reset_password_email(user)
    @user = user
    @subject = 'Reset your IDrive Express password'
    mail to: user.email, subject: @subject
  end

  def new_user_email(user)
    @user = user
    @user.generate_reset_password_token! # for auto-setting new password from email
    @subject = 'Your new IDrive Express account'
    mail to: @user.email, subject: @subject
  end

  def notify_user_of_order_state(user, order_state)
    @user = user
    @order_state = order_state
    @subject = "Notification update for order ##{@order_state.order.id}: #{@order_state.state.label}"
    mail to: @user.email, subject: @subject, reply_to: order_state.user.email
  end
end
