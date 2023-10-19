require 'rails_helper'

RSpec.describe Product do
  let(:product_idrive) { build_stubbed(:product_idrive) }
  let(:product_ibackup) { build_stubbed(:product_ibackup) }
  let(:product_idrive360) { build_stubbed(:product_idrive360) }

  describe '.customers' do
    it 'returns the association' do
      expect(product_ibackup.customers).to eq([])
    end
  end

  describe '#is?' do
    it 'does successful comparison with a string' do
      expect(product_idrive.is?('idrive')).to eq(true)
    end

    it 'does failure comparison with a string' do
      expect(product_idrive.is?('ibackup')).to eq(false)
    end

    it 'does successful comparison with a symbol' do
      expect(product_idrive.is?(:idrive)).to eq(true)
    end

    it 'does failure comparison with a symbol' do
      expect(product_idrive.is?(:ibackup)).to eq(false)
    end

    it 'does successful comparison with a regex' do
      expect(product_idrive.is?(/i(drive|backup|drive360)/i)).to eq(true)
    end

    it 'does failure comparison with a regex' do
      expect(product_idrive.is?(/idrive/)).to eq(false)
    end

    it 'does successful comparison with a string for idrive360' do
      expect(product_idrive360.is?('idrive360')).to eq(true)
    end
  end

  describe '#valid?' do
    describe 'name' do
      it 'is required (nil)' do
        expect(build(:product, name: nil)).not_to be_valid
      end

      it 'is required (blank)' do
        expect(build(:product, name: '')).not_to be_valid
      end

      it 'is unique' do
        create(:product_idrive)
        expect(build(:product_idrive)).not_to be_valid
      end
    end
  end
end
