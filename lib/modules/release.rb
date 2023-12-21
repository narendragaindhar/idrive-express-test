module Release
  VERSION_FILE = 'config/version'.freeze
  ROOT = File.dirname(File.dirname(File.dirname(File.absolute_path(__FILE__))))

  def self.release(level, version_file: VERSION_FILE)
    version_file_abs_path = File.join(ROOT, version_file)

    ensure_clean! version_file
    puts "Releasing a new #{level} version..."
    version = current_version version_file_abs_path
    puts "Current version: #{version}"
    version = version.bump level
    puts "New version: #{version}"
    update_version version_file_abs_path, version
    puts 'Commiting changes'
    commit version_file, version
    puts 'push to main'
    push_to_main
    puts 'Tagging release'
    tag version
    puts 'Pushing tag to remote'
    push_tag version
    puts 'Delete local tag'
    delete_local_tag version
  end

  def self.ensure_clean!(file)
    return unless `git status '#{file}'`.match?(/^\s+modified:\s+#{file}$/)
    raise "#{file} is dirty. Please commit your changes and run again."
  end

  def self.current_version(version_file)
    Release::Version.new(*File.read(version_file).strip.split('.').map(&:to_i))
  end

  def self.update_version(version_file, version)
    File.open(version_file, 'w') do |f|
      f.write("#{version}\n")
    end
  end

  def self.commit(version_file, version)
    run!("git add -a '#{version_file}' && git commit --message 'Bumping version to #{version}'")
  end
  
  def self.push_to_main
    run!('git push origin main')
  end

  def self.tag(version)
    run!("git tag -a '#{version.to_tag}' --message 'Release #{version.to_tag}' main")
  end

  def self.push_tag(version)
    #run!('git push origin main')
    run!("git push origin '#{version.to_tag}'")
  end

  def self.delete_local_tag(version)
    run!("git tag -d '#{version.to_tag}'")
  end

  def self.run!(command)
    puts command
    raise "Command failed: #{command}" unless system(command)
  end
end

require_relative 'release/version'
