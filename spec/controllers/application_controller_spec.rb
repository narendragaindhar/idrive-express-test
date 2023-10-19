require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  let(:request) { get(:index) }
  let(:user) { create(:user) }

  # dummy controller method
  controller do
    def index
      authorize(:application, :index?)
      render plain: 'Hello world'
    end
  end

  context 'when logged out' do
    it 'redirects to login page' do
      expect(request).to redirect_to login_path
    end

    it 'shows the user a message' do
      request
      expect(flash[:alert]).to eq('You must be logged in to access the requested page.')
    end
  end

  context 'when unauthorized' do
    before do
      login_user user
    end

    it 'shows an error message to the user' do
      request
      expect(flash[:error]).to eq('You are not authorized to perform this action')
    end

    it 'redirects to the root URL' do
      expect(request).to redirect_to(root_path)
    end

    it 'logs a warning message' do
      allow_any_instance_of(ActionController::TestRequest).to receive(:path).and_return('/index')
      expect(Rails.logger).to receive(:warn).with(
        "Unauthorized action detected by User ##{user.id} (#{user.name} <#{user.email}>): "\
        'action=ApplicationPolicy.index? url=/index'
      )
      request
    end
  end

  context 'when authorized' do
    before do
      login_user user
      allow(controller).to receive(:authorize) {
        controller.instance_variable_set(:@_pundit_policy_authorized, true)
        true
      }
    end

    it 'sets the var @orders_path_sym' do
      request
      expect(assigns[:orders_path_sym]).to eq(:orders_path)
    end
  end
end
