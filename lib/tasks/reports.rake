# handles running of reports that match a certain frequency

REPORTS = {
  daily: -> { true },
  weekly: -> { Time.now.utc.monday? },
  monthly: -> { Time.now.utc.day == 1 }
}.freeze

namespace :reports do
  REPORTS.each do |frequency, run_condition|
    desc "Run the #{frequency} reports and send an email to all recipients"
    task frequency => :environment do
      should_run = run_condition.call
      force = ENV.fetch('EXPRESS_REPORTS_FORCE', false).present?
      puts "Starting report: frequency=#{frequency} "\
           "should_run=#{should_run} " \
           "force=#{force}"

      if should_run || force
        puts "Running report: #{frequency}"
        ReportingJob.perform_later(frequency.to_s)
      end
    end
  end
end
