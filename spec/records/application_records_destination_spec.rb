require 'rails_helper'

RSpec.describe ApplicationRecords do
  let(:seed) { described_class.new('030-destination').seed! }

  before { described_class.new('000-address').seed! }

  describe '#seed!' do
    it 'creates all records' do
      expect { seed }.to change(Destination, :count).from(0).to(5)
    end
  end
end
