class ReportingJob < ApplicationJob
  queue_as :default

  def perform(frequency_or_report)
    if frequency_or_report.is_a? Report
      send_email(frequency_or_report)
    else
      Report.where(frequency: frequency_or_report)
            .where('`recipients` IS NOT NULL')
            .find_each(&method(:send_email))
    end
  end

  private

  def send_email(report)
    ReportMailer.report_results(report).deliver_now
  end
end
