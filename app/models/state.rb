class State < ApplicationRecord
  belongs_to :order_type
  has_many :order_states, dependent: :restrict_with_exception
  has_many :orders, dependent: :restrict_with_exception,
                    inverse_of: :states,
                    through: :order_states

  validates :active, inclusion: { in: [true, false] }
  validates :is_drive_event, inclusion: { in: [true, false] }
  validates :key,
            allow_blank: true,
            length: { maximum: 255 },
            uniqueness: true,
            format: { with: /\A[a-z0-9_]{3,}\Z/,
                      message: 'must be at least 3 lowercase alphanumeric characters (or "_")' }
  validates :label,
            presence: true,
            length: { maximum: 255 }
  validates :notify_by_default, inclusion: { in: [true, false] }
  validates :order_type, presence: true
  validates :percentage,
            presence: true,
            numericality: { greater_than_or_equal_to: 0,
                            less_than_or_equal_to: 100,
                            only_integer: true }
  validates :public_by_default, inclusion: { in: [true, false] }
  validates :is_out_of_our_hands, inclusion: { in: [true, false] }
  validates :leaves_us, inclusion: { in: [true, false] }

  # initial state mappings: order_type.key => state.key
  INITIAL_STATES = {
    'idrive_upload' => 'upload_order_created',
    'idrive_restore' => 'restore_order_created',
    'idrive_one' => 'idrive_one_order_created',
    'idrive_bmr' => 'idrive_bmr_order_created',
    'idrive_bmr_upload' => 'idrive_bmr_upload_order_created',
    'idrive_bmr_restore' => 'idrive_bmr_restore_order_created',
    'idrive360_upload' => 'idrive360_upload_order_created',
    'idrive360_restore' => 'idrive360_restore_order_created',
    'ibackup_upload' => 'ibackup_upload_order_created',
    'ibackup_restore' => 'ibackup_restore_order_created'
  }.freeze
  # states that indicate an order has successfully ended
  SUCCESSFUL_ENDINGS = %w[
    upload_order_completed
    restore_order_completed
    idrive_one_order_shipped
    idrive_bmr_order_shipped
    idrive_bmr_upload_order_completed
    idrive_bmr_restore_order_completed
    idrive360_upload_order_completed
    idrive360_restore_order_completed
    ibackup_upload_order_completed
    ibackup_restore_order_completed
  ].freeze

  # scopes
  scope :usable, ->(order_type) { where(order_type: order_type, active: true).by_percentage }
  scope :by_percentage, -> { order(percentage: :asc) }

  # given a certain express order, get the first state that occurs in the
  # process
  def self.get_initial_state(order_type)
    find_by key: INITIAL_STATES.fetch(order_type.key)
  end

  after_initialize do
    self.active = true if new_record? && active != false
  end

  # does the state successfully complete an order
  def completes_successfully?
    SUCCESSFUL_ENDINGS.include?(key)
  end

  def key=(key)
    super(key.try(:downcase))
  end

  def label_and_percentage
    "#{label} - #{percentage}%#{percentage == 100 ? ' (Completes order)' : ''}"
  end
end
