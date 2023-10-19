require Rails.root.join('lib', 'modules', 'core_data')

namespace :core_data do
  desc 'execute `rails runner` on seed files from db/seeds named in '\
       'EXPRESS_SEED environmental variable. can specify multiple files '\
       'by separating filenames with spaces'
  task seed: :environment do
    seeds = ENV.fetch('EXPRESS_SEED', '').strip.split
    CoreData::Seed.seed(seeds)
  end
end
