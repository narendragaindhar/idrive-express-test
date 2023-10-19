require 'rails_helper'

RSpec.describe Order do
  let!(:state_initial) { State.find_by(key: 'upload_order_created') || create(:state_initial) }
  let(:order) { create(:order) }
  let(:order_with_drive) { create(:order_with_drive) }

  describe '::Sizable' do
    describe '#size_units' do
      it 'returns the correct human readable label' do
        order = create(:order, size: 5_368_709_120)
        expect(order.size_units).to eq('GB')
      end
    end

    describe '#size_count' do
      it 'returns the correct human readable count' do
        order = create(:order, size: 5_368_709_120)
        expect(order.size_count).to eq('5')
      end
    end

    describe '#size_count= and #size_units=' do
      it 'allows setting :size via bytes' do
        order_with_drive.update!(size_units: 'B', size_count: 1)
        expect(order_with_drive.size).to eq(1)
      end

      it 'allows setting :size via kilobytes' do
        order_with_drive.update!(size_units: 'KB', size_count: 1)
        expect(order_with_drive.size).to eq(1024)
      end

      it 'allows setting :size via megabytes' do
        order_with_drive.update!(size_units: 'MB', size_count: 1)
        expect(order_with_drive.size).to eq(1_048_576)
      end

      it 'allows setting :size via gigabytes' do
        order_with_drive.update!(size_units: 'GB', size_count: 1)
        expect(order_with_drive.size).to eq(1_073_741_824)
      end

      it 'allows setting :size via terabytes' do
        order_with_drive.update!(size_units: 'TB', size_count: 1)
        expect(order_with_drive.size).to eq(1_099_511_627_776)
      end

      it 'allows setting :size via petabytes' do
        order_with_drive.update!(size_units: 'PB', size_count: 1)
        expect(order_with_drive.size).to eq(1_125_899_906_842_624)
      end
    end
  end

  describe '.after_create' do
    it 'assigns an initial state' do
      expect(order.order_states.first.state).to eq(state_initial)
    end

    it 'assigns an initial state with stability' do
      create(:state_international_shipping_fee, percentage: 5)
      expect(order.order_states.first.state).to eq(state_initial)
    end

    context 'with an idrive restore order' do
      let!(:state_initial) { State.find_by(key: 'restore_order_created') || create(:state_restore_initial) }
      let(:order) { create(:order_restore) }

      it 'assigns an initial state' do
        expect(order.order_states.first.state).to eq(state_initial)
      end
    end

    context 'with an idrive one order' do
      let!(:state_initial) { State.find_by(key: 'idrive_one_order_created') || create(:state_idrive_one_initial) }
      let(:order) { create(:order_idrive_one) }

      it 'assigns an initial state' do
        expect(order.order_states.first.state).to eq(state_initial)
      end
    end

    context 'with an ibackup upload order' do
      let!(:state_initial) do
        State.find_by(key: 'ibackup_upload_order_created') || create(:state_ibackup_upload_initial)
      end
      let(:order) { create(:order_ibackup_upload) }

      it 'assigns an initial state' do
        expect(order.order_states.first.state).to eq(state_initial)
      end
    end
  end

  describe '.to_csv' do
    let!(:order1) do
      create(:order_upload, customer: create(:customer, username: 'user1'),
                            address: create(:address, recipient: 'Mrs. Orin Emmerich', organization: nil,
                                                      address: '77020 Javier Lake', city: 'West King',
                                                      state: 'New Jersey', zip: '76489-1059', country: 'USA'))
    end
    let!(:order2) do
      create(:order_idrive_one, customer: create(:customer, username: 'user2'),
                                address: create(:address, recipient: 'Jamaal Kiehn', organization: 'Kihn-Klocko',
                                                          address: '3164 Garfield Parkways',
                                                          city: 'North Darlenemouth', state: 'NM', zip: '87378-5643',
                                                          country: 'USA'))
    end
    let!(:order3) do
      create(:order_ibackup_upload, customer: create(:customer, username: 'user3'),
                                    address: create(:address, recipient: nil, organization: 'Haley Inc',
                                                              address: '9107 Werner Ranch', city: 'Port Cory',
                                                              state: nil, zip: 'ADFF215', country: 'Germany'))
    end

    it 'returns csv formatted text with all orders' do
      expect(described_class.all.to_csv).to eq(
        <<-CSV.strip_heredoc
        #{order1.id},user1,Mrs. Orin Emmerich,77020 Javier Lake,West King,New Jersey,76489-1059,USA
        #{order2.id},user2,Jamaal Kiehn c/o Kihn-Klocko,3164 Garfield Parkways,North Darlenemouth,NM,87378-5643,USA
        #{order3.id},user3,Haley Inc,9107 Werner Ranch,Port Cory,,ADFF215,Germany
        CSV
      )
    end
  end

  describe '#create_day_count' do
    it 'creates a DayCount with proper staleness' do
      day_count = order.create_day_count
      expect(day_count.persisted?).to eq(true)
      expect(day_count.stale?).to eq(true)
    end
  end

  describe '#labelize' do
    let(:customer) { create(:customer, username: 'the_user') }

    it 'describes idrive upload orders' do
      expect(create(:order_upload, customer: customer).labelize).to match(
        /\A#\d+ \| IDrive Express Upload for the_user\z/
      )
    end

    it 'describes idrive restore orders' do
      expect(create(:order_restore, customer: customer).labelize).to match(
        /\A#\d+ \| IDrive Express Restore for the_user\z/
      )
    end

    it 'describes idrive one orders' do
      expect(
        create(:order_idrive_one, size: 274_877_906_944, comments: 'SSD', customer: customer).labelize
      ).to match(/\A#\d+ \| IDrive One \(256 GB SSD\) for the_user\z/)
    end

    it 'describes idrive bmr orders' do
      expect(
        create(:order_idrive_bmr, customer: customer).labelize
      ).to match(/\A#\d+ \| IDrive BMR for the_user\z/)
    end

    it 'describes idrive bmr express upload orders' do
      expect(
        create(:order_idrive_bmr_upload, customer: customer).labelize
      ).to match(/\A#\d+ \| IDrive BMR Express Upload for the_user\z/)
    end

    it 'describes idrive bmr express restore orders' do
      expect(
        create(:order_idrive_bmr_restore, customer: customer).labelize
      ).to match(/\A#\d+ \| IDrive BMR Express Restore for the_user\z/)
    end

    it 'describes idrive360 express upload orders' do
      expect(
        create(:order_idrive360_upload, customer: customer).labelize
      ).to match(/\A#\d+ \| IDrive360 Express Upload for the_user\z/)
    end

    it 'describes idrive360 express restore orders' do
      expect(
        create(:order_idrive360_restore, customer: customer).labelize
      ).to match(/\A#\d+ \| IDrive360 Express Restore for the_user\z/)
    end

    it 'describes ibackup upload orders' do
      expect(create(:order_ibackup_upload, customer: customer).labelize).to match(
        /\A#\d+ \| IBackup Express Upload for the_user\z/
      )
    end

    it 'describes ibackup restore orders' do
      expect(create(:order_ibackup_restore, customer: customer).labelize).to match(
        /\A#\d+ \| IBackup Express Restore for the_user\z/
      )
    end
  end

  describe '#to_csv' do
    let(:customer) { create(:customer, username: 'sweet_username') }
    let(:address_recipient) do
      create(:address, recipient: 'Dr. Joe, PhD', organization: nil,
                       address: '18492 Fleet St.', city: 'Paradise Falls',
                       state: 'NY', zip: '91847', country: 'USA')
    end
    let(:address_organization) do
      create(:address, recipient: nil, organization: 'The Biz LLC',
                       address: '844 Elm St.', city: 'Cooltown', state: 'CO',
                       zip: '81472', country: 'USA')
    end
    let(:address_both) do
      create(:address, recipient: 'Mail Receiving', organization: 'The Resort',
                       address: '99 Park Place', city: 'Big City', state: 'WA',
                       zip: '65845', country: 'USA')
    end

    it 'converts the order into a usable csv string' do
      expect(
        create(:order, customer: customer, address: address_recipient).to_csv
      ).to match(/\A\d+,sweet_username,"Dr. Joe, PhD",18492 Fleet St.,Paradise Falls,NY,91847,USA\n\z/)
    end

    it 'will return an array back if format: :array' do
      order = create(:order, customer: customer, address: address_recipient)
      expect(order.to_csv(format: :array)).to eq(
        [order.id, 'sweet_username', 'Dr. Joe, PhD', '18492 Fleet St.', 'Paradise Falls', 'NY', '91847', 'USA']
      )
    end

    it 'works if address only has a organization field' do
      expect(
        create(:order, customer: customer, address: address_organization).to_csv
      ).to match(/\A\d+,sweet_username,The Biz LLC,844 Elm St.,Cooltown,CO,81472,USA\n\z/)
    end

    it 'works if address has both recipient and organization fields' do
      expect(
        create(:order, customer: customer, address: address_both).to_csv
      ).to match(%r{\A\d+,sweet_username,Mail Receiving c/o The Resort,99 Park Place,Big City,WA,65845,USA\n\z})
    end
  end

  describe '#validate' do
    describe 'address' do
      it 'is required (nil)' do
        expect(build(:order, address: nil)).not_to be_valid
      end

      it 'is invalid if the address is outside of the USA for idrive one orders' do
        %w[Mexico France Denmark Japan].each do |country|
          order = build(:order_idrive_one, address: create(:address, country: country))
          expect(order.valid?).to be false
          expect(order.errors[:base]).to eq(['Cannot ship to addresses outside of the USA'])
        end
      end
    end

    describe 'customer' do
      it 'is required (nil)' do
        expect(build(:order, customer: nil)).not_to be_valid
      end
    end

    describe 'destination' do
      it 'is required (nil)' do
        expect(build(:order, destination: nil)).not_to be_valid
      end
    end

    describe 'drive' do
      context 'when creating' do
        it 'is not required' do
          expect(build(:order, drive: nil)).to be_valid
        end
      end

      context 'when updating' do
        it 'is required' do
          expect(create(:order, drive: nil)).not_to be_valid
        end
      end
    end

    describe 'order_type' do
      it 'is required (nil)' do
        expect(build(:order, order_type: nil)).not_to be_valid
      end
    end

    describe 'size' do
      it 'is required (nil)' do
        expect(build(:order, size: nil)).not_to be_valid
      end

      it 'is required (blank)' do
        expect(build(:order, size: '')).not_to be_valid
      end

      it 'is >= 0' do
        expect(build(:order, size: -1)).not_to be_valid
      end
    end
  end
end
