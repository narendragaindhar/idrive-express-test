class User < ApplicationRecord
  authenticates_with_sorcery!

  has_and_belongs_to_many :orders
  has_and_belongs_to_many :roles
  has_many :drive_events, dependent: :restrict_with_exception
  has_many :order_states, dependent: :restrict_with_exception

  attr_accessor :remember_me

  validates :name,
            presence: true,
            length: { maximum: 255 }
  validates :email,
            presence: true,
            uniqueness: true,
            length: { maximum: 255 },
            format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :password,
            presence: true,
            confirmation: { if: -> { persisted? } },
            if: -> { new_record? || password.present? }

  # scopes
  scope :exclude_users, ->(users) { where.not(id: users) if users.present? && !users.empty? }
  scope :by_name, -> { order(name: :asc) }
  scope :including_roles, -> { references(:users_roles).includes(:roles, roles_users: :role) }

  def self.all_by_name(*except_users)
    exclude_users(except_users).by_name
  end

  def role?(*keys)
    !roles.where(key: keys).empty?
  end
end
