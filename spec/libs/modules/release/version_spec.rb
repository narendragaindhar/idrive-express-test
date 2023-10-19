require 'modules/release/version'

RSpec.describe Release::Version do
  let(:version) { described_class.new(1, 2, 3) }

  it 'can bump the patch level' do
    expect(version.bump('patch')).to eq(described_class.new(1, 2, 4))
  end

  it 'can bump the minor level' do
    expect(version.bump('minor')).to eq(described_class.new(1, 3, 0))
  end

  it 'can bump the major level' do
    expect(version.bump('major')).to eq(described_class.new(2, 0, 0))
  end

  it 'doesn\'t bump unknown levels' do
    expect do
      version.bump('blar')
    end.to raise_error(ArgumentError)
  end

  it 'goes to string' do
    expect(version.to_s).to eq('1.2.3')
  end

  it 'goes to tag' do
    expect(version.to_tag).to eq('v1.2.3')
  end
end
