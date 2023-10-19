require 'rails_helper'

RSpec.describe ApplicationRecords do
  let(:seed) { described_class.new('090-state_ibackup_upload').seed! }

  before do
    described_class.new('010-product').seed!
    described_class.new('040-order_type').seed!
  end

  describe '#seed!' do
    it 'creates all records' do
      expect { seed }.to change(State, :count).from(0).to(5)
    end
  end
end
