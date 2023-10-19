require 'tempfile'
require 'spec_helper'
require 'modules/release'

RSpec.describe Release do
  let(:version) { Release::Version.new(1, 2, 3) }
  let(:version_file) { Tempfile.new(File.basename(__FILE__)) }

  before do
    version_file.write("#{version}\n")
    version_file.flush
    version_file.close
  end

  after do
    version_file.close!
  end

  describe '.current_version' do
    it 'gets version information from a file' do
      expect(described_class.current_version(version_file.path)).to eq(version)
    end
  end

  describe '.update_version' do
    it 'can update version information to a file' do
      described_class.update_version(version_file.path, version.bump('minor'))
      expect(version_file.open.read).to eq("1.3.0\n")
    end
  end
end
