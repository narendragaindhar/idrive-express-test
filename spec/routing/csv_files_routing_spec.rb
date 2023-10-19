require 'rails_helper'

RSpec.describe CSVFilesController, type: :routing do
  it 'routes to #index' do
    expect(get: '/csv').to route_to('csv_files#index')
  end

  it 'routes to #create' do
    expect(post: '/csv').to route_to('csv_files#create')
  end
end
