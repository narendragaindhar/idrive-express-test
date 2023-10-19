class DayCount < ApplicationRecord
  belongs_to :order

  validates :order, presence: true
  validates :count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :is_final, inclusion: { in: [true, false] }

  after_initialize do
    if new_record?
      self.count ||= 0
      self.is_final ||= false
    end
  end

  def label
    day_count = count.to_s
    if stale?
      day_count += ' (Stale)'
    elsif is_final?
      day_count += ' (Final)'
    end
    day_count
  end

  def recount
    count = 0
    the_day = order.created_at.to_date
    today = Time.zone.today
    completed_at = order.completed_at&.to_date

    until the_day > today || (completed_at && the_day > completed_at)
      unless the_day.sunday? || the_day.saturday?
        order_state = OrderState.latest_for_date(order, the_day)
        unless order_state.present? &&
               (order_state.created_at.to_date < the_day &&
                order_state.state.leaves_us?) ||
               order_state.state.is_out_of_our_hands?
          count += 1
        end
      end
      the_day += 1
    end

    update(count: count,
           is_final: completed_at.present? && the_day > completed_at,
           updated_at: Time.zone.now)
    count
  end

  def stale?
    new_record? || (!is_final? && updated_at < Time.zone.now.beginning_of_day)
  end
end
