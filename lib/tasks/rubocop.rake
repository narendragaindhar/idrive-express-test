begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError => e
  raise e unless Rails.env.production? # gem is not present on production
end
