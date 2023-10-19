require 'rails_helper'

RSpec.describe Helpers::DateFilter do
  let(:date_re) { /2015-\d{2}-\d{2} \d{2}:\d{2}:\d{2}(\.\d+)?/ }

  def filtered(date_string)
    Helpers::DateFilter.filter(Order.all, :created_at, date_string).to_sql
  end

  describe '.filter' do
    it 'matches special value "today"' do
      today = Time.zone.today
      tomorrow = today.tomorrow
      expect(filtered('today')).to match(/`created_at` BETWEEN '#{today.year}-#{today.month.to_s.rjust(2, '0')}-#{today.day.to_s.rjust(2, '0')}.+' AND '#{tomorrow.year}-#{tomorrow.month.to_s.rjust(2, '0')}-#{tomorrow.day.to_s.rjust(2, '0')}.+'/) # rubocop:disable Metrics/LineLength
    end

    it 'matches exact time' do
      expect(filtered('2015-10-02T12:30:00')).to match(/`created_at` = '#{date_re}'/)
    end

    it 'matches whole day' do
      expect(filtered('2015-10-02')).to match(/`created_at` BETWEEN '#{date_re}' AND '#{date_re}'/)
    end

    it 'always returns a relation' do
      expect(filtered('nope')).not_to match(/`created_at`/)
    end

    it 'matches > whole day' do
      expect(filtered('>2015-10-03')).to match(/`created_at` > '#{date_re}'/)
    end

    it 'matches > exact time' do
      expect(filtered('>2015-10-03T11:03:23')).to match(/`created_at` > '#{date_re}'/)
    end

    it 'matches >= whole day' do
      expect(filtered('>=2015-10-04')).to match(/`created_at` >= '#{date_re}'/)
    end

    it 'matches >= exact time' do
      expect(filtered('>=2015-10-13T15:43:23')).to match(/`created_at` >= '#{date_re}'/)
    end

    it 'matches = whole day' do
      expect(filtered('=2015-10-05')).to match(/`created_at` BETWEEN '#{date_re}' AND '#{date_re}'/)
    end

    it 'matches = exact time' do
      expect(filtered('=2015-10-05T22:09:00')).to match(/`created_at` = '#{date_re}/)
    end

    it 'matches < whole day' do
      expect(filtered('<2015-10-06')).to match(/`created_at` < '#{date_re}'/)
    end

    it 'matches < exact time' do
      expect(filtered('<2015-10-06T02:00:30')).to match(/`created_at` < '#{date_re}'/)
    end

    it 'matches <= whole day' do
      expect(filtered('<=2015-10-07')).to match(/`created_at` <= '#{date_re}'/)
    end

    it 'matches <= exact time' do
      expect(filtered('<=2015-10-27T12:00:00')).to match(/`created_at` <= '#{date_re}'/)
    end

    it 'matches a date range' do
      expect(filtered('2015-09-01..2015-10-01')).to match(/`created_at` BETWEEN '#{date_re}' AND '#{date_re}'/)
    end

    it 'matches a time range' do
      expect(filtered('2015-09-01T12:00:00..2015-09-01T09:00:00')).to match(
        /`created_at` BETWEEN '#{date_re}' AND '#{date_re}'/
      )
    end
  end
end
