class RolesController < ApplicationController
  before_action :find_user
  before_action :setup_view

  # GET /users/:user_id/roles/edit
  def edit
    authorize Contexts::UserRole.new(@user)
    @chosen_roles = @user.roles.by_name
  end

  # PATCH/PUT /users/:user_id/roles
  def update
    roles = Role.where(id: role_params[:roles])
    user_roles = Contexts::UserRole.new(@user, roles)
    authorize user_roles

    begin
      @user.roles = user_roles.roles
      flash[:notice] = 'Roles updated successfully'
      redirect_to user_path(user_roles.user)
    rescue ActiveRecord::RecordNotSaved
      @chosen_roles = user_roles.roles
      flash[:error] = 'Role update failed'
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def find_user
    @user = User.find(params[:user_id])
  end

  def role_params
    params.require(:user).permit(roles: [])
  end

  def setup_view
    @roles = Role.by_name
  end
end
