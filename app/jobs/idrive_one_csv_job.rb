class IDriveOneCSVJob < ApplicationJob
  queue_as :default

  def perform(csv_file_content, user)
    csv_file = IDriveOneCSVService.new(CSVFile.new(file: csv_file_content), user).process
    if csv_file.success?
      Rails.logger.info ['IDriveOneCSVService#perform finished:',
                         "warnings=#{csv_file.warnings.full_messages}",
                         "records_processed=#{csv_file.records_processed}",
                         "records_updated=#{csv_file.records_updated}"].join(' ')
    else
      Rails.logger.error ['IDriveOneCSVService#perform failed:',
                          "errors=#{csv_file.errors.full_messages}",
                          "warnings=#{csv_file.warnings.full_messages}"].join(' ')
    end
  end
end
