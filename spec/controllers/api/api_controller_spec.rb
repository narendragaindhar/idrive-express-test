require 'rails_helper'

RSpec.describe API::APIController, type: :controller do
  # dummy controller method
  controller do
    def index
      render plain: 'Hello world'
    end
  end

  describe '#require_api_login' do
    context 'without an auth token' do
      it 'returns a 401 error' do
        get :index
        assert_response :unauthorized
      end
    end

    context 'with an invalid auth token' do
      before do
        request.env['HTTP_AUTHORIZATION'] = 'nope nope nope'
      end

      it 'returns a 401 error' do
        get :index
        assert_response :unauthorized
      end
    end

    context 'with a valid token' do
      before do
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(
          ENV['API_TOKEN']
        )
      end

      it 'returns success' do
        get :index
        assert_response :success
      end
    end
  end
end
