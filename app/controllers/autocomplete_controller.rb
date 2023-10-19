class AutocompleteController < ApplicationController
  LIMIT = ENV.fetch('EXPRESS_AUTOCOMPLETE_LIMIT', 10).to_i.freeze

  skip_after_action :verify_authorized

  # GET /autocomplete/customers
  def customers
    @records = Customer.search(params[:term]).order(:name)
    render_autocomplete
  end

  # GET /autocomplete/drives
  def drives
    @records = Drive.search(params[:term]).available
    render_autocomplete
  end

  private

  def render_autocomplete
    @records = @records.limit(params.fetch(:limit, LIMIT))
    @label_method ||= :label
    render :index
  end
end
