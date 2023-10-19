require 'rails_helper'

RSpec.shared_examples 'help page' do |page|
  it "shows help page \"#{page}\"" do
    expect(get(:show, params: { page: page })).to be_successful
  end
end

RSpec.describe HelpController, type: :controller do
  before do
    allow(controller).to receive(:require_login).and_return(true)
  end

  describe 'GET #index' do
    let(:request) { get(:index) }

    it 'is successful' do
      expect(request).to be_successful
    end

    it 'renders the index template' do
      expect(request).to render_template(:index)
    end

    it 'assigns @pages' do
      request
      expect(assigns[:pages].size).to eq(3)
    end
  end

  describe 'GET #show' do
    it 'does not allow relative paths to escape out of directory' do
      expect do
        get :show, params: { page: '../../../../README.md' }
      end.to raise_error(ActionController::RoutingError)
    end

    it_behaves_like 'help page', '../../searching-orders'
    it_behaves_like 'help page', 'searching-orders'
    it_behaves_like 'help page', 'search-syntax'
    it_behaves_like 'help page', 'update-orders-from-csv'
  end
end
