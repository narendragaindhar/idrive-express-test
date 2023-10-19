require 'rails_helper'

RSpec.describe Drive do
  # 500 GB
  let(:drive) { create(:drive, size: 536_870_912_000) }

  describe '::Sizable concern' do
    it 'has humanize_size available to it' do
      expect(drive.humanize_size).to eq('500 GB')
    end

    it 'has size_count available to it' do
      expect(drive.size_count).to eq('500')
    end

    it 'has size_units available to it' do
      expect(drive.size_units).to eq('GB')
    end

    it 'can update the size attribute' do
      drive.update(size_count: '2', size_units: 'TB')
      expect(drive.size).to eq(2_199_023_255_552)
    end
  end

  describe '.after_initialize' do
    it 'is active by default if it is a new record' do
      drive = described_class.new(attributes_for(:drive, active: nil))
      expect(drive.active).to eq(true)
    end

    it 'allows setting active to false as a new record' do
      drive = described_class.new(attributes_for(:drive, active: false))
      expect(drive.active).to eq(false)
    end

    it 'is not in_use by default if it is a new record' do
      drive = described_class.new(attributes_for(:drive, in_use: nil))
      expect(drive.in_use).to eq(false)
    end
  end

  describe '.available' do
    it 'returns an ordered list of available drives for use' do
      create(:drive, active: false, identification_number: 'CC', serial: 'BB')
      drive_a = create(:drive, identification_number: 'AA', serial: 'MM')
      drive_d = create(:drive, in_use: true, identification_number: 'DD', serial: 'ZZ')
      drive_b = create(:drive, identification_number: 'BB', serial: 'EE')
      drive_a2 = create(:drive, identification_number: 'AA', serial: 'BB')
      drive_a3 = create(:drive, in_use: true, identification_number: 'AA', serial: 'XX')

      expect(described_class.available).to eq([drive_a2, drive_a, drive_b, drive_a3, drive_d])
    end
  end

  describe '.search' do
    let!(:drive_1) { create(:drive, identification_number: 'ABC', serial: '123') }
    let!(:drive_2) { create(:drive, identification_number: 'GHI', serial: '456') }

    it 'returns drives matching serial' do
      expect(described_class.search('ABC')).to eq([drive_1])
    end

    it 'returns drives matching identification_number' do
      expect(described_class.search('456')).to eq([drive_2])
    end

    it 'only matches fields starting with the query' do
      expect(described_class.search('BC')).to eq([])
    end

    it 'does not filter if nothing provided' do
      expect(described_class.search(nil)).to eq([drive_1, drive_2])
    end
  end

  describe '#label' do
    it 'returns friendly short string to describe the drive' do
      drive = create(:drive, identification_number: 'F012847', serial: 'E84927', size: 536_870_912_000)
      expect(drive.label(short: true)).to eq('F012847 (E84927)')
    end

    it 'returns friendly long string to describe the drive' do
      drive = create(:drive, identification_number: 'F012847', serial: 'E84927', size: 536_870_912_000)
      expect(drive.label).to eq('F012847 (E84927) | 500 GB | Available')
    end

    it 'show the status of the drive' do
      drive = create(:drive, in_use: true, identification_number: 'J8829082', serial: 'N9928', size: 4_398_046_511_104)
      expect(drive.label).to eq('J8829082 (N9928) | 4 TB | In use')
    end

    it 'is blank if its a new record' do
      expect(build(:drive).label).to eq('')
    end
  end

  describe '#validate' do
    describe 'identification_number' do
      it 'is required (nil)' do
        expect(build(:drive, identification_number: nil)).not_to be_valid
      end

      it 'is required (blank)' do
        expect(build(:drive, identification_number: '')).not_to be_valid
      end

      it 'is <= 255 characters' do
        identification_number = 'a' * 256
        expect(build(:drive, identification_number: identification_number)).not_to be_valid
      end

      it 'and serial are unique' do
        create(:drive, identification_number: '1234', serial: '5678')
        expect(build(:drive, identification_number: '1234', serial: '5678')).not_to be_valid
      end

      it 'and serial are unique in the DB' do
        create(:drive, identification_number: '1234', serial: '5678')
        expect do
          create(:drive, identification_number: '1234', serial: '5678')
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    describe 'serial' do
      it 'is required (nil)' do
        expect(build(:drive, serial: nil)).not_to be_valid
      end

      it 'is required (blank)' do
        expect(build(:drive, serial: '')).not_to be_valid
      end

      it 'is <= 255 characters' do
        serial = 'a' * 256
        expect(build(:drive, serial: serial)).not_to be_valid
      end
    end

    describe 'size' do
      it 'is required (nil)' do
        expect(build(:drive, size: nil)).not_to be_valid
      end

      it 'is required (blank)' do
        expect(build(:drive, size: '')).not_to be_valid
      end

      it 'is >= 0' do
        expect(build(:drive, size: -1)).not_to be_valid
      end

      it 'is an integer' do
        expect(build(:drive, size: 50.1)).not_to be_valid
      end
    end
  end
end
