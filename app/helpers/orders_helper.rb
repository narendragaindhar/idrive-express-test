module OrdersHelper
  def order_row_class(order)
    if order_is_in_danger?(order)
      'list-group-item-danger'
    elsif order_is_in_warning?(order)
      'list-group-item-warning'
    end
  end

  def order_label_class(order)
    if order_is_in_danger?(order)
      'tag-danger'
    elsif order_is_in_warning?(order)
      'tag-warning'
    else
      'tag-default'
    end
  end

  def order_label_title(order)
    if order_is_in_danger?(order)
      "Danger: It has been #{order.day_count.count} days since this order was created"
    elsif order_is_in_warning?(order)
      "Warning: It has been #{order.day_count.count} days since this order was created"
    elsif order.day_count.present? && !order.day_count.stale?
      if order.completed_at.present?
        "Order took #{pluralize(order.day_count.count, 'day')} to complete"
      else
        "Order has been active for #{pluralize(order.day_count.count, 'day')}"
      end
    else
      'Calculating day count...'
    end
  end

  def order_is_in_danger?(order)
    order.completed_at.blank? &&
      order.day_count.present? &&
      !order.day_count.stale? &&
      order.day_count.count >= ENV['ORDERS_DANGER_DAYS'].to_i
  end

  def order_is_in_warning?(order)
    order.completed_at.blank? &&
      order.day_count.present? &&
      !order.day_count.stale? &&
      order.day_count.count >= ENV['ORDERS_WARNING_DAYS'].to_i
  end
end
