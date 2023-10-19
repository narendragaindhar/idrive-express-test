class UsersController < ApplicationController
  before_action :find_user, only: %i[edit show update disable]

  # POST /users or POST /order/:order_id/users
  def create
    if params[:order_id]
      @order = Order.find params[:order_id]
      authorize(@order, :update?)

      @user = User.find(params.require(:user).require(:id))
      @order.add_user_to_watchlist @user
      redirect_to @order, notice: "#{@user.name} added to watchlist"
    else
      @user = User.new(permitted_attributes(User.new))
      authorize @user
      @user.password = SecureRandom.hex

      if @user.save
        UserMailer.new_user_email(@user).deliver_later
        notice = 'User was successfully created.'
        if policy(Contexts::UserRole.new(@user)).edit?
          notice = [notice, 'New users have no roles and cannot perform many '\
                            'actions on the site. Make sure you grant this '\
                            'user some roles before they use the site']
        end
        redirect_to user_path(@user), notice: notice
      else
        flash.now[:error] = 'User could not be created'
        render :new, status: :unprocessable_entity
      end
    end
  end

  # DELETE /order/:order_id/users/:id
  def destroy
    @order = Order.find params[:order_id]
    authorize(@order, :update?)

    @user = @order.users.find(params[:id])
    @order.user_ids -= [@user.id]
    redirect_to @order
  end

  # GET /users/:id/edit
  def edit
    authorize @user
  end

  # GET /users
  def index
    @users = User.including_roles.by_name
    authorize @users
    @user = User.new
    authorize @user, :new?
  end

  # GET /users/new
  def new
    @user = User.new
    authorize @user
  end

  # GET /users/:id
  def show
    authorize @user
  end

  # PATCH/PUT /users/:id
  def update
    authorize @user
    attrs = permitted_attributes(@user).reject { |_k, v| v.blank? }
    @user.name = attrs[:name] if attrs.key? :name
    @user.email = attrs[:email] if attrs.key? :email
    if attrs.key? :password
      @user.password = attrs[:password]
      @user.password_confirmation = attrs.fetch(:password_confirmation, '')
    end

    if @user.save
      redirect_to user_path(@user), notice: 'Profile updated successfully'
    else
      flash.now[:error] = 'Profile could not be updated'
      render :edit, status: :unprocessable_entity
    end
  end

  def disable
    authorize @user
    if params[:user][:disabled_at] == '1'
      if @user.disabled_at.nil?
        @user.disabled_at = Time.now
        @user.disabled_reason = params[:user][:disabled_reason]
      else
        @user.disabled_at = nil
        @user.disabled_reason = nil
      end
      @user.save
    end
    redirect_to user_path(@user)
  end

  private

  def find_user
    @user = User.including_roles.find(params[:id])
  end
end
