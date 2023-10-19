class CSVFile
  include ActiveModel::Model
  attr_accessor :file
  attr_accessor :records_processed, :records_updated, :success

  validate :file_is_present?
  validate :file_is_readable?

  def self.human_attribute_name(attr, _options = {})
    attr.to_s.humanize
  end

  def self.lookup_ancestors
    [self]
  end

  def initialize(attributes = {})
    super
    @success = false
    @records_processed = 0
    @records_updated = 0
  end

  def errors
    @errors ||= ActiveModel::Errors.new(self)
  end

  # wrapper around File.read but ensures content will only contain valid UTF-8
  def read
    return unless valid?

    contents = if file.respond_to? :read
                 file.read
               else
                 file
               end
    contents.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
  end

  def read_attribute_for_validation(attr)
    send(attr)
  end

  def success?
    success
  end

  def warnings
    @warnings ||= ActiveModel::Errors.new(self)
  end

  private

  def file_is_present?
    errors.add(:file, 'does not exist') if file.blank?
  rescue ArgumentError
    # binary type files can raise a "invalid byte sequence in UTF-8". we are
    # ok for now, at least something is here.
  end

  def file_is_readable?
    errors.add(:file, 'is not readable') unless file.is_a?(String) || file.respond_to?(:read)
  end
end
