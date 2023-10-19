class HelpController < ApplicationController
  layout 'help'
  skip_after_action :verify_authorized

  PAGES_DIR = Rails.root.join('app', 'views', 'help', 'pages')
  PAGE_EXTENSION = '.html.haml'.freeze

  # GET /help
  def index
    @pages = Dir.glob("#{PAGES_DIR}/*#{PAGE_EXTENSION}").map do |page|
      page.sub(PAGES_DIR.to_s, '').sub(/#{PAGE_EXTENSION}\z/i, '')[1..]
    end
  end

  # GET /help/:page
  def show
    page = File.join(PAGES_DIR, page_param)

    raise ActionController::RoutingError, 'Not found' unless File.file? page

    render File.join('help', 'pages', page_param)
  end

  private

  def page_param
    "#{params[:page].gsub('../', '').underscore}#{PAGE_EXTENSION}"
  end
end
