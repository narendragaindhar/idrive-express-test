# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def new_user_email
    users = User.pluck(:id)
    UserMailer.new_user_email(User.find(users.sample))
  end

  def notify_user_of_order_state
    order_states = OrderState.where.not(user: nil).pluck(:id)
    order_state = OrderState.find(order_states.sample)
    user = User.where.not(id: order_state.user.id).first
    UserMailer.notify_user_of_order_state(user, order_state)
  end

  def reset_password_email
    users = User.pluck(:id)
    user = User.find(users.sample)
    user.generate_reset_password_token!
    UserMailer.reset_password_email(user)
  end
end
