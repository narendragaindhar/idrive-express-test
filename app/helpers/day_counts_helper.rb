module DayCountsHelper
  def day_count_stale_class(order)
    if order.day_count.present? && !order.day_count.stale?
      ''
    else
      'js-order-day-count-is-stale'
    end
  end
end
