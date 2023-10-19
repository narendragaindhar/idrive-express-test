require 'rails_helper'

RSpec.describe ReportsController, type: :controller do
  let(:report) do
    create(:report, name: 'Drive report',
                    query: 'SELECT `identification_number`, `serial` FROM `drives`',
                    recipients: 'user1@idrive.com')
  end
  let(:user) do
    user = create(:user)
    user.roles << create(:role_reporting)
    user
  end

  before do
    login_user user
  end

  describe 'POST #create' do
    let(:params) do
      { report: attributes_for(:report) }
    end

    context 'with invalid data' do
      let(:invalid_params) do
        data = params
        data[:report].delete(:name)
        data
      end
      let(:request) { post(:create, params: invalid_params) }

      it 'is not successful' do
        expect(request).to have_http_status(:unprocessable_entity)
      end

      it 'rerenders new template' do
        expect(request).to render_template(:new)
      end

      it 'assigns @report' do
        request
        expect(assigns[:report]).to be_a_new(Report)
      end
    end

    context 'with valid data' do
      let(:request) { post(:create, params: params) }

      it 'creates a new report' do
        expect { request }.to change(Report, :count).by(1)
      end

      it 'redirects to new report' do
        expect(request).to redirect_to report_path assigns[:report]
      end

      it 'shows the user a message' do
        request
        expect(flash[:notice]).to eq('Report created successfully')
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:request) { delete(:destroy, params: { id: report.id }) }

    it 'destroys the report' do
      request
      expect { Report.find(report.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'redirects back to the index' do
      expect(request).to redirect_to(reports_path)
    end

    it 'shows the user a message' do
      request
      expect(flash[:notice]).to eq('Report removed')
    end
  end

  describe 'GET #edit' do
    let(:request) { get(:edit, params: { id: report.id }) }

    it 'is successful' do
      expect(request).to be_successful
    end

    it 'renders the edit template' do
      expect(request).to render_template(:edit)
    end

    it 'assigns @report' do
      request
      expect(assigns[:report]).to eq(report)
    end

    it 'assigns @schema' do
      request
      expect(assigns[:schema]).to be_an_instance_of(Hash)
    end
  end

  describe 'GET #index' do
    let(:request) { get(:index) }

    it 'is successful' do
      expect(request).to be_successful
    end

    it 'renders the index template' do
      expect(request).to render_template(:index)
    end

    it 'assigns @reports' do
      reports = [report]
      request
      expect(assigns[:reports]).to eq(reports)
    end
  end

  describe 'GET #new' do
    let(:request) { get(:new) }

    it 'is successful' do
      expect(request).to be_successful
    end

    it 'renders the new template' do
      expect(request).to render_template(:new)
    end

    it 'assigns @report' do
      request
      expect(assigns[:report]).to be_a_new(Report)
    end

    it 'assigns @schema' do
      request
      expect(assigns[:schema]).to be_an_instance_of(Hash)
    end
  end

  describe 'POST #preview' do
    let(:request) { post(:preview, params: params, format: :json) }

    context 'with invalid data' do
      let(:params) do
        { report: { query: 'SELCT' } }
      end

      it 'is not successful' do
        expect(request).to have_http_status(:unprocessable_entity)
      end

      it 'renders the run template' do
        expect(request).to render_template(:run)
      end

      it 'assigns @report' do
        request
        expect(assigns[:report]).to be_a_new(Report)
      end
    end

    context 'with valid data' do
      let(:params) do
        { report: { query: 'SELECT `id` FROM `drives` WHERE `active` = 1' } }
      end

      it 'is successful' do
        expect(request).to be_successful
      end

      it 'does not create a new report' do
        expect { request }.not_to change(Report, :count)
      end

      it 'renders the run template' do
        expect(request).to render_template(:run)
      end

      it 'assigns @report' do
        request
        expect(assigns[:report]).to be_a_new(Report)
      end
    end
  end

  describe 'GET #run' do
    describe 'format :html' do
      let(:request) { get(:run, params: { id: report.id }) }

      it 'redirects to new report' do
        expect(request).to redirect_to report_path(report)
      end

      it 'queues the report job' do
        expect(ReportingJob).to receive(:perform_later).with(report)
        request
      end

      it 'shows a message to the user' do
        request
        expect(flash[:notice]).to eq('Running report and emailing recipients')
      end

      it 'assigns @report' do
        request
        expect(assigns[:report]).to eq(report)
      end
    end

    describe 'format :json' do
      let(:request) { get(:run, params: { id: report.id }, format: :json) }

      it 'is successful' do
        expect(request).to be_successful
      end

      it 'renders the run template' do
        expect(request).to render_template(:run)
      end

      it 'assigns @report' do
        request
        expect(assigns[:report]).to eq(report)
      end
    end
  end

  describe 'GET #show' do
    let(:request) { get(:show, params: { id: report.id }) }

    it 'is successful' do
      expect(request).to be_successful
    end

    it 'renders the show template' do
      expect(request).to render_template(:show)
    end

    it 'assigns @report' do
      request
      expect(assigns[:report]).to eq(report)
    end
  end

  describe 'PATCH #update' do
    let(:params) do
      {
        id: report.id,
        report: {
          name: 'Active drives',
          description: 'Only usable drives',
          query: 'SELECT `id`, `serial` FROM `drives` WHERE `active` = 1'
        }
      }
    end

    context 'with invalid data' do
      let(:invalid_params) do
        data = params
        data[:report][:name] = ''
        data
      end
      let(:request) { patch(:update, params: invalid_params) }

      it 'is not successful' do
        expect(request).to have_http_status(:unprocessable_entity)
      end

      it 'rerenders the form' do
        expect(request).to render_template(:edit)
      end

      it 'assigns @report' do
        request
        expect(assigns[:report]).to eq(report)
      end

      it 'assigns @schema' do
        request
        expect(assigns[:schema]).to be_an_instance_of(Hash)
      end
    end

    context 'with valid data' do
      let(:request) { patch(:update, params: params) }

      it 'redirects back to report' do
        expect(request).to redirect_to(report_path(report))
      end

      it 'shows a message to the user' do
        request
        expect(flash[:notice]).to eq('Report updated successfully')
      end

      it 'updates the report' do
        request
        expect(report.reload.name).to eq('Active drives')
      end
    end
  end
end
