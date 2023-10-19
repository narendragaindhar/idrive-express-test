require 'rails_helper'

RSpec.describe 'csv_files/show.html.haml', type: :view do
  helper FontAwesome::Rails::IconHelper

  before do
    render
  end

  it 'lets the user know their CSV is processing' do
    expect(rendered).to match(/your csv has been uploaded and is being processed/i)
  end

  it 'has an element to let the JS initialize' do
    expect(rendered).to have_tag('#js-csv-files-processing')
  end
end
