class Report < ApplicationRecord
  FREQUENCIES = %w[daily weekly monthly].freeze

  # validation
  validates :name, presence: true, length: { maximum: 255 }
  validates :query, presence: true
  validates :frequency,
            allow_nil: true,
            inclusion: { in: FREQUENCIES, message: 'is not a valid frequency' }
  validates :recipients, length: { maximum: 255 }
  validate :valid_query?
  validate :valid_recipients?

  def frequency=(frequency)
    super(frequency.presence)
  end

  def recipients=(recipients)
    super(recipients.presence)
  end

  def recipients_list
    recipients.split(',').map(&:strip)
  rescue NoMethodError
    [] # nil...
  end

  def result
    @result ||= Readonly::Query.exec_query(query)
  end

  def result_count
    @result_count ||= result.length
  end

  def valid_recipients?
    return true if recipients.blank?

    all_valid = recipients_list.all? do |recipient|
      recipient =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
    end
    errors.add(:recipients, 'has an invalid email address') unless all_valid
    all_valid
  end

  def valid_query?
    result
    result_count
    true
  rescue ActiveRecord::StatementInvalid => e
    errors.add(:query, "is invalid: #{e}")
    false
  end
end
