class ReportMailer < ApplicationMailer
  # send the results of the report to all recipients
  def report_results(report)
    @report = report
    @subject = "Express#{' ' << @report.frequency if @report.frequency.present?} report: #{@report.name}"
    attachments["#{@report.name.parameterize}.csv"] = {
      mime_type: 'text/csv',
      content: generate_csv
    }
    mail to: @report.recipients_list, subject: @subject, reply_to: nil
  end

  private

  def generate_csv
    CSV.generate do |csv|
      csv << @report.result.columns.map(&:humanize)
      @report.result.rows.each do |row|
        csv << row
      end
    end
  end
end
