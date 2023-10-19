class SessionsController < ApplicationController
  skip_before_action :require_login
  skip_after_action :verify_authorized

  # POST /login
  def create
    if disabled?
      flash.now[:error] = 'Your account has been deactivated, and login is no longer possible.'
      @user = User.new user_params
      render :new
    elsif login(user_params[:email], user_params[:password], user_params[:remember_me])
      redirect_back_or_to root_path, notice: 'Logged in successfully.'
    else
      logger.warn "Invalid login for user: #{user_params[:email]}"
      flash.now.alert = 'Email or password was invalid.'
      @user = User.new user_params
      render :new
    end
  end

  # DELETE /logout
  def destroy
    logout
    redirect_to login_path, notice: 'You have been logged out.'
  end

  # GET /login
  def new
    @user = User.new
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :remember_me)
  end

  def disabled?
    user = User.find_by(email: user_params[:email])
    !user&.disabled_at.nil?
  end
end
