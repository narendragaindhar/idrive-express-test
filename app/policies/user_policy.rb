class UserPolicy < ApplicationPolicy
  def create?
    allowed?
  end

  def index?
    allowed?
  end

  def show?
    same_user? || allowed?
  end

  def update?
    same_user?
  end

  def disable?
    allowed?
  end

  def permitted_attributes
    if record.new_record?
      %i[email name]
    elsif user.id == record.id
      %i[email name password password_confirmation]
    else
      []
    end
  end

  private

  def allowed?
    user.role? :idrive_employee, :super_user
  end

  def same_user?
    user.id == record.id
  end
end
