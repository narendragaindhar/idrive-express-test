require 'rails_helper'

RSpec.describe 'orders/_search_highlight.html.haml', type: :view do
  let(:customer) { build_stubbed(:customer, name: 'Johnny James', username: 'johnny_james', email: 'johnny@james.com') }
  let(:drive) { build_stubbed(:drive, identification_number: 'KWIDKH883', serial: 'XJJ5999824') }
  let(:order) do
    o = build_stubbed(:order, customer: customer, drive: drive, comments: 'Yo! I want to upload me some data')
    allow(o).to receive(:order_states).and_return(
      [
        build_stubbed(
          :order_state,
          comments: "USPS sent tracking number: XKJD89892382AAL\n\nUSPS return tracking number: MMDKWUCUUU3888DWW987",
          state: build_stubbed(:state_shipping_label_generated)
        ),
        build_stubbed(:order_state, comments: 'Your drive has been shipped!',
                                    state: build_stubbed(:state_drive_shipped))
      ]
    )
    o
  end

  before do
    render partial: 'orders/search_highlight.html.haml', locals: { query: query, order: order }
  end

  context 'without a search' do
    let(:query) { nil }

    it 'does nothing' do
      expect(rendered).to eq('')
    end
  end

  context 'with a plain search' do
    context 'when it matches order.comments' do
      let(:query) { 'upload me some data' }

      it 'shows a match result' do
        expect(rendered).to match('Customer comment match: ')
      end
    end

    context 'when it matches customer.name' do
      let(:query) { 'johnny james' }

      it 'shows a match result' do
        expect(rendered).to match('Customer match: ')
      end
    end

    context 'when it matches customer.username' do
      let(:query) { 'johnny_james' }

      it 'shows a match result' do
        expect(rendered).to match('Customer match: ')
      end
    end

    context 'when it matches customer.email' do
      let(:query) { 'johnny@james.com' }

      it 'shows a match result' do
        expect(rendered).to match('Customer match: ')
      end
    end
  end

  context 'with a simple keyword search' do
    context 'when it matches order_state.state.label' do
      let(:query) { 'state:generated' }

      it 'shows a match result' do
        expect(rendered).to match('State match: ')
      end
    end

    context 'when it matches order_state.comments' do
      let(:query) { 'state:XKJD89892382AAL' }

      it 'shows a match result' do
        expect(rendered).to match('State match: ')
      end
    end

    context 'when drive identification number matches' do
      let(:query) { 'drive:KWIDKH883' }

      it 'shows a match result' do
        expect(rendered).to match('Drive match: ')
      end
    end

    context 'when it matches drive.identification_number' do
      let(:query) { 'drive:XJJ5999824' }

      it 'shows a match result' do
        expect(rendered).to match('Drive match: ')
      end
    end
  end

  context 'with a complex search' do
    let(:query) { 'customer:johnny has been shipped' }

    it 'does nothing' do
      expect(rendered).to eq('')
    end
  end
end
