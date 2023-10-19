require 'sidekiq/api'

class CSVFilesController < ApplicationController
  before_action :authorize_user
  before_action :ensure_user_job, only: [:show]
  before_action :find_job, only: [:show]

  # GET /csv
  def index
    @csv_file = CSVFile.new
  end

  # POST /csv
  def create
    @csv_file = CSVFile.new(csv_file_params)
    if @csv_file.valid?
      @job = IDriveOneCSVJob.perform_later(@csv_file.read, current_user)
      store_job_in_session
      redirect_to csv_file_path(@job.provider_job_id), notice: 'Processing CSV'
    else
      flash.now[:error] = 'CSV upload failure'
      render :index, status: :unprocessable_entity
    end
  end

  # GET /csv/:id
  def show
    return if @job

    clear_job_from_session
    redirect_to csv_files_path, notice: 'CSV finished processing'
  end

  private

  def authorize_user
    authorize(:order, :bulk_update?)
  end

  def clear_job_from_session
    session[:job_ids].delete(params[:id])
    session.delete(:job_ids) if session[:job_ids].empty?
  end

  def csv_file_params
    # prefer .fetch over .require because request will blow up unless a file is
    # uploaded with the request
    params.fetch(:csv_file, {}).permit(:file)
  end

  def ensure_user_job
    raise ActiveRecord::RecordNotFound unless session[:job_ids] && session[:job_ids][params[:id]]
  end

  def find_job
    @job = Sidekiq::Queue.new.find_job(params[:id])
  end

  def store_job_in_session
    if session.key? :job_ids
      session[:job_ids][@job.provider_job_id] = true
    else
      session[:job_ids] = { @job.provider_job_id.to_s => true }
    end
  end
end
