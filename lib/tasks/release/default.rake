require Rails.root.join('lib', 'modules', 'release')

namespace :release do
  desc 'Release a new patch version of the app (x.y.Z)'
  task patch: :environment do
    Release.release('patch')
  end

  desc 'Release a new minor version of the app (x.Y.z)'
  task minor: :environment do
    Release.release('minor')
  end

  desc 'Release a new major version of the app (X.y.z)'
  task major: :environment do
    Release.release('major')
  end
end

desc 'Release a new patch version of the app (x.y.Z)'
task release: 'release:patch'
