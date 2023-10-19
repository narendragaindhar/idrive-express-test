namespace :deploy do
  desc 'runs all tasks that should be done when deploying to staging'
  task staging: :environment do
    Rake::Task['db:migrate'].invoke
    Rake::Task['core_data:seed_records'].invoke
    Rake::Task['core_data:seed'].invoke
  end
end
