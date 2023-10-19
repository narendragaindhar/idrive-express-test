require 'rails_helper'

RSpec.describe Destination do
  describe '.after_initialize' do
    it 'becomes active by default if it is a new record' do
      destination = described_class.new(attributes_for(:destination_alchemy, active: nil))
      expect(destination.active).to eq(true)
    end
  end

  describe '.create' do
    it 'can make a viawest destination' do
      expect { create(:destination_viawest_1) }.not_to raise_error
    end

    it 'can make a alchemy destination' do
      expect { create(:destination_alchemy) }.not_to raise_error
    end

    it 'can make a office destination' do
      expect { create(:destination_office) }.not_to raise_error
    end

    it 'can make a iron mountain destination' do
      expect { create(:destination_iron_mountain) }.not_to raise_error
    end

    it 'can make a viatel destination' do
      expect { create(:destination_viatel) }.not_to raise_error
    end
  end

  describe '#key=' do
    it 'downcases keys' do
      expect(build(:destination_alchemy, key: 'UPPERCASE').key).to eq('uppercase')
    end
  end

  describe '#validate' do
    describe 'address' do
      it 'is required (nil)' do
        expect(build(:destination_alchemy, address: nil)).not_to be_valid
      end
    end

    describe 'key' do
      it 'is required (nil)' do
        expect(build(:destination_alchemy, key: nil)).not_to be_valid
      end

      it 'is required (blank)' do
        expect(build(:destination_alchemy, key: '')).not_to be_valid
      end

      it 'is sensible' do
        expect(build(:destination_alchemy, key: 'craz¥ stuffs 999')).not_to be_valid
      end

      it 'is unique' do
        create(:destination_alchemy, key: 'dup_key')
        expect(build(:destination_alchemy, key: 'dup_key')).not_to be_valid
      end
    end

    describe 'name' do
      it 'is required (nil)' do
        expect(build(:destination_alchemy, name: nil)).not_to be_valid
      end

      it 'is required (blank)' do
        expect(build(:destination_alchemy, name: '')).not_to be_valid
      end
    end
  end
end
