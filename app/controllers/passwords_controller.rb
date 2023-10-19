class PasswordsController < ApplicationController
  before_action :find_user_by_token, only: %i[edit update]
  skip_before_action :require_login
  skip_after_action :verify_authorized

  # POST /passwords
  def create
    user = User.find_by email: user_params[:email]
    if user.present?
      user.deliver_reset_password_instructions!
      redirect_to login_path, notice: 'Instructions have been sent to your email address.'
    else
      flash.now[:error] = 'No user was found with those details'
      @user = User.new user_params
      render :new
    end
  end

  # GET /passwords/:id/edit
  def edit
    flash.now[:notice] = 'You can now reset your password'
  end

  # GET /passwords/new
  def new
    @user = User.new
  end

  # PATCH/PUT /passwords/:id
  def update
    @user.password_confirmation = user_params[:password_confirmation]
    if @user.change_password(user_params[:password])
      auto_login(@user)
      redirect_to root_path, notice: 'Password was successfully updated and you have been logged in'
    else
      flash.now[:error] = 'There was a problem resetting your password'
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def find_user_by_token
    @token = params.require(:id)
    @user = User.load_from_reset_password_token(@token)
    redirect_to new_password_path, alert: 'Could not find user with that reset link' unless @user
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
