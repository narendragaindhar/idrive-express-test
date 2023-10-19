class Role < ApplicationRecord
  has_and_belongs_to_many :users

  # validation
  validates :key,
            presence: true,
            length: { maximum: 255 },
            format: {
              with: /\A[a-z0-9_]{3,}\Z/,
              message: 'must be at least 3 lowercase alphanumeric characters (or "_")'
            },
            uniqueness: true
  validates :name, presence: true, length: { maximum: 255 }
  validates :description, presence: true, length: { maximum: 255 }

  # scopes
  scope :by_name, -> { order(name: :asc) }
end
