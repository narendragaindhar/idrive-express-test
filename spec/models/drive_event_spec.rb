require 'rails_helper'

RSpec.describe DriveEvent, type: :model do
  describe '#validate' do
    describe 'drive' do
      it 'is required (nil)' do
        expect(build(:drive_event, drive: nil)).not_to be_valid
      end
    end

    describe 'event' do
      it 'is required (nil)' do
        expect(build(:drive_event, event: nil)).not_to be_valid
      end

      it 'is required (blank)' do
        expect(build(:drive_event, event: '')).not_to be_valid
      end
    end

    describe 'user' do
      it 'is required (nil)' do
        expect(build(:drive_event, user: nil)).not_to be_valid
      end
    end
  end
end
