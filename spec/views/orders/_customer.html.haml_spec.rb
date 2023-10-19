require 'rails_helper'

RSpec.describe 'orders/_customer.html.haml', type: :view do
  let(:customer) { build_stubbed(:customer, priority: 0) }

  before do
    assign(:customer, customer)
    render
  end

  describe '#priority' do
    it 'is not shown' do
      expect(rendered).to have_tag('.list-group-item', text: /Priority.+?No/m)
    end

    context 'with a medium priority' do
      let(:customer) { build_stubbed(:customer, priority: 1) }

      it 'is shown' do
        expect(rendered).to have_tag('.list-group-item', text: /Priority.+?Normal/m)
      end
    end

    context 'with a high priority' do
      let(:customer) { build_stubbed(:customer, priority: 3) }

      it 'is shown with emphasis' do
        expect(rendered).to have_tag('.list-group-item', text: /Priority.+?High/m)
      end
    end
  end
end
