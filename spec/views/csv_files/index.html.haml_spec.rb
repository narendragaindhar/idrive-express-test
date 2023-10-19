require 'rails_helper'

RSpec.describe 'csv_files/index', type: :view do
  helper FontAwesome::Rails::IconHelper

  let(:csv_file) { CSVFile.new }

  before do
    assign(:csv_file, csv_file)
    render
  end

  it 'has a @csv_file form' do
    expect(rendered).to have_tag('form', with: { enctype: 'multipart/form-data',
                                                 action: csv_files_path, method: 'post' })
  end

  context 'with errors' do
    let(:csv_file) do
      results = CSVFile.new
      results.errors.add(:base, 'Invalid CSV file')
      results
    end

    it 'shows a danger alert' do
      expect(rendered).to have_tag('.alert.alert-danger', text: /1 error\s+occurred while processing the CSV file:/) do
        with_tag('li', count: 1, text: 'Invalid CSV file')
      end
    end
  end
end
