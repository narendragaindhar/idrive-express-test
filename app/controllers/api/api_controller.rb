module API
  class APIController < ApplicationController
    before_action :require_api_login
    skip_before_action :verify_authenticity_token
    skip_before_action :require_login
    skip_after_action :verify_authorized

    private

    def require_api_login
      authenticate_or_request_with_http_token do |token, _options|
        token == ENV['API_TOKEN']
      end
    end
  end
end
