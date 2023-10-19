class Destination < ApplicationRecord
  has_many :orders, dependent: :nullify
  has_one :address, as: :addressable, dependent: :destroy, inverse_of: :addressable

  validates :address, presence: true
  validates :active, inclusion: { in: [true, false] }
  validates :key,
            presence: true,
            uniqueness: true,
            format: { with: /\A[a-z0-9_]{3,}\Z/,
                      message: 'must be at least 3 lowercase alphanumeric characters (or "_")' }
  validates :name, presence: true

  accepts_nested_attributes_for :address

  after_initialize do
    self.active ||= true if new_record?
  end

  def key=(key)
    super(key.try(:downcase))
  end
end
