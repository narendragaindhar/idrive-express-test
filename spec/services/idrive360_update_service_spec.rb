require 'rails_helper'

RSpec.describe IDrive360UpdateService do
  let(:state) { build_stubbed(:state_initial) }
  let(:order_state) { build_stubbed(:order_state, state: state, is_public: true) }

  describe '.perform' do
    let(:updater) { described_class.new(order_state) }

    it 'returns true when the update succeeds' do
      expect(updater.perform).to eq(true)
    end

    it 'returns false when the update fails with invalid data' do
      expect(updater).to receive(:request_body).twice.and_return({})
      expect(updater.perform).to eq(false)
    end
  end
end
