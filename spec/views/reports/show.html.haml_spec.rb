require 'rails_helper'

RSpec.describe 'reports/show.html.haml', type: :view do
  helper FontAwesome::Rails::IconHelper

  let(:report) do
    build_stubbed(:report, name: 'My report',
                           recipients: 'user@idrive.com')
  end

  before do
    assign(:report, report)
    render
  end

  it 'displays the report name' do
    expect(rendered).to match('My report')
  end

  it 'links to delete the report' do
    expect(rendered).to have_tag('a', text: /Delete report/,
                                      with: { href: report_path(report),
                                              'data-method' => :delete })
  end

  it 'links to edit the report' do
    expect(rendered).to have_tag('a', text: /Edit/, with: { href: edit_report_path(report) })
  end

  it 'links to email the report' do
    expect(rendered).to have_tag('a', text: /Email report/, with: { href: run_report_path(report) })
  end

  context 'without recipients' do
    let(:report) { build_stubbed(:report, recipients: nil) }

    it 'does not link to email the report' do
      expect(rendered).not_to have_tag('a', with: { href: run_report_path(report) })
    end
  end
end
