require 'rails_helper'
require 'will_paginate/array'

RSpec.describe 'reports/index.html.haml', type: :view do
  helper FontAwesome::Rails::IconHelper

  let(:report_a) { build_stubbed(:report, name: 'Report A') }
  let(:report_b) { build_stubbed(:report, name: 'Report B') }
  let(:reports) do
    [
      report_a,
      report_b
    ].paginate
  end

  before do
    assign(:reports, reports)
    render
  end

  it 'displays the reports' do
    reports.each do |report|
      expect(rendered).to have_tag('a', text: report.name,
                                        with: { href: report_path(report) })
    end
  end

  it 'links to create a new report' do
    expect(rendered).to have_tag('a', text: /New report/, with: { href: new_report_path })
  end
end
