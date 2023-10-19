require 'rails_helper'

RSpec.describe 'orders/_shipping.html.haml', type: :view do
  let(:address) { create(:address) }
  let(:destination) { create(:destination_alchemy) }
  let(:order) { create(:order, address: address, destination: destination) }

  before do
    assign(:address, address)
    assign(:destination, destination)
    assign(:order, order)
    render
  end

  describe 'csv information' do
    it 'has a couple links to it' do
      expect(rendered).to have_tag('a', count: 2, with: { href: order_path(order, format: :csv) })
    end

    it 'offers to download it as well' do
      expect(rendered).to have_tag('a', count: 1, with: { href: order_path(order, format: :csv, download: true) })
    end

    it 'has a button to open the modal' do
      expect(rendered).to have_tag('.btn.btn-sm', with: { 'data-target' => '#js-order-csv-modal' })
    end

    it 'has a modal box associated with it' do
      expect(rendered).to have_tag('div.modal', with: { id: 'js-order-csv-modal' })
    end
  end
end
