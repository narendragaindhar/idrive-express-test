require 'fileutils'
require 'spec_helper'
require 'modules/core_data/seed'

RSpec.describe CoreData::Seed do
  it 'takes a list of files and expands them to the expected full path' do
    expect(described_class.expand_paths(['one.rb', 'two.rb'], '/dir/name')).to eq(
      ['/dir/name/one.rb', '/dir/name/two.rb']
    )
  end

  describe '.ensure_present!' do
    let(:seed_dir) { Dir.mktmpdir }
    let(:seed_file) { File.join(seed_dir, 'seed.rb') }
    let(:seed_file_2) { File.join(seed_dir, 'seed2.rb') }

    before do
      FileUtils.touch(seed_file)
      FileUtils.touch(seed_file_2)
    end

    after do
      FileUtils.remove_entry seed_dir
    end

    it 'raises an error if a seed file is not present' do
      expect do
        described_class.ensure_present!([File.join(seed_dir, 'nothere.rb')])
      end.to raise_error ArgumentError
    end

    it 'verifies all seed files are present' do
      expect do
        described_class.ensure_present!([seed_file, seed_file_2])
      end.not_to raise_error
    end
  end
end
