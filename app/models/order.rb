class Order < ApplicationRecord
  include Sizable

  self.per_page = ENV['ORDERS_PER_PAGE'] || 50

  belongs_to :customer, inverse_of: :orders
  belongs_to :destination
  belongs_to :drive
  belongs_to :order_type
  has_many :order_states, dependent: :destroy
  has_many :states, inverse_of: :orders, through: :order_states
  has_and_belongs_to_many :users
  has_one :address, as: :addressable, dependent: :destroy
  has_one :day_count, dependent: :destroy

  attr_accessor :current_user_id

  validates :address, presence: true
  validates :customer, presence: true
  validates :destination, presence: true
  validates :drive, presence: { on: :update }
  validates :needs_review, inclusion: { in: [true, false] }
  validates :order_type, presence: true
  validates :size, numericality: { greater_than: 0 }
  validates :size_count, presence: true
  validates :size_units, presence: true, inclusion: { in: UNITS }
  validate :idrive_one_not_shipping_outside_usa

  accepts_nested_attributes_for :address, :customer, :drive

  after_create :set_initial_state
  after_update :update_users
  after_save :update_drive_availability

  # scopes
  scope :where_user, lambda { |user|
    joins(:orders_users).where(orders_users: { user: user }) if user.present?
  }

  # return the most recent order from a given user or all if none passed
  def self.most_recently_updated(user = nil)
    where_user(user)
      .order(updated_at: :desc).first
  end

  def self.to_csv(options = {})
    CSV.generate(**options) do |csv|
      all.find_each(batch_size: 100) do |order|
        csv << order.to_csv(format: :array)
      end
    end
  end

  def as_json(_options = {})
    {
      # order attributes
      id: id,
      comments: comments,
      size: size,
      needs_review: needs_review,
      os: os,
      created_at: created_at,
      updated_at: updated_at,
      # associations attributes
      address: address,
      customer: customer,
      destination: destination,
      order_type: order_type
    }
  end

  def customer_label
    customer.try(:label)
  end

  def drive_label
    drive.try(:label)
  end

  def labelize
    lbl = "##{id} | #{order_type.full_name}"
    lbl << " (#{humanize_size} #{comments})" if order_type.key_is? :idrive_one
    "#{lbl} for #{customer.username}"
  end

  def label
    @label ||= order_states.order(:id).last.try(:state).try(:label) || ''
  end

  def percentage
    @percentage ||= order_states.order(:id).last.try(:state).try(:percentage) || 0
  end

  def last_updating_user
    @last_updating_user ||= order_states.order(:id).last.try(:user).try(:name) || ''
  end

  def create_day_count(*options)
    super(*options, created_at: created_at, updated_at: 24.hours.ago)
  end

  def set_initial_state
    initial_state = State.get_initial_state(order_type)
    order_states.create! state: initial_state, comments: initial_state.description,
                         did_notify: initial_state.notify_by_default,
                         is_public: initial_state.public_by_default
  end

  def to_csv(format: :csv)
    fields = [
      id,
      customer.username,
      address.to_field,
      address.address,
      address.city,
      address.state,
      address.zip,
      address.country
    ]
    format == :array ? fields : fields.to_csv
  end

  def update_drive_availability
    # NOTE: having to use changes not previous_changes despite being in an after_update due to it being a db transaction
    return unless saved_changes['drive_id']

    old_drive_id = saved_changes['drive_id'][0]
    Drive.find(old_drive_id).update(in_use: false) unless old_drive_id.nil?
    drive.update in_use: true
    return unless current_user_id

    drive.drive_events.create(user_id: current_user_id,
                              event: "Drive associated with Order ##{id}")
  end

  def update_users
    add_user_to_watchlist(User.find(current_user_id)) if current_user_id
  end

  def add_user_to_watchlist(user)
    users << user if user
  rescue ActiveRecord::RecordNotUnique
    # we good. user is already working on it.
  end

  def idrive_one_not_shipping_outside_usa
    return unless order_type&.key_is?(:idrive_one) && address&.outside_usa?

    errors.add :base, 'Cannot ship to addresses outside of the USA'
  end
end
