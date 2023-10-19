require 'rails_helper'

RSpec.describe ApplicationRecords do
  let(:seed) { described_class.new('010-product').seed! }

  describe '#seed!' do
    it 'creates all records' do
      expect { seed }.to change(Product, :count).from(0).to(3)
    end
  end
end
