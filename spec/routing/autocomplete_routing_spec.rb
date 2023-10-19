require 'rails_helper'

RSpec.describe AutocompleteController, type: :routing do
  it 'routes to #customers' do
    expect(get: '/autocomplete/customers').to route_to('autocomplete#customers')
  end

  it 'routes to #drives' do
    expect(get: '/autocomplete/drives').to route_to('autocomplete#drives')
  end
end
