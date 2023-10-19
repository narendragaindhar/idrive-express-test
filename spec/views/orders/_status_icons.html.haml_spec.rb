require 'rails_helper'

RSpec.describe 'orders/_status_icons.html.haml', type: :view do
  helper FontAwesome::Rails::IconHelper

  let(:customer) { build_stubbed(:customer, priority: 0) }
  let(:order) { build_stubbed(:order, customer: customer) }

  before do
    render partial: 'orders/status_icons.html.haml', locals: { order: order }
  end

  describe 'order.priority' do
    context 'with out a priority' do
      it 'is not shown' do
        expect(rendered).not_to have_tag('.fa-star', with: { title: /priority/i })
      end
    end

    context 'with a medium priority' do
      let(:customer) { build_stubbed(:customer, priority: 1) }

      it 'is shown' do
        expect(rendered).to have_tag('.fa-star', with: { title: 'Priority order' })
      end
    end

    context 'with a high priority' do
      let(:customer) { build_stubbed(:customer, priority: 3) }

      it 'is shown with emphasis' do
        expect(rendered).to have_tag('.fa-star.text-danger', with: { title: 'High priority order' })
      end
    end
  end
end
