require 'rails_helper'

RSpec.describe Address do
  describe '#outside_usa?' do
    it 'returns true for addresses falling outside of usa' do
      %w[Finland Mexico England China Россия इंडिया].each do |country|
        address = create(:address, country: country)
        expect(address.outside_usa?).to eq(true), "#{country} should be outside USA"
      end
    end

    it 'returns false for addresses falling inside of usa' do
      ['USA', 'U.S.A', 'usa', 'united states', 'united states of america',
       'United States of America', 'America', 'america'].each do |country|
        address = create(:address, country: country)
        expect(address.outside_usa?).to eq(false), "#{country} should be inside USA"
      end
    end

    it 'returns false for undefined country' do
      address = build(:address, country: nil)
      expect(address.outside_usa?).to eq(false)
    end
  end

  describe '#to_field' do
    it 'works if just recipient is set' do
      expect(create(:address, recipient: 'Darth Vader', organization: nil).to_field).to eq('Darth Vader')
    end

    it 'works if just organization is set' do
      expect(create(:address, recipient: nil, organization: 'Death Star').to_field).to eq('Death Star')
    end

    it 'works if both recipient and organization is set' do
      expect(
        create(:address, recipient: 'Darth Vader', organization: 'Death Star').to_field
      ).to eq('Darth Vader c/o Death Star')
    end
  end

  describe '#validate' do
    describe 'address' do
      it 'is required (nil)' do
        expect(build(:address, address: nil)).not_to be_valid
      end

      it 'is required (blank)' do
        expect(build(:address, address: '')).not_to be_valid
      end

      it 'is <= 255 characters' do
        address = 'a' * 256
        expect(build(:address, address: address)).not_to be_valid
      end
    end

    describe 'city' do
      it 'is required (nil)' do
        expect(build(:address, city: nil)).not_to be_valid
      end

      it 'is required (blank)' do
        expect(build(:address, city: '')).not_to be_valid
      end

      it 'is <= 255 characters' do
        city = 'a' * 256
        expect(build(:address, city: city)).not_to be_valid
      end
    end

    describe 'country' do
      it 'is required (nil)' do
        expect(build(:address, country: nil)).not_to be_valid
      end

      it 'is required (blank)' do
        expect(build(:address, country: '')).not_to be_valid
      end

      it 'is <= 255 characters' do
        country = 'a' * 256
        expect(build(:address, country: country)).not_to be_valid
      end
    end

    describe 'recipient' do
      it 'is required if organization is missing (nil)' do
        expect(build(:address, recipient: nil, organization: nil)).not_to be_valid
      end

      it 'is required if organization is missing (blank)' do
        expect(build(:address, recipient: '', organization: '')).not_to be_valid
      end

      it 'is <= 255 characters' do
        recipient = 'a' * 256
        expect(build(:address, recipient: recipient)).not_to be_valid
      end
    end

    describe 'organization' do
      it 'is <= 255 characters' do
        organization = 'a' * 256
        expect(build(:address, organization: organization)).not_to be_valid
      end
    end

    describe 'zip' do
      it 'is required (nil)' do
        expect(build(:address, zip: nil)).not_to be_valid
      end

      it 'is required (blank)' do
        expect(build(:address, zip: '')).not_to be_valid
      end

      it 'is <= 255 characters' do
        zip = 'a' * 256
        expect(build(:address, zip: zip)).not_to be_valid
      end
    end
  end
end
