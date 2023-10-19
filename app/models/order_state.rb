class OrderState < ApplicationRecord
  belongs_to :user
  belongs_to :order, touch: true
  belongs_to :state

  attr_accessor :user_id, :notify_user_id

  validates :did_notify, inclusion: { in: [true, false] }
  validates :is_public, inclusion: { in: [true, false] }
  validates :order, presence: true
  validates :state, presence: true

  after_create :add_user_to_order_watchlist
  after_create :complete_order,              if: :completed?
  after_create :create_drive_event,          if: :drive_event?
  after_create :notify_customer, if: :did_notify?
  after_create :notify_user
  after_create :staleify_day_count
  after_create :update_api, if: :is_public?
  after_create :reopen_completed_order, if: -> { !order&.completed_at.nil? }

  def self.latest_for_date(order, date)
    next_date = date + 1
    time = Time.zone.parse "#{next_date.year}-#{next_date.month}-#{next_date.day} 00:00:00"
    where(order: order)
      .where('created_at < ?', time.beginning_of_day)
      .order(created_at: :desc)
      .order(id: :desc)
      .first
      .presence
  end

  def staleify_day_count
    order.day_count&.update(updated_at: 24.hours.ago)
  end

  def private?
    !is_public? && !did_notify?
  end

  private

  def add_user_to_order_watchlist
    order.add_user_to_watchlist user
  end

  def completed?
    state && state.percentage == 100
  end

  def complete_order
    begin
      order.update_attribute :completed_at, Time.zone.now
    rescue ActiveRecord::RecordNotUnique
      # orders.users can throw duplicate key exception
    end

    # in general, states that complete the order reset the in_use field unless
    # they do not return to us
    if state.completes_successfully? &&
       order.drive &&
       !order.order_type.key_is?(:idrive_one, :idrive_bmr)
      order.drive.update in_use: false
    end
  end

  def create_drive_event
    order.drive.drive_events.create user: user, event: "#{state.label} on Order ##{order_id}"
  end

  def drive_event?
    state&.is_drive_event && order.drive.present?
  end

  def notify_customer
    CustomerMailer.order_state_updated(self).deliver_later
  end

  def notify_user
    return if notify_user_id.blank?

    begin
      user = User.find(notify_user_id)
      UserMailer.notify_user_of_order_state(user, self).deliver_later
    rescue ActiveRecord::RecordNotFound
      logger.error "Tried to notify non-existant user_id: #{notify_user_id}"
    end
  end

  def update_api
    UpdateAPIJob.perform_later(self)
  end

  def reopen_completed_order
    if state && state.percentage < 100 # rubocop:disable Style/GuardClause
      begin
        order.update_attribute :completed_at, nil
      rescue ActiveRecord::RecordNotUnique
        # orders.users can throw duplicate key exception
      end

      if order.drive &&
         !order.order_type.key_is?(:idrive_one, :idrive_bmr)
        order.drive.update in_use: true
      end
    end
  end
end
