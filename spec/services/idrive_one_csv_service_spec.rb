require 'rails_helper'

RSpec.describe IDriveOneCSVService do
  let!(:state_status_update) { create(:state_idrive_one_status_update) }
  let!(:state_shipping_label) { create(:state_idrive_one_shipping_label_generated) }
  let!(:state_order_shipped) { create(:state_idrive_one_order_shipped) }
  let!(:state_cancelled) { create(:state_idrive_one_order_cancelled) }
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
  let(:order_hold) { create(:order_idrive_one) }
  let(:order_cancelled) { create(:order_idrive_one) }
  let(:file) do
    tempfile = Tempfile.open('csv')
    # rubocop:disable Metrics/LineLength
    CSV.open(tempfile.path, 'wb', headers: :first_row) do |csv|
      csv << ['IDriveStaff', 'JW No.', 'Status', 'Ticket number', 'Username', 'PD', 'Name', 'Street', 'City', 'State', 'Zip code', 'Country', 'MAC number', 'HDD S/N', 'Tracking number', 'Responed to customer', 'Date Ordered', 'Promo Code', 'OrderID', 'Notes']
      csv << [nil, '1TB_17.2910', nil, order.id, order.customer.email, 'pd', order.address.to_field, order.address.address, order.address.city, order.address.state, order.address.zip, order.address.country, '001CC226B188', 'DM2L684K', 'FC548059CAAFBDFB4F0F5839721B6643', 'y', order.created_at.strftime('%-m/%-d/%Y'), 'ONE_CNET', 'AR3ED958E70C', 'I have some stuff to say']
      csv << [nil, '1TB_17.2911', nil, unsupported_order.id, unsupported_order.customer.email, 'pd', unsupported_order.address.to_field, unsupported_order.address.address, unsupported_order.address.city, unsupported_order.address.state, unsupported_order.address.zip, unsupported_order.address.country, 'F77ACC56A0CECC2', '4904B50F9ACF87E07', 'E0BAED79DAD2E73339F88403D2EE85D4', 'y', unsupported_order.created_at.strftime('%-m/%-d/%Y'), 'ONE_CNET', 'F26A9FFFAD', nil]
      csv << [nil, '1TB_17.2912', nil, order_no_drive.id, order_no_drive.customer.email, 'pd', order_no_drive.address.to_field, order_no_drive.address.address, order_no_drive.address.city, order_no_drive.address.state, order_no_drive.address.zip, order_no_drive.address.country, '', nil, nil, 'y', order_no_drive.created_at.strftime('%-m/%-d/%Y'), '', 'AR3ED958E70C', nil]
      csv << [nil, 'OneTB.2890', nil, order_no_drive_shipping.id, order_no_drive_shipping.customer.email, 'pd', order_no_drive_shipping.address.to_field, order_no_drive_shipping.address.address, order_no_drive_shipping.address.city, order_no_drive_shipping.address.state, order_no_drive_shipping.address.zip, order_no_drive_shipping.address.country, nil, '', '237BE42A42675E2C020C3D9DD72D40CC', 'y', order_no_drive_shipping.created_at.strftime('%-m/%-d/%Y'), nil, nil, nil]
      csv << [nil, 'OneTB.2891', nil, "  #{order_weird_but_valid.id} ", order_weird_but_valid.customer.email, 'pd', order_weird_but_valid.address.to_field, order_weird_but_valid.address.address, order_weird_but_valid.address.city, order_weird_but_valid.address.state, order_weird_but_valid.address.zip, order_weird_but_valid.address.country, ' 001CC226EA68 ', " \n97F3ED8FD021F", "\n\n\n9E12AD27610D9CB9AADC354A87171169", 'y', order_weird_but_valid.created_at.strftime('%-m/%-d/%Y'), nil, '27671B844', "  I wrote\n\na long \nweird formatted\nnote   "]
      csv << [nil, 'OneTB.2892', nil, order_drive_no_shipping.id, order_drive_no_shipping.customer.email, 'pd', order_drive_no_shipping.address.to_field, order_drive_no_shipping.address.address, order_drive_no_shipping.address.city, order_drive_no_shipping.address.state, order_drive_no_shipping.address.zip, order_drive_no_shipping.address.country, 'B97CEA37A2989', 'C2022D425C5459B1', nil, 'y', order_drive_no_shipping.created_at.strftime('%-m/%-d/%Y'), nil, '73C420C6B4C', nil]
      csv << [nil, '1TB_17.2945', nil, 'ID00977369', 'lynmar41', 'pd', 'Lyman Jones', '3422 Arrowhead Blvd. #74', 'Blythe', 'California', '92225', 'United States of America', '001CC226D3BC', 'DM2L1YNK', '420922259405510200829271768558', 'y', '06 Jan 2017', nil, nil, nil]
      csv << [nil, nil, 'HOLD', order_hold.id, order_hold.customer.email, 'pd', order_hold.address.to_field, order_hold.address.address, order_hold.address.city, order_hold.address.state, order_hold.address.zip, order_hold.address.country, '001CC2269C00', '046538A120B023B0', '8C4FE35136C38112FA9C7E20A1839810', nil, order_hold.created_at.strftime('%-m/%-d/%Y'), 'ONE_RUSH', 'AL0ED51E5DB0', nil]
      csv << [nil, nil, 'Cancelled', order_cancelled.id, order_cancelled.customer.email, 'pd', order_cancelled.address.to_field, order_cancelled.address.address, order_cancelled.address.city, order_cancelled.address.state, order_cancelled.address.zip, order_cancelled.address.country, nil, nil, nil, nil, order_cancelled.created_at.strftime('%-m/%-d/%Y'), nil, 'BE3437C70ED88', nil]
    end
    # rubocop:enable Metrics/LineLength
    tempfile
  end
  let(:csv_file) { CSVFile.new(file: file.read) }
  let(:processor) { described_class.new(csv_file, user) }

  before do
    allow_any_instance_of(OrderState).to receive(:notify_customer)
  end

  after do
    File.unlink(file) if File.exist?(file)
  end

  describe '#line_message' do
    it 'is a formatted message about a specific line' do
      expect(processor.line_message(3, 32, 'is dumb')).to eq('line #3: Order #32 is dumb')
    end
  end

  describe '#process' do
    context 'with malformed CSV' do
      it 'does not process completely wrong file objects' do
        csv = CSVFile.new(file: File.new(file_fixture('csv_file/not_a_csv.gif').realpath))
        results = described_class.new(csv, user).process
        expect(results.success).to eq(false)
        expect(results.errors[:base]).to include('Invalid CSV file')
      end

      it 'does not process completely wrong file contents' do
        csv = CSVFile.new(file: file_fixture('csv_file/not_a_csv.gif').read)
        results = described_class.new(csv, user).process
        expect(results.success).to eq(false)
        expect(results.errors[:base]).to include('Invalid CSV file')
      end

      it 'does not process random text objects' do
        csv = CSVFile.new(file: File.new(file_fixture('csv_file/not_a_csv.txt').realpath))
        results = described_class.new(csv, user).process
        expect(results.success).to eq(false)
        expect(results.errors[:base]).to include('Invalid CSV file')
      end

      it 'does not process random text files contents' do
        csv = CSVFile.new(file: file_fixture('csv_file/not_a_csv.txt').read)
        results = described_class.new(csv, user).process
        expect(results.success).to eq(false)
        expect(results.errors[:base]).to include('Invalid CSV file')
      end
    end

    context 'with a valid file' do
      it 'returns true' do
        expect(processor.process.success).to eq(true)
      end

      it 'returns the number of records processed' do
        expect(processor.process.records_processed).to eq(7)
      end

      it 'returns the number of records updated' do
        expect(processor.process.records_updated).to eq(5)
      end

      it 'creates new drives' do
        expect do
          processor.process
        end.to change(Drive, :count).by(3)
      end

      it 'sets the drive information' do
        expect(order.drive).to eq(nil)
        processor.process
        expect(order.reload.drive).to eq(Drive.find_by!(identification_number: '001CC226B188', serial: 'DM2L684K'))
      end

      it 'adds a private status update state if notes are present' do
        expect(order.order_states.find_by(state: state_status_update)).to eq(nil)
        processor.process
        order_state = order.order_states.find_by(state: state_status_update)

        expect(order_state.user).to eq(user)
        expect(order_state.comments).to eq('I have some stuff to say')
        expect(order_state.is_public).to eq(false)
        expect(order_state.did_notify).to eq(false)
      end

      it 'adds a private shipping label state if tracking number is present' do
        expect(order.order_states.find_by(state: state_shipping_label)).to eq(nil)
        processor.process
        order_state = order.order_states.find_by(state: state_shipping_label)

        expect(order_state.user).to eq(user)
        expect(order_state.comments).to eq('USPS tracking number: FC548059CAAFBDFB4F0F5839721B6643')
        expect(order_state.is_public).to eq(false)
        expect(order_state.did_notify).to eq(false)
      end

      it 'add a public order shipped state if tracking number is present' do
        expect(order.order_states.find_by(state: state_order_shipped)).to eq(nil)
        processor.process
        order_state = order.order_states.find_by(state: state_order_shipped)

        expect(order_state.user).to eq(user)
        expect(order_state.comments).to eq('Your IDrive One has been shipped and '\
                                           'your order is complete! Your tracking '\
                                           'number is FC548059CAAFBDFB4F0F5839721B6643. '\
                                           'Please allow 2-3 days for delivery.')
        expect(order_state.is_public).to eq(true)
        expect(order_state.did_notify).to eq(true)
      end

      context 'with an unsupported order' do
        it 'is not processed' do
          expect(unsupported_order).not_to receive(:drive=)
          expect(unsupported_order.order_states).not_to receive(:find_or_create_by)
          processor.process
        end

        it 'records a warning' do
          results = processor.process
          expect(results.warnings[:file]).to include("line #3: Order ##{unsupported_order.id} is not for an IDrive One")
        end
      end

      context 'without drive information or tracking info' do
        it 'does not assign a drive' do
          expect(order_no_drive).not_to receive(:drive=)
          processor.process
        end

        it 'does not get any new states' do
          expect(order_no_drive.order_states).not_to receive(:find_or_create_by)
          processor.process
        end
      end

      context 'without drive information but having tracking info' do
        it 'does not assign a drive' do
          expect(order_no_drive_shipping).not_to receive(:drive=)
          processor.process
        end

        it 'only gets shipping info states' do
          expect(order_no_drive_shipping.order_states).not_to receive(:find_or_create_by)
          expect do
            processor.process
          end.to change { order_no_drive_shipping.order_states.count }.by(1)
        end

        it 'does not get completed' do
          expect(order_no_drive_shipping.completed_at).to eq(nil)
          processor.process
          expect(order_no_drive_shipping.completed_at).to eq(nil)
        end

        it 'records a warning about this' do
          results = processor.process
          expect(results.warnings[:file]).to include(
            "line #5: Order ##{order_no_drive_shipping.id} has a tracking "\
            'number but no drive. Order cannot be completed without a drive.'
          )
        end
      end

      context 'with weird but valid details' do
        it 'creates and assigns a drive' do
          processor.process
          drive = order_weird_but_valid.reload.drive
          expect(drive.identification_number).to eq('001CC226EA68')
          expect(drive.serial).to eq('97F3ED8FD021F')
        end

        it 'still adds the states' do
          expect do
            processor.process
          end.to change { order_weird_but_valid.order_states.size }.by(3)
        end

        it 'adds a properly formatted private status update state' do
          processor.process
          order_state = order_weird_but_valid.order_states.find_by(state: state_status_update)

          expect(order_state.comments).to eq("I wrote\n\na long \nweird formatted\nnote")
        end

        it 'adds a private state with correct shipping information' do
          processor.process
          order_state = order_weird_but_valid.order_states.find_by(state: state_shipping_label)

          expect(order_state.comments).to eq('USPS tracking number: 9E12AD27610D9CB9AADC354A87171169')
        end

        it 'adds a correctly formatted public state completing the order' do
          processor.process
          order_state = order_weird_but_valid.order_states.find_by(state: state_order_shipped)

          expect(order_state.comments).to eq('Your IDrive One has been shipped and '\
                                             'your order is complete! Your tracking '\
                                             'number is 9E12AD27610D9CB9AADC354A87171169. '\
                                             'Please allow 2-3 days for delivery.')
        end
      end

      context 'with drive information but no tracking info' do
        it 'assigns a drive' do
          expect(order_drive_no_shipping.drive).to eq(nil)
          processor.process
          expect(order_drive_no_shipping.reload.drive).to eq(
            Drive.find_by(identification_number: 'B97CEA37A2989', serial: 'C2022D425C5459B1')
          )
        end

        it 'does not get any states added' do
          expect do
            processor.process
          end.to change { order_drive_no_shipping.order_states.count }.by(0)
        end

        it 'does not get completed' do
          expect(order_drive_no_shipping.completed_at).to eq(nil)
          processor.process
          expect(order_drive_no_shipping.completed_at).to eq(nil)
        end
      end

      context 'with status "on hold"' do
        it 'does not assign a drive' do
          expect(order_hold.drive).to eq(nil)
          processor.process
          expect(order_hold.reload.drive).to eq(nil)
        end

        it 'does not get any states added' do
          expect do
            processor.process
          end.to change { order_hold.order_states.count }.by(0)
        end

        it 'does not get completed' do
          expect(order_hold.completed_at).to eq(nil)
          processor.process
          expect(order_hold.completed_at).to eq(nil)
        end

        it 'records a warning about this' do
          results = processor.process
          expect(results.warnings[:file]).to include("line #9: Order ##{order_hold.id} is on hold and was not updated")
        end
      end

      context 'with status "cancelled"' do
        it 'does not assign a drive' do
          expect(order_cancelled.drive).to eq(nil)
          processor.process
          expect(order_cancelled.reload.drive).to eq(nil)
        end

        it 'gets a cancelled state' do
          processor.process
          order_state = order_cancelled.order_states.find_by(state: state_cancelled)

          expect(order_state.comments).to eq('Your IDrive One order has been cancelled')
        end

        it 'gets completed' do
          expect(order_cancelled.completed_at).to eq(nil)
          processor.process
          expect(order_cancelled.reload.completed_at).not_to eq(nil)
        end
      end

      context 'when processing multiple times' do
        let(:multiple_processings) do
          contents = file.read
          described_class.new(CSVFile.new(file: contents), user).process
          described_class.new(CSVFile.new(file: contents), user).process
          described_class.new(CSVFile.new(file: contents), user).process
          described_class.new(CSVFile.new(file: contents), user).process
        end

        it 'is still successful' do
          expect(multiple_processings.success).to eq(true)
        end

        it 'still returns the same number of records processed' do
          expect(multiple_processings.records_processed).to eq(7)
        end

        it 'does not update any records' do
          expect(multiple_processings.records_updated).to eq(0)
        end

        it 'does not keep creating drives' do
          expect do
            multiple_processings
          end.to change(Drive, :count).by(3)
        end

        it 'does not keep creating states' do
          expect do
            multiple_processings
          end.to change { order.order_states.size }.by(3)

          expect do
            multiple_processings
          end.to change { order_weird_but_valid.order_states.size }.by(0)
        end
      end
    end
  end

  describe '#add_shipping_information' do
    context 'when the order already shipped' do
      before do
        order.order_states.create!(state: state_order_shipped, user: user,
                                   comments: 'Your order shipped', did_notify: true,
                                   is_public: true)
      end

      it 'returns false' do
        expect(processor.add_shipping_information(order, 'ABCD1234')).to eq(false)
      end

      it 'does not add a state' do
        expect do
          processor.add_shipping_information(order, 'ABCD1234')
        end.to change { order.order_states.count }.by(0)
      end
    end

    context 'when shipping information is already added' do
      before do
        order.order_states.create!(state: state_shipping_label, user: user,
                                   comments: 'USPS tracking number: EFGH5678',
                                   did_notify: false, is_public: false)
      end

      it 'returns false' do
        expect(processor.add_shipping_information(order, 'EFGH5678')).to eq(false)
      end

      it 'does not add a state' do
        expect do
          processor.add_shipping_information(order, 'EFGH5678')
        end.to change { order.order_states.count }.by(0)
      end
    end

    context 'with updated shipping information' do
      before do
        order.order_states.create!(state: state_shipping_label, user: user,
                                   comments: 'USPS tracking number: IJKL9012',
                                   did_notify: false, is_public: false)
      end

      it 'returns true' do
        expect(processor.add_shipping_information(order, 'MNOP3456')).to eq(true)
      end

      it 'adds a new state with the updated information' do
        processor.add_shipping_information(order, 'MNOP3456')
        os = order.order_states.last
        expect(os.comments).to eq('Updated USPS tracking number: MNOP3456')
      end
    end

    context 'without shipping information' do
      it 'returns true' do
        expect(processor.add_shipping_information(order, 'QRST7890')).to eq(true)
      end

      it 'adds a new state with the updated information' do
        processor.add_shipping_information(order, 'QRST7890')
        os = order.order_states.last
        expect(os.comments).to eq('USPS tracking number: QRST7890')
      end
    end
  end

  describe '#complete_order' do
    context 'when the order already shipped' do
      before do
        order.order_states.create!(state: state_order_shipped, user: user,
                                   comments: 'Your order shipped. Your tracking number is ABCD1234.',
                                   did_notify: true, is_public: true)
      end

      it 'returns false' do
        expect(processor.complete_order(order, 'ABCD1234')).to eq(false)
      end

      it 'does not add a state' do
        expect do
          processor.complete_order(order, 'ABCD1234')
        end.to change { order.order_states.count }.by(0)
      end
    end

    context 'when the order already shipped but has updated shipping information' do
      before do
        order.order_states.create!(state: state_order_shipped, user: user,
                                   comments: 'Your order shipped. Your tracking number is IJKL9012.',
                                   did_notify: false, is_public: false)
      end

      it 'returns true' do
        expect(processor.complete_order(order, 'MNOP3456')).to eq(true)
      end

      it 'adds a new state with the updated information' do
        processor.complete_order(order, 'MNOP3456')
        os = order.order_states.last
        expect(os.comments).to eq([
          'Your IDrive One has been shipped and your order is complete!',
          'Your UPDATED tracking number is MNOP3456. Please allow 2-3 days',
          'for delivery.'
        ].join(' '))
      end
    end

    context 'when the order has not shipped' do
      it 'returns true' do
        expect(processor.complete_order(order, 'QRST7890')).to eq(true)
      end

      it 'adds a new state with the updated information' do
        processor.complete_order(order, 'QRST7890')
        os = order.order_states.last
        expect(os.comments).to eq([
          'Your IDrive One has been shipped and your order is complete!',
          'Your tracking number is QRST7890. Please allow 2-3 days for',
          'delivery.'
        ].join(' '))
      end
    end
  end
end
