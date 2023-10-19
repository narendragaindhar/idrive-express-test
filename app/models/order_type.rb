class OrderType < ApplicationRecord
  belongs_to :product
  has_many :orders, dependent: :nullify
  has_many :states, dependent: :nullify

  validates :key, presence: true, uniqueness: true,
                  format: { with: /\A[a-z0-9_]{3,}\Z/,
                            message: 'must be at least 3 lowercase alphanumeric characters (or "_")' }
  validates :name, presence: true
  validates :product, presence: true

  IDRIVE_UPLOAD = 'idrive_upload'.freeze
  IDRIVE_RESTORE = 'idrive_restore'.freeze
  IDRIVE_ONE = 'idrive_one'.freeze
  IDRIVE_BMR = 'idrive_bmr'.freeze
  IDRIVE_BMR_UPLOAD = 'idrive_bmr_upload'.freeze
  IDRIVE_BMR_RESTORE = 'idrive_bmr_restore'.freeze
  IDRIVE360_UPLOAD = 'idrive360_upload'.freeze
  IDRIVE360_RESTORE = 'idrive360_restore'.freeze
  IBACKUP_UPLOAD = 'ibackup_upload'.freeze
  IBACKUP_RESTORE = 'ibackup_restore'.freeze
  ORDER_TYPES = [
    IDRIVE_UPLOAD,
    IDRIVE_RESTORE,
    IDRIVE_ONE,
    IDRIVE_BMR,
    IDRIVE_BMR_UPLOAD,
    IDRIVE_BMR_RESTORE,
    IDRIVE360_UPLOAD,
    IDRIVE360_RESTORE,
    IBACKUP_UPLOAD,
    IBACKUP_RESTORE
  ].freeze

  def full_name
    "#{product.name} #{name}"
  end

  def key=(key)
    super(key.try(:downcase))
  end

  def key_is?(*keys)
    keys.each do |k|
      return true if key.to_sym == k.to_sym
    rescue NoMethodError
      # nil..
    end
    false
  end
end
