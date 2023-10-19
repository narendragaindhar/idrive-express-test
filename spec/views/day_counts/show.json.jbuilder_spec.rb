require 'rails_helper'
require 'rspec/json_expectations'

RSpec.describe 'day_counts/show.json.jbuilder', type: :view do
  helper OrdersHelper

  let(:count) { 3 }
  let(:day_count) { build_stubbed(:day_count, count: count) }
  let(:order) { build_stubbed(:order, day_count: day_count) }

  before do
    allow(day_count).to receive(:stale?).and_return(false)
    allow(ENV).to receive(:[]).with('ORDERS_DANGER_DAYS').and_return('6')
    allow(ENV).to receive(:[]).with('ORDERS_WARNING_DAYS').and_return('4')
    assign(:order, order)
    render
  end

  it 'contains object .day_count' do
    expect(rendered).to include_json(
      day_count: {
        id: day_count.id,
        order_id: day_count.order_id,
        count: 3,
        is_final: false,
        created_at: /\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+-\d{2}:\d{2}\z/,
        updated_at: /\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+-\d{2}:\d{2}\z/
      }
    )
  end

  it 'contains object .content' do
    expect(rendered).to include_json(
      content: {
        order_row_class: nil,
        day_count_html: /js-order-day-count/i
      }
    )
  end

  it 'content.day_count_html contains html' do
    expect(JSON.parse(rendered)['content']['day_count_html']).to have_tag(
      'span.js-order-day-count', text: "\n#{count}\n"
    )
  end

  context 'when in a warning state' do
    let(:count) { 4 }

    it 'content.day_count_html contains warning html' do
      expect(JSON.parse(rendered)['content']['day_count_html']).to have_tag(
        'span.js-order-day-count.tag-warning', text: "\n#{count}\n"
      )
    end
  end

  context 'when in a danger state' do
    let(:count) { 6 }

    it 'content.day_count_html contains danger html' do
      expect(JSON.parse(rendered)['content']['day_count_html']).to have_tag(
        'span.js-order-day-count.tag-danger', text: "\n#{count}\n"
      )
    end
  end
end
