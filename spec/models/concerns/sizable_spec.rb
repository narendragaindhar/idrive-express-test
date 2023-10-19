require 'rails_helper'

RSpec.describe Sizable do
  let(:klass) do
    Struct.new(:size) do
      include Sizable
    end
  end
  # 1gb
  let(:sizable) { klass.new(1_073_741_824) }

  describe '.to_bytes' do
    it 'converts TB to bytes' do
      expect(described_class.to_bytes(1, 'tb')).to eq(1_099_511_627_776)
    end
  end

  describe '::ClassMethods' do
    describe '.sizable_attr' do
      it 'returns the default attr if nothing is set' do
        expect(klass.sizable_attr).to eq(:size)
      end
    end

    describe '.sizable_attr=' do
      it 'returns the override if it is set' do
        klass.sizable_attr = :the_size
        expect(klass.sizable_attr).to eq(:the_size)
      end
    end
  end

  describe '::InstanceMethods' do
    describe '#humanize_size' do
      it 'returns a human friendly version of the size' do
        expect(sizable.humanize_size).to eq('1 GB')
      end

      it 'returns a blank string if not present' do
        sizable.size = nil
        expect(sizable.humanize_size).to eq('')
      end
    end

    describe '#size_count' do
      it 'returns the number part of the size string' do
        expect(sizable.size_count).to eq('1')
      end

      it 'returns nil if nothing is set' do
        sizable.size = nil
        expect(sizable.size_count).to be_nil
      end
    end

    describe '#size_count=' do
      it 'sets the number part of the size string' do
        sizable.size = nil
        sizable.size_count = '2'
        expect(sizable.size_count).to eq('2')
      end

      it 'sets the :size attribute if size_units is also there' do
        sizable.size_units = 'GB'
        sizable.size_count = '2'
        expect(sizable.size).to eq(2_147_483_648)
      end
    end

    describe '#size_units' do
      it 'returns the unit part of the size' do
        expect(sizable.size_units).to eq('GB')
      end

      it 'normalizes the units when bytes is < 1024' do
        sizable.size = 512
        expect(sizable.size_units).to eq('B')
      end
    end

    describe '#size_units=' do
      it 'sets the units part of the size' do
        sizable.size = nil
        sizable.size_units = 'TB'
        expect(sizable.size_units).to eq('TB')
      end

      it 'sets the :size attribute if size_count is also there' do
        sizable.size_count = '1'
        sizable.size_units = 'TB'
        expect(sizable.size).to eq(1_099_511_627_776)
      end
    end
  end
end
