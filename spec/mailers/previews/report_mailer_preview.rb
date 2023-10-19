# Preview all emails at http://localhost:3000/rails/mailers/report_mailer
class ReportMailerPreview < ActionMailer::Preview
  def report_results
    report_ids = Report.pluck(:id)
    ReportMailer.report_results(Report.find(report_ids.sample))
  end
end
