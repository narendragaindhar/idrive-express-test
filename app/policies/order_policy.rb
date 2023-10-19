class OrderPolicy < ApplicationPolicy
  def bulk_update?
    user.role? :super_user, :idrive_employee, :idrive_one_contractor, :bmr_agent
  end

  def create?
    user.role? :idrive_employee, :super_user
  end

  def show?
    update? || user.role?(:support_agent)
  end

  def update?
    if create?
      true
    elsif user.role? :idrive_one_contractor
      record.order_type.key_is? :idrive_one
    elsif user.role? :bmr_agent
      record.order_type.key.include?('idrive_bmr')
    else
      false
    end
  end

  class Scope < Scope
    def resolve
      if user.role? :idrive_employee, :super_user, :support_agent
        scope.references(:order_types).where(
          order_types: { key: OrderType::ORDER_TYPES }
        )
      elsif user.role? :idrive_one_contractor
        scope.references(:order_types).where(order_types: { key: OrderType::IDRIVE_ONE })
      elsif user.role? :bmr_agent
        scope.references(:order_types).where(order_types: { key: OrderType::ORDER_TYPES.grep(/idrive_bmr/) })
      else
        scope.none
      end
    end
  end
end
