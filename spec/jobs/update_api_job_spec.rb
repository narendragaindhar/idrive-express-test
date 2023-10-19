require 'rails_helper'

RSpec.describe UpdateAPIJob, type: :job do
  let!(:order) { create(:order_upload) }
  let(:order_state) { create(:order_state, order: order, is_public: true) }

  it 'can be queued' do
    expect do
      described_class.perform_later(order_state)
    end.to have_enqueued_job.with(order_state)
  end

  describe '#perform' do
    it 'calls the update service' do
      expect(UpdateService).to receive(:perform).with(order_state).and_return(true)
      described_class.perform_now(order_state)
    end

    it 'sets :is_public to false if the request fails' do
      expect(UpdateService).to receive(:perform).and_return(false)
      described_class.perform_now(order_state)
      expect(order_state.reload.is_public).to eq(false)
    end
  end
end
