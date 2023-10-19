require 'rails_helper'

RSpec.describe ApplicationRecords do
  let(:seed) { described_class.new('040-order_type').seed! }

  before { described_class.new('010-product').seed! }

  describe '#seed!' do
    it 'creates all records' do
      expect { seed }.to change(OrderType, :count).from(0).to(10)
    end
  end
end
