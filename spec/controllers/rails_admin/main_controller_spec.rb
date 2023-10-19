require 'rails_helper'

RSpec.describe RailsAdmin::MainController, type: :controller do
  let(:user) { create(:user) }

  before do
    # https://www.relishapp.com/rspec/rspec-rails/v/3-2/docs/controller-specs/engine-routes-for-controllers
    @routes = RailsAdmin::Engine.routes
    login_user user
  end

  describe 'GET #dashboard' do
    let(:request) { get(:dashboard) }

    context 'with no roles' do
      it 'redirects back to main app' do
        expect(request).to redirect_to Rails.application.class.routes.url_helpers.root_path
      end
    end

    context 'with other roles' do
      it 'redirects back to main app' do
        user.roles << create(:role, key: 'other_role', name: 'Other role')
        expect(request).to redirect_to Rails.application.class.routes.url_helpers.root_path
      end
    end

    context 'with role `idrive_employee`' do
      it 'is successful' do
        user.roles << create(:role_idrive_employee)
        expect(request).to be_successful
      end
    end

    context 'with role `super_user`' do
      it 'is successful' do
        user.roles << create(:role_super_user)
        expect(request).to be_successful
      end
    end
  end
end
