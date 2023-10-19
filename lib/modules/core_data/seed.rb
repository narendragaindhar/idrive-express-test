module CoreData
  module Seed
    ROOT = File.dirname(File.dirname(File.dirname(File.dirname(File.absolute_path(__FILE__)))))
    SEED_DIR = File.join(ROOT, 'db/seeds')

    def self.seed(seeds, seed_dir: SEED_DIR)
      return if seeds.empty?

      puts "Starting data seed from #{seeds.count} file(s)"
      puts "Verifying seed files present in #{seed_dir}: #{seeds.join(', ')}"
      seeds = expand_paths(seeds, seed_dir)
      ensure_present!(seeds)

      puts 'Seeding data'
      seeds.each do |seed|
        run!(seed)
      end

      puts 'Seeding completed'
    end

    def self.expand_paths(seeds, seed_dir)
      seeds.map do |seed|
        File.join(seed_dir, seed)
      end
    end

    def self.ensure_present!(seeds)
      seeds.each do |seed|
        raise ArgumentError, "Seed file does not exist: \"#{seed}\"" unless File.exist?(seed)
      end
    end

    def self.run!(seed)
      command = "rails runner '#{seed}'"
      puts command
      return if system(command)
      raise "Command failed: #{command}"
    end
  end
end
