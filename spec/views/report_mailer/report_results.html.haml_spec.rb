require 'rails_helper'

RSpec.describe 'report_mailer/report_results.html.haml', type: :view do
  helper MailHelper

  let(:result) do
    instance_double(
      'ActiveRecord::Result',
      columns: %w[id name],
      length: 2,
      rows: [[1, 'Joe'], [23, 'Barry']]
    )
  end
  let(:report) do
    r = build_stubbed(:report, name: 'My report',
                               recipients: 'user@idrive.com')
    r.instance_variable_set(:@result, result)
    r
  end

  before do
    assign(:report, report)
    render
  end

  it 'shows a count of results' do
    expect(rendered).to match(/Results:.*2/m)
  end

  it 'humanizes the column names in headers' do
    %w[Id Name].each do |column|
      expect(rendered).to have_tag('td', text: column)
    end
  end

  it 'has rows with all the values' do
    expect(rendered).to have_tag('tbody>tr', count: 2)
  end

  context 'with no results' do
    let(:result) do
      instance_double(
        'ActiveRecord::Result',
        columns: %w[id name],
        length: 0,
        rows: []
      )
    end

    it 'shows a row indicating nothing returned' do
      expect(rendered).to have_tag('tbody>tr', count: 1) do
        with_tag('td', count: 1, text: /No results/, with: { colspan: 2 })
      end
    end
  end

  context 'with a column named :order_id' do
    let(:result) do
      instance_double(
        'ActiveRecord::Result',
        columns: %w[order_id details],
        length: 1,
        rows: [[52, 'IDrive Express upload']]
      )
    end

    it 'links to the order with the full url' do
      expect(rendered).to have_tag('a', text: '52', with: { href: 'http://test.host/orders/52' })
    end
  end
end
