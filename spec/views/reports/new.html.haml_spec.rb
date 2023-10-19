require 'rails_helper'

RSpec.describe 'reports/new.html.haml', type: :view do
  helper FontAwesome::Rails::IconHelper

  let(:report) { Report.new }

  before do
    assign(:report, report)
    render
  end

  it 'has a form' do
    expect(rendered).to have_tag('form', with: { action: reports_path })
  end
end
