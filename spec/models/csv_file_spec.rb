require 'rails_helper'

RSpec.describe CSVFile, type: :model do
  let(:csv_file) do
    tempfile = Tempfile.open('csv_file')
    CSV.open(tempfile.path, 'wb', headers: :first_row) do |csv|
      csv << ['IDriveStaff', 'JW No.', 'Status', 'Ticket number', 'Username', 'PD', 'Name', 'Street', 'City', 'State', 'Zip code', 'Country', 'MAC number', 'HDD S/N', 'Tracking number', 'Responed to customer', 'Date Ordered', 'Promo Code', 'OrderID', 'Notes'] # rubocop:disable Metrics/LineLength
    end
    tempfile
  end
  let(:csv_file_attrs) do
    { file: ActionDispatch::Http::UploadedFile.new(tempfile: csv_file) }
  end
  let(:csv) { described_class.new(csv_file_attrs) }

  after do
    File.unlink(csv_file) if File.exist?(csv_file)
  end

  describe '#initialize' do
    it 'sets the defaults' do
      expect(csv.success).to eq(false)
      expect(csv.success?).to eq(false)
      expect(csv.records_processed).to eq(0)
      expect(csv.records_updated).to eq(0)
    end
  end

  describe '#errors' do
    it 'can add errors' do
      csv.errors.add(:file, 'Invalid')
      expect(csv.errors[:file]).to include('Invalid')
    end
  end

  describe '#read' do
    it 'works for strings' do
      expect(described_class.new(file: 'hi').read).to eq('hi')
    end

    it 'works for file objects' do
      contents = csv_file.read
      csv_file.rewind
      expect(csv.read).to eq(contents)
    end

    it 'returns nil if not valid' do
      expect(described_class.new(file: nil).read).to eq(nil)
    end

    # it 'forces valid UTF-8 encoding on the file' do
    #  contents = file_fixture('csv_file/not_a_csv.txt').read
    #  expect(contents).to receive(:encode).and_call_original
    #  CSVFile.new(file: contents).read
    # end
  end

  describe '#records_processed' do
    it 'can be set' do
      csv.records_processed = 10
      expect(csv.records_processed).to eq(10)
    end
  end

  describe '#records_updated' do
    it 'can be set' do
      csv.records_processed = 5
      expect(csv.records_processed).to eq(5)
    end
  end

  describe '#success' do
    it 'can be set' do
      csv.success = true
      expect(csv.success).to eq(true)
      expect(csv.success?).to eq(true)
    end
  end

  describe '#validate' do
    describe 'file' do
      it 'is invalid if nil' do
        csv = described_class.new(file: nil)
        expect(csv.valid?).to be(false)
        expect(csv.errors[:file]).to include('does not exist')
      end

      it 'is invalid if it is a blank string' do
        csv = described_class.new(file: '')
        expect(csv).not_to be_valid
        expect(csv.errors[:file]).to include('does not exist')
      end

      it 'is invalid if not a String or file-like object' do
        csv = described_class.new(file: {})
        expect(csv.valid?).to be(false)
        expect(csv.errors[:file]).to include('is not readable')
      end

      it 'is valid if it is a string' do
        expect(described_class.new(file: csv_file.read)).to be_valid
      end

      it 'is valid even for binary type contents' do
        expect(described_class.new(file: file_fixture('csv_file/not_a_csv.gif').read)).to be_valid
      end

      it 'is valid if object is file-like' do
        expect(csv).to be_valid
      end
    end
  end

  describe '#warnings' do
    it 'can add warnings' do
      csv.warnings.add(:file, 'line 5 is silly')
      expect(csv.warnings[:file]).to include('line 5 is silly')
    end

    describe '#full_messages' do
      it 'appears correctly' do
        csv.warnings.add(:file, 'line #113: Order #62 not for IDrive One')
        csv.warnings.add(:file, 'line #114: Order #72 has a tracking number but '\
                                'no drive. Order cannot be completed without a drive.')

        expect(csv.warnings.full_messages).to eq(
          [
            'File line #113: Order #62 not for IDrive One',
            'File line #114: Order #72 has a tracking number but no drive. Order cannot be completed without a drive.'
          ]
        )
      end
    end
  end
end
