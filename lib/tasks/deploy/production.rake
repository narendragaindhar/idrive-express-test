namespace :deploy do
  desc 'runs all tasks that should be done when deploying to production'
  task production: :environment do
    RUN_MIGRATIONS = ENV.fetch('EXPRESS_RUN_MIGRATIONS', '').strip
    Rake::Task['db:migrate'].invoke if RUN_MIGRATIONS.present? && RUN_MIGRATIONS != '0'
    Rake::Task['core_data:seed_records'].invoke
    Rake::Task['core_data:seed'].invoke
  end
end
