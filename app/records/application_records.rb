class ApplicationRecords
  # ApplicationRecords is responsible for managing "core" records in the
  # database. At a high level this class will load a `.yml` file and loop
  # through all records in it.
  #
  # First it will attempt to find the record using the `core` dict attributes.
  # If found, it will either update the record by merging the `core` and
  # `update` attribute dicts together or note that the record is up-to-date. If
  # the record is not found, it will create a new record in the database by
  # merging the `core`, `update` and `create` dicts together.
  #
  # Note that order of record processing matters because of model
  # relationships. The record files should by prefixed with a number (ie
  # "030-destination.yml") so that lower level relationships will be created
  # first before their dependent records.

  attr_reader :records

  RECORDS_DIR = Rails.root.join('app', 'records', 'records')

  def self.seed!(**kwargs)
    Dir.glob(RECORDS_DIR.join('*.yml'))
       .sort
       .map { |p| File.basename(p, '.yml') }
       .each do |record|
      ApplicationRecords.new(record, **kwargs).seed!
    end
  end

  def initialize(records, dry_run: false)
    records_file = YAML.load_file(RECORDS_DIR.join("#{records}.yml"))
    @records = records_file['records']
    @model_class = resolve_model_class!(records_file['model_class'])
    @dry_run = dry_run
  end

  def build_attrs(raw_attrs)
    attrs = {}
    raw_attrs.each do |attribute, value|
      begin
        value = resolve_model_class!(attribute).find_by! value if value.is_a? Hash
      rescue ActiveRecord::RecordNotFound
        Rails.logger.error "Association not found: find_by=#{value}"
        raise unless @dry_run

        value = nil
      end
      attrs[attribute] = value
    end
    attrs
  end

  # create one record
  def create!(attrs)
    create_attrs = build_attrs(
      attrs['core']
        .merge(attrs.fetch('update', {}))
          .merge(attrs.fetch('create', {}))
    )

    record = @model_class.new(create_attrs)
    record.save! unless @dry_run
    Rails.logger.info "Created #{record.class.name} "\
                      "##{record.id}: #{create_attrs}"
  end

  # find a given record and update it with the given attributes if needed
  def find_and_update!(attrs)
    record = @model_class.find_by! attrs['core']
    update_attrs = build_attrs(attrs['core'].merge(attrs.fetch('update', {})))
    record.assign_attributes(update_attrs)
    if record.changed?
      record.save! unless @dry_run
      Rails.logger.info "Updated #{record.class.name} ##{record.id}: "\
                        "from=#{record.previous_changes} to=#{update_attrs}"
      true
    else
      Rails.logger.info "Found #{record.class.name} ##{record.id}: "\
                        "find_by=#{attrs['core']}"
      false
    end
  end

  def resolve_model_class!(model_name)
    model_class = model_name.camelize.constantize
    raise "Not a rails model: #{model_class}" unless model_class.ancestors.include? ApplicationRecord

    model_class
  end

  # seed the DB with data and keep records up to date
  def seed!
    Rails.logger.info "Start seeding records: model=#{@model_class.name} dry_run=#{@dry_run}"
    @records.each do |record|
      find_and_update!(record)
    rescue ActiveRecord::RecordNotFound
      create!(record)
    end
    Rails.logger.info "Finish seeding records: model=#{@model_class.name} dry_run=#{@dry_run}"
  end
end
