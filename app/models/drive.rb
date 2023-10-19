class Drive < ApplicationRecord
  include Sizable

  has_many :drive_events, dependent: :restrict_with_exception
  has_many :orders, dependent: :restrict_with_exception

  validates :active, inclusion: { in: [true, false] }
  validates :identification_number,
            presence: true,
            length: { maximum: 255 },
            uniqueness: { scope: :serial }
  validates :in_use, inclusion: { in: [true, false] }
  validates :serial,
            presence: true,
            length: { maximum: 255 }
  validates :size,
            presence: true,
            numericality: { greater_than: 0, only_integer: true }
  validates :size_count, presence: true
  validates :size_units, presence: true

  # scopes
  scope :available, lambda {
    where(active: true)
      .order(in_use: :asc, identification_number: :asc, serial: :asc)
  }
  scope :search, lambda { |query|
    if query.present?
      where('`serial` LIKE ? OR `identification_number` LIKE ?',
            "#{query}%", "#{query}%")
    end
  }

  after_initialize do
    if new_record?
      self.active = true if active.nil?
      self.in_use ||= false
    end
  end

  def label(short: false)
    return '' unless persisted?

    parts = []
    parts << "#{identification_number} (#{serial})"
    unless short
      parts << humanize_size
      parts << (in_use ? 'In use' : 'Available')
    end
    parts.join(' | ')
  end
end
