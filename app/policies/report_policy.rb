class ReportPolicy < ApplicationPolicy
  def create?
    allowed?
  end

  def destroy?
    allowed?
  end

  def index?
    allowed?
  end

  def preview?
    allowed?
  end

  def run?
    allowed?
  end

  def show?
    allowed?
  end

  def update?
    allowed?
  end

  private

  def allowed?
    user.role? :reporting, :super_user
  end
end
