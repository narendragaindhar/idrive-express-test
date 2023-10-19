namespace :core_data do
  desc 'ensure all core data records have been seeded & updated in the db'
  task seed_records: :environment do
    dry_run = ENV.fetch('EXPRESS_CORE_DATA_DRY_RUN', '').strip
    dry_run = dry_run.present? && dry_run != '0'

    ApplicationRecords.seed! dry_run: dry_run
  end
end
