require 'rails_helper'
require 'sidekiq/api'

RSpec.describe CSVFilesController, type: :controller do
  let(:user) do
    user = create(:user)
    user.roles << create(:role_idrive_one_contractor)
    user
  end
  let(:order) { create(:order_idrive_one) }
  let(:unsupported_order) { create(:order_upload) }
  let(:order_no_drive) { create(:order_idrive_one) }
  let(:order_no_drive_shipping) { create(:order_idrive_one) }
  let(:order_weird_but_valid) { create(:order_idrive_one) }
  let(:order_drive_no_shipping) { create(:order_idrive_one) }
  let(:csv_file) do
    tempfile = Tempfile.open('csv')
    # rubocop:disable Metrics/LineLength
    CSV.open(tempfile.path, 'wb', headers: :first_row, row_sep: "\r\n") do |csv|
      csv << ['IDriveStaff', 'JW No.', 'Status', 'Ticket number', 'Username', 'PD', 'Name', 'Street', 'City', 'State', 'Zip code', 'Country', 'MAC number', 'HDD S/N', 'Tracking number', 'Responed to customer', 'Date Ordered', 'Promo Code', 'OrderID', 'Notes']
      csv << [nil, 'OneTB.0785', nil, order.id, order.customer.email, 'pd', order.address.to_field, order.address.address, order.address.city, order.address.state, order.address.zip, order.address.country, '95AE1B5B1B9FF1F', '352ABC68D55B679BD', '3B8C83AD67A7906F70AF010E031BB685', 'y', order.created_at.strftime('%-m/%-d/%Y'), 'ONE_CNET', '935CF49BAC19F95', 'I am a comment. Hey hey hey!']
      csv << [nil, 'OneTB.0786', nil, unsupported_order.id, unsupported_order.customer.email, 'pd', unsupported_order.address.to_field, unsupported_order.address.address, unsupported_order.address.city, unsupported_order.address.state, unsupported_order.address.zip, unsupported_order.address.country, 'FE6D2587CE7D391EB', '424C1F697A3A6B3', 'C9FC78EA58070C009FF87D738BAFDF7A', 'y', unsupported_order.created_at.strftime('%-m/%-d/%Y'), 'ONE_CNET', 'CD9C8083F4C3', nil]
      csv << [nil, 'OneTB.0787', nil, order_no_drive.id, order_no_drive.customer.email, 'pd', order_no_drive.address.to_field, order_no_drive.address.address, order_no_drive.address.city, order_no_drive.address.state, order_no_drive.address.zip, order_no_drive.address.country, '', nil, nil, 'y', order_no_drive.created_at.strftime('%-m/%-d/%Y'), '', '860C10E2FCDA1DFA09D0', nil]
      csv << [nil, 'OneTB.1087', nil, order_no_drive_shipping.id, order_no_drive_shipping.customer.email, 'pd', order_no_drive_shipping.address.to_field, order_no_drive_shipping.address.address, order_no_drive_shipping.address.city, order_no_drive_shipping.address.state, order_no_drive_shipping.address.zip, order_no_drive_shipping.address.country, nil, '', '1235F68BB4303045484176454463FCF7', 'y', order_no_drive_shipping.created_at.strftime('%-m/%-d/%Y'), nil, 'F5272482E1FAC8969', nil]
      csv << [nil, 'OneTB.1088', nil, "  #{order_weird_but_valid.id} ", order_weird_but_valid.customer.email, 'pd', order_weird_but_valid.address.to_field, order_weird_but_valid.address.address, order_weird_but_valid.address.city, order_weird_but_valid.address.state, order_weird_but_valid.address.zip, order_weird_but_valid.address.country, ' A68A0B42D61448D ', " \n5B6AD08F5079C", "\n\n\n12D60DFCB5067CB7C7D97608CCE4543B", 'y', order_weird_but_valid.created_at.strftime('%-m/%-d/%Y'), nil, 'FBE72FF77496C7DC', "  I am writing...\n and that was it   "]
      csv << [nil, 'OneTB.1089', nil, order_drive_no_shipping.id, order_drive_no_shipping.customer.email, 'pd', order_drive_no_shipping.address.to_field, order_drive_no_shipping.address.address, order_drive_no_shipping.address.city, order_drive_no_shipping.address.state, order_drive_no_shipping.address.zip, order_drive_no_shipping.address.country, '5330E3B1E0F8B145', 'F768A3F52DF8D61A', nil, 'y', order_drive_no_shipping.created_at.strftime('%-m/%-d/%Y'), nil, '231968A58F02EF', nil]
      csv << [nil, '1TB_17.2922', nil, 'ID00977679', 'mymar41', 'pd', 'Jenny Jones', '312 Arrowhead St. #24', 'Fullerton', 'California', '92115', 'United States of America', '4DA18B5218FB1AD47', '8864398C118959E', '8D13EEDD86B3C4A5ABC75621F8857BEF', 'y', '19 Jan 2017', nil, nil, nil]
    end
    # rubocop:enable Metrics/LineLength
    tempfile.path
  end

  before do
    # states used insternally by the processor
    create(:state_idrive_one_status_update)
    create(:state_idrive_one_shipping_label_generated)
    create(:state_idrive_one_order_shipped)
    create(:state_idrive_one_order_cancelled)

    allow_any_instance_of(OrderState).to receive(:notify_customer)
    login_user user
  end

  after do
    File.unlink(csv_file) if File.exist?(csv_file)
  end

  describe 'GET #index' do
    let(:request) { get(:index) }

    it 'assigns @csv_file' do
      request
      expect(assigns(:csv_file)).to be_an_instance_of(CSVFile)
    end

    it 'renders the :index template' do
      expect(request).to render_template(:index)
    end
  end

  describe 'POST #create' do
    let(:request) { post(:create, params: data) }

    context 'with valid params' do
      let(:job) { instance_double('IDriveOneCSVJob', provider_job_id: '1234567890asdfghjkl') }
      let(:data) do
        {
          csv_file: {
            file: Rack::Test::UploadedFile.new(csv_file, 'text/plain')
          }
        }
      end

      before do
        allow(IDriveOneCSVJob).to receive(:perform_later).with(
          File.open(csv_file).read,
          user
        ).and_return(job)
      end

      it 'redirects to show path' do
        expect(request).to redirect_to csv_file_path('1234567890asdfghjkl')
      end

      it 'shows a success message' do
        request
        expect(flash.now[:notice]).to eq('Processing CSV')
      end

      it 'assigns @csv_file' do
        request
        expect(assigns[:csv_file]).to be_an_instance_of(CSVFile)
      end

      it 'assigns @job' do
        request
        expect(assigns[:job]).to eq(job)
      end

      it 'sets the job id in the session' do
        request
        expect(session[:job_ids]).to eq('1234567890asdfghjkl' => true)
      end
    end

    context 'with invalid params' do
      let(:data) do
        { csv_file: { file: nil } }
      end

      it 'is not successful' do
        expect(request).to have_http_status(:unprocessable_entity)
      end

      it 'shows an error message' do
        request
        expect(flash.now[:error]).to eq('CSV upload failure')
      end

      it 'assigns @csv_file' do
        request
        expect(assigns[:csv_file]).to be_an_instance_of(CSVFile)
      end

      it 'has errors during the processing' do
        request
        expect(assigns[:csv_file].errors[:file]).to include('does not exist')
      end

      it 're-renders the "index" template' do
        expect(request).to render_template(:index)
      end
    end

    context 'without params' do
      let(:data) { {} }

      it 'is not successful' do
        expect(request).to have_http_status(:unprocessable_entity)
      end

      it 'assigns @csv_file' do
        request
        expect(assigns[:csv_file]).to be_an_instance_of(CSVFile)
      end

      it 're-renders the "index" template' do
        expect(request).to render_template(:index)
      end
    end
  end

  describe 'GET #show' do
    let(:id) { 'zxvbqwer2345' }
    let(:job) { nil }
    let(:job_ids) { nil }
    let(:request) { get :show, params: { id: id } }
    let(:finder) { instance_double('Sidekiq::Queue', find_job: job) }

    before do
      session[:job_ids] = job_ids
      allow(Sidekiq::Queue).to receive(:new).and_return(finder)
    end

    context 'with job not present in the session' do
      context 'when it is processing' do
        let(:job) { instance_double('Job') }

        it 'returns a 404 error' do
          expect { request }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context 'when it is not processing' do
        it 'returns a 404 error' do
          expect { request }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end

    context 'with job present in the session' do
      let(:job_ids) { { id => true } }

      context 'when it is still processing' do
        let(:job) { instance_double('Job') }

        it 'is successful' do
          expect(request).to have_http_status :success
        end
      end

      context 'when it is done processing' do
        it 'redirects back to the index' do
          expect(request).to redirect_to csv_files_path
        end

        it 'sets a success message' do
          request
          expect(flash[:notice]).to eq('CSV finished processing')
        end

        it 'clears the jobs from the session' do
          request
          expect(session[:job_ids]).to eq(nil)
        end

        it 'only deletes the key if there are more than one' do
          session[:job_ids] = { id => true, 'asdflkjlkvoiiuwer' => true }
          request
          expect(session[:job_ids]).to eq('asdflkjlkvoiiuwer' => true)
        end
      end
    end
  end
end
