require 'rails_helper'

RSpec.describe ReportsController, type: :routing do
  it 'routes to #create' do
    expect(post: '/reports').to route_to('reports#create')
  end

  it 'routes to #edit' do
    expect(get: '/reports/9/edit').to route_to('reports#edit', id: '9')
  end

  it 'routes to #destroy' do
    expect(delete: '/reports/4').to route_to('reports#destroy', id: '4')
  end

  it 'routes to #index' do
    expect(get: '/reports').to route_to('reports#index')
  end

  it 'routes to #new' do
    expect(get: '/reports/new').to route_to('reports#new')
  end

  it 'routes to #preview' do
    expect(post: '/reports/preview').to route_to('reports#preview')
  end

  it 'routes to #run' do
    expect(get: '/reports/7/run').to route_to('reports#run', id: '7')
  end

  it 'routes to #show' do
    expect(get: '/reports/3').to route_to('reports#show', id: '3')
  end

  it 'routes to #update' do
    expect(patch: '/reports/8').to route_to('reports#update', id: '8')
  end
end
