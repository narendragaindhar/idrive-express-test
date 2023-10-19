class Customer < ApplicationRecord
  include ActionView::Helpers::NumberHelper

  HIGH_PRIORITY_MINIMUM = ENV.fetch('EXPRESS_CUSTOMER_HIGH_PRIORITY_MINIMUM', 3).to_i.freeze
  PRIORITY_MINIMUM = ENV.fetch('EXPRESS_CUSTOMER_PRIORITY_MINIMUM', 1).to_i.freeze

  belongs_to :product
  has_many :orders, dependent: :restrict_with_exception, inverse_of: :customer

  validates :email, presence: true
  validates :name, presence: true
  validates :priority, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :product, presence: true
  validates :quota, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :username, presence: true, uniqueness: { scope: :product }

  scope :search, lambda { |query|
    if query.present?
      where('`email` LIKE ? OR `name` LIKE ? OR `username` LIKE ?',
            "#{query}%", "%#{query}%", "#{query}%")
    end
  }

  def email=(email)
    super(email.try(:downcase))
  end

  def label
    "#{name} (#{username})"
  end

  def high_priority?
    priority && priority >= HIGH_PRIORITY_MINIMUM
  end

  def human_phone
    number_to_phone(phone)
  end

  def human_quota
    number_to_human_size(quota)
  end

  def normal_priority?
    priority && priority >= PRIORITY_MINIMUM
  end

  def username=(username)
    super(username.try(:downcase))
  end

  def more_than_one_open_order?
    orders.where(completed_at: nil).count > 1
  end
end
