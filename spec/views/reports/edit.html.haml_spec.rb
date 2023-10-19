require 'rails_helper'

RSpec.describe 'reports/edit.html.haml', type: :view do
  helper FontAwesome::Rails::IconHelper

  let(:report) { build_stubbed(:report) }

  before do
    assign(:report, report)
    render
  end

  it 'has a form' do
    expect(rendered).to have_tag('form', with: { action: report_path(report) })
  end
end
