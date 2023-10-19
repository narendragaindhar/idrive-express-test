require 'rails_helper'

RSpec.describe Report, type: :model do
  describe '#frequency=' do
    it 'converts value to nil if blank' do
      expect(build(:report, frequency: '').frequency).to be_nil
    end
  end

  describe '#recipients=' do
    it 'converts value to nil if blank' do
      expect(build(:report, recipients: '').recipients).to be_nil
    end
  end

  describe '#recipients_list=' do
    it 'returns an array of all the recipients' do
      report = build(:report, recipients: 'user@domain.com, user2@domain.com,user3@domain.com')
      expect(report.recipients_list).to eq(%w[user@domain.com user2@domain.com user3@domain.com])
    end

    it 'returns an empty array if blank' do
      report = build(:report, recipients: '')
      expect(report.recipients_list).to eq([])
    end
  end

  context 'when running queries' do
    let(:report) do
      build_stubbed(:report, name: 'Drives', query: 'SELECT `serial` FROM `drives`')
    end

    # transactions conflict with two separate connections to the db
    self.use_transactional_tests = false

    before do
      create(:drive, serial: 'ABCD1234')
    end

    after do
      DatabaseCleaner.clean_with :truncation
    end

    describe '#result' do
      it 'returns the result of the query' do
        expect(report.result.rows[0][0]).to eq('ABCD1234')
      end
    end

    describe '#result_count' do
      it 'returns the count of how many rows match' do
        expect(report.result_count).to eq(1)
      end
    end

    describe '#valid_query?' do
      let(:report) { build(:report, name: 'Drives', query: 'SELCT FRM `drives`') }

      it 'returns false if invalid' do
        expect(report.valid_query?).to eq(false)
      end

      it 'records errors if any exception is thrown' do
        report.valid_query?
        expect(report.errors[:query][0]).to match(/error in your SQL syntax/)
      end
    end
  end

  describe '#valid_recipients?' do
    it 'does not validate if no value is present' do
      report = build(:report, recipients: '')
      report.valid_recipients?
      expect(report.errors[:recipients]).to be_empty
    end

    it 'returns true if valid' do
      report = build(:report, recipients: 'user@domain.com')
      expect(report.valid_recipients?).to eq(true)
    end

    it 'returns false if invalid' do
      report = build(:report, recipients: 'nope')
      expect(report.valid_recipients?).to eq(false)
    end

    it 'allows a single email address' do
      report = build(:report, recipients: 'user@domain.com')
      report.valid_recipients?
      expect(report.errors[:recipients]).to be_empty
    end

    it 'allows multiple email addresses' do
      report = build(:report, recipients: 'user@domain.com,u2@d2.com,u3@d3.com')
      report.valid_recipients?
      expect(report.errors[:recipients]).to be_empty
    end

    it 'allows weird spacing as long as the format is correct' do
      report = build(:report, recipients: '  user@domain.com,   u2@d2.com,u3@d3.com, u4@d4.com,   u5+label@d5.com ')
      report.valid_recipients?
      expect(report.errors[:recipients]).to be_empty
    end
  end

  describe '#validate' do
    describe 'name' do
      it 'is required (nil)' do
        expect(build(:report, name: nil)).not_to be_valid
      end

      it 'is required (blank)' do
        expect(build(:report, name: '')).not_to be_valid
      end

      it 'is <= 255 characters' do
        name = 'a' * 256
        expect(build(:report, name: name)).not_to be_valid
      end
    end

    describe 'description' do
      it 'is not required (nil)' do
        expect(build(:report, description: nil)).to be_valid
      end

      it 'is not required (blank)' do
        expect(build(:report, description: '')).to be_valid
      end
    end

    describe 'query' do
      it 'is required (nil)' do
        expect(build(:report, query: nil)).not_to be_valid
      end

      it 'is required (blank)' do
        expect(build(:report, query: '')).not_to be_valid
      end
    end

    describe 'frequency' do
      it 'is not required (nil)' do
        expect(build(:report, frequency: nil)).to be_valid
      end

      it 'is not required (blank)' do
        expect(build(:report, frequency: '')).to be_valid
      end

      it 'must be a valid frequency' do
        expect(build(:report, frequency: 'nope')).not_to be_valid
      end

      it 'can be daily' do
        expect(build(:report, frequency: 'daily')).to be_valid
      end

      it 'can be weekly' do
        expect(build(:report, frequency: 'weekly')).to be_valid
      end

      it 'can be monthly' do
        expect(build(:report, frequency: 'monthly')).to be_valid
      end
    end

    describe 'recipients' do
      it 'is not required (nil)' do
        expect(build(:report, recipients: nil)).to be_valid
      end

      it 'is not required (blank)' do
        expect(build(:report, recipients: '')).to be_valid
      end

      it 'is <= 255 characters' do
        recipients = "#{'a' * 245}@domain.com"
        expect(build(:report, recipients: recipients)).not_to be_valid
      end

      it 'must have a valid email address' do
        expect(build(:report, recipients: 'nope')).not_to be_valid
      end

      it 'must have all valid email addresses' do
        expect(build(:report, recipients: 'user@domain.com, nope')).not_to be_valid
      end

      it 'can be one email address' do
        expect(build(:report, recipients: 'user@domain.com')).to be_valid
      end

      it 'can be multiple email addresses' do
        expect(build(:report, recipients: 'user@domain.com, user2@domain2.com,user3@domain.com')).to be_valid
      end
    end
  end
end
