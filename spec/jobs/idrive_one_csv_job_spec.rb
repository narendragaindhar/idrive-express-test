require 'rails_helper'

RSpec.describe IDriveOneCSVJob, type: :job do
  let(:csv_file_content) do
    tempfile = Tempfile.open('csv')
    # rubocop:disable Metrics/LineLength
    CSV.open(tempfile.path, 'wb', headers: :first_row) do |csv|
      csv << ['IDriveStaff', 'JW No.', 'Status', 'Ticket number', 'Username', 'PD', 'Name', 'Street', 'City', 'State', 'Zip code', 'Country', 'MAC number', 'HDD S/N', 'Tracking number', 'Responed to customer', 'Date Ordered', 'Promo Code', 'OrderID', 'Notes']
      csv << [nil, '1TB_17.2910', nil, 1234, 'meggie.jast@pfefferherman.co', 'pd', "Ramona O'Kon", '824 Dagmar Square', 'Skilesstad', 'FL', '67746-6612', 'USA', '001CC226B188', 'DM2L684K', 'FC548059CAAFBDFB4F0F5839721B6643', 'y', '3/20/2017', 'ONE_CNET', 'AR3ED958E70C', 'I have some stuff to say']
      csv << [nil, '1TB_17.2911', nil, 1235, 'carolyne_kemmer@leuschkerice.name', 'pd', 'Fanny Dicki', '239 Kara Port', 'Collinsstad', 'IA', '45051', 'USA', 'F77ACC56A0CECC2', '4904B50F9ACF87E07', 'E0BAED79DAD2E73339F88403D2EE85D4', 'y', '3/21/2017', 'ONE_CNET', 'F26A9FFFAD', nil]
      csv << [nil, '1TB_17.2912', nil, 1236, 'jayden_wiegand@flatley.io', 'pd', "Walton O'Keefe", '2029 Ryley Lodge', 'Schummton', 'AR', '16856-0053', 'USA', '', nil, nil, 'y', '3/21/2017', '', 'AR3ED958E70C', nil]
      csv << [nil, 'OneTB.2890', nil, 1237, 'ed@torpjohnson.net', 'pd', 'Ebba Price', '1552 Christ Forest', 'Port Oren', 'OR', '52632-2314', 'USA', nil, '', '237BE42A42675E2C020C3D9DD72D40CC', 'y', '3/22/2017', nil, nil, nil]
      csv << [nil, 'OneTB.2891', nil, '  1238 ', 'lonzo_cruickshank@langworthdach.com', 'pd', 'Gregoria Kuhn', '221 Marian Rue', 'New Perry', 'AL', '51490-2329', 'USA', ' 001CC226EA68 ', " \n97F3ED8FD021F", "\n\n\n9E12AD27610D9CB9AADC354A87171169", 'y', '3/22/2017', nil, '27671B844', "  I wrote\n\na long \nweird formatted\nnote   "]
      csv << [nil, 'OneTB.2892', nil, 1239, 'drew@white.com', 'pd', 'Norval Morissette', '965 Spencer Prairie', 'North Chadrickview', 'IL', '75609-4178', 'USA', 'B97CEA37A2989', 'C2022D425C5459B1', nil, 'y', '3/22/2017', nil, '73C420C6B4C', nil]
      csv << [nil, '1TB_17.2945', nil, 'ID00977369', 'lynmar41', 'pd', 'Lyman Jones', '3422 Arrowhead Blvd. #74', 'Blythe', 'California', '92225', 'United States of America', '001CC226D3BC', 'DM2L1YNK', '420922259405510200829271768558', 'y', '06 Jan 2017', nil, nil, nil]
      csv << [nil, nil, 'HOLD', 1240, 'shanon_hudson@armstrong.info', 'pd', 'Bette Romaguera Jr.', '648 Romaguera Trafficway', 'Port Jeffrey', 'WY', '81458', 'USA', '001CC2269C00', '046538A120B023B0', '8C4FE35136C38112FA9C7E20A1839810', nil, '3/22/2017', 'ONE_RUSH', 'AL0ED51E5DB0', nil]
      csv << [nil, nil, 'Cancelled', 1241, 'nat@auer.org', 'pd', 'Toy Marks', '22061 Amparo Stravenue', 'Crawfordside', 'DE', '59281-2941', 'USA', nil, nil, nil, nil, '3/22/2017', nil, 'BE3437C70ED88', nil]
    end
    # rubocop:enable Metrics/LineLength
    tempfile.read
  end
  let(:user) { create(:user) }

  it 'can be queued' do
    expect do
      described_class.perform_later(csv_file_content, user)
    end.to have_enqueued_job(described_class)
  end

  it 'accepts the correct arguments' do
    expect do
      described_class.perform_later(csv_file_content, user)
    end.to have_enqueued_job.with(csv_file_content, user)
  end

  describe '#perform' do
    let(:job) { described_class.perform_now(csv_file_content, user) }

    it 'processes the file' do
      expect { job }.not_to raise_error
    end

    context 'with stubbed args' do
      let(:csv_file) do
        c = CSVFile.new(file: '/path/to/file.csv')
        c.success = true
        c.records_processed = 10
        c.records_updated = 3
        c
      end
      let(:processor) { instance_double('IDriveOneCSVService', process: csv_file) }

      before do
        allow(IDriveOneCSVService).to receive(:new).with(an_instance_of(CSVFile), user).and_return(processor)
      end

      it 'checks the result' do
        expect(csv_file).to receive(:success?).and_return(true)
        job
      end
    end
  end
end
