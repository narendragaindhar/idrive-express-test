class ReportsController < ApplicationController
  before_action :find_report, only: %i[destroy edit run show update]
  before_action :initialize_report, only: %i[create preview]
  before_action :load_schema, only: %i[edit new update]

  # POST /reports
  def create
    if @report.save
      redirect_to @report, notice: 'Report created successfully'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /reports/:id
  def destroy
    @report.destroy
    redirect_to reports_path, notice: 'Report removed'
  end

  # GET /reports/:id/edit
  def edit; end

  # GET /reports
  def index
    @reports = Report.all.order(:name).paginate(page: params[:page])
    authorize @reports
  end

  # GET /reports/new
  def new
    @report = Report.new
    authorize @report
  end

  # POST /reports/preview
  def preview
    @report.name = 'Test report'
    if @report.valid?
      render :run
    else
      render :run, status: :unprocessable_entity
    end
  end

  # GET /reports/:id/run
  def run
    respond_to do |format|
      format.html do
        ReportingJob.perform_later(@report) if @report.recipients.present?
        redirect_to @report, notice: 'Running report and emailing recipients'
      end
      format.json
    end
  end

  # GET /reports/:id
  def show; end

  # PATCH/PUT /reports/:id
  def update
    if @report.update report_params
      redirect_to @report, notice: 'Report updated successfully'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def find_report
    @report = Report.find(params[:id])
    authorize @report
  end

  def initialize_report
    @report = Report.new report_params
    authorize @report
  end

  def load_schema
    @schema = ApplicationRecord.subclasses.map do |model|
      [
        model.table_name,
        model.column_names.reject { |c| c =~ /password|salt|token/i }
      ]
    end.to_h
  end

  def report_params
    @report_params ||= params.require(:report).permit(
      :name, :description, :query, :frequency, :recipients
    )
  end
end
