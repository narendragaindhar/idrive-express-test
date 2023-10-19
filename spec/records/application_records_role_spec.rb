require 'rails_helper'

RSpec.describe ApplicationRecords do
  let(:seed) { described_class.new('020-role').seed! }

  describe '#seed!' do
    it 'creates all records' do
      expect { seed }.to change(Role, :count).from(0).to(7)
    end
  end
end
