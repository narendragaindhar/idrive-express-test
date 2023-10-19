class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :require_login
  before_action :set_orders_path
  after_action :verify_authorized

  # authorization
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def not_authenticated
    redirect_to main_app.login_path, alert: 'You must be logged in to access the requested page.'
  end

  def user_not_authorized(exception)
    logger.warn(
      "Unauthorized action detected by User ##{current_user.id} "\
      "(#{current_user.name} <#{current_user.email}>): "\
      "action=#{exception.policy.class}.#{exception.query} url=#{request.path}"
    )
    flash[:error] = 'You are not authorized to perform this action'
    redirect_to(request.referer || main_app.root_path)
  end

  # many urls default to using the `orders_path` helper however there are times
  # when this may not be true (namely when viewing "my orders"). we will set
  # as default, however controllers may override this if need be
  def set_orders_path
    @orders_path_sym = :orders_path
  end
end
