require 'rails_helper'

RSpec.describe Readonly::Query, type: :model do
  describe '.exec_query' do
    let!(:drive_1) { create(:drive, serial: 'ABC123') }
    let!(:drive_2) { create(:drive, serial: 'DEF456') }
    let(:query) do
      <<~SQL
        SELECT
          `id`,
          `serial`
        FROM `drives`
        ORDER BY `id` ASC
      SQL
    end
    let(:result) { described_class.exec_query(query) }

    it 'returns an ActiveRecord::Result' do
      expect(result).to be_an_instance_of(ActiveRecord::Result)
    end

    it 'returns query columns' do
      expect(result.columns).to eq(%w[id serial])
    end

    context 'when querying for real' do
      # transactions conflict with two separate connections to the db
      self.use_transactional_tests = false

      after do
        DatabaseCleaner.clean_with :truncation
      end

      it 'returns query rows' do
        expect(result.rows).to eq(
          [
            [drive_1.id, 'ABC123'],
            [drive_2.id, 'DEF456']
          ]
        )
      end
    end
  end
end
