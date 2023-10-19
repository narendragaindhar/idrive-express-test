require 'rails_helper'

RSpec.describe OrderQuery do
  # heads up! this test sets up all data in a before(:all) block. reason is
  # these tests were taking a long time to run and it's faster to just create
  # the data once and do queries on it later since we don't manipulate the
  # records during the tests.
  before(:all) do
    @customer = create(:customer, name: 'Mr. Joe Johnson', email: 'joe@johnson.com',
                                  username: 'joe_johnson', server: 'evs234.idrive.com')
    @user = create(:user, name: 'Percyjokavich Kuvalis', email: 'danniemundo@jast.name')
    @state_international_shipping_fee = create(:state_international_shipping_fee)

    @order_upload = create(:order_upload, customer: @customer, comments: 'hi there',
                                          created_at: Time.zone.parse('2015-10-01T12:30:00'))
    create(:order_state, comments: 'This order is shipping internationally', order: @order_upload,
                         state: @state_international_shipping_fee, user: @user)
    create(:order_state, comments: "USPS sent tracking number: X884736\n\nUSPS return tracking number: MX7288",
                         order: @order_upload, state: create(:state_shipping_label_generated))
    @order_upload.update_attribute(
      :updated_at,
      Time.zone.parse('2015-10-05T05:30:00')
    )

    @order_upload2 = create(:order_upload, size: 1_099_511_627_776)
    create(:order_state, comments: 'This order is shipping internationally',
                         order: @order_upload2, state: @state_international_shipping_fee)
    create(:order_state, comments: 'Billy Bob, this comment is for you',
                         order: @order_upload2, state: create(:state_on_hold_pre_shipped))

    @order_upload3 = create(:order_upload)
    create(:order_state, comments: 'Your IDrive Express order is complete',
                         order: @order_upload3, state: create(:state_upload_completed))

    @order_restore = create(:order_restore, customer: @customer)
    create(:order_state, comments: 'Your data restore has begun', order: @order_restore,
                         state: create(:state_restore_restore_started))

    @order_restore2 = create(:order_restore)
    create(:order_state, comments: 'This order is shipping internationally',
                         order: @order_restore2, state: create(:state_restore_international_shipping_fee))

    @order_idrive_one = create(:order_idrive_one, customer: @customer, size: 1_099_511_627_776)
    create(:order_state, comments: 'Account is paid and in good standing. No red flags found. OK to ship.',
                         order: @order_idrive_one, state: create(:state_idrive_one_account_verified))

    @order_idrive_one2 = create(:order_idrive_one, size: 1_099_511_627_776)

    @order_idrive_one3 = create(:order_idrive_one, size: 2_199_023_255_552)
    create(:order_state, comments: 'Your IDrive One order has been cancelled',
                         order: @order_idrive_one3, state: create(:state_idrive_one_order_cancelled))

    @order_idrive_bmr = create(:order_idrive_bmr)
    @order_idrive_bmr_upload = create(:order_idrive_bmr_upload)
    @order_idrive_bmr_restore = create(:order_idrive_bmr_restore)

    @order_idrive360_upload = create(:order_idrive360_upload)
    @order_idrive360_restore = create(:order_idrive360_restore)

    @order_ibackup_upload = create(
      :order_ibackup_upload, size: 2_748_779_069_440,
                             drive: create(:drive, identification_number: '48297XJH',
                                                   serial: 'MSVE4827')
    )

    @order_ibackup_upload2 = create(:order_ibackup_upload)
    create(:order_state, comments: 'This order is shipping internationally',
                         order: @order_ibackup_upload2,
                         state: create(:state_ibackup_upload_international_shipping_fee))
    create(:order_state, comments: 'Billy Bob, this comment is for you',
                         order: @order_ibackup_upload2, state: create(:state_ibackup_upload_on_hold_pre_shipped))

    @order_ibackup_restore = create(:order_ibackup_restore)

    @order_ibackup_restore2 = create(:order_ibackup_restore)
  end

  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  it 'returns the results of the plain search' do
    expect(described_class.resolve('joe_johnson')).to eq([@order_idrive_one, @order_restore, @order_upload])
  end

  it 'handles complex queries' do
    query = 'state:international state:"on hold" created:>=2016-10-02 comments:\'billy bob\''
    expect(described_class.resolve(query)).to eq([@order_ibackup_upload2, @order_upload2])
  end

  it 'returns unfiltered results for a nil query' do
    expect(described_class.resolve(nil)).to eq(
      [
        @order_ibackup_restore2,
        @order_ibackup_restore,
        @order_ibackup_upload2,
        @order_ibackup_upload,
        @order_idrive360_restore,
        @order_idrive360_upload,
        @order_idrive_bmr_restore,
        @order_idrive_bmr_upload,
        @order_idrive_bmr,
        @order_idrive_one2,
        @order_idrive_one,
        @order_restore2,
        @order_restore,
        @order_upload2,
        @order_upload,
        @order_idrive_one3,
        @order_upload3
      ]
    )
  end

  context 'with unsupported kwargs' do
    it 'has no effect on the result' do
      expect(described_class.resolve('hey:there')).to eq(
        [
          @order_ibackup_restore2,
          @order_ibackup_restore,
          @order_ibackup_upload2,
          @order_ibackup_upload,
          @order_idrive360_restore,
          @order_idrive360_upload,
          @order_idrive_bmr_restore,
          @order_idrive_bmr_upload,
          @order_idrive_bmr,
          @order_idrive_one2,
          @order_idrive_one,
          @order_restore2,
          @order_restore,
          @order_upload2,
          @order_upload,
          @order_idrive_one3,
          @order_upload3
        ]
      )
    end
  end

  context 'with query keyword :comments' do
    it 'searches order_states.comments' do
      expect(described_class.resolve('comments:X884736')).to eq([@order_upload])
    end

    it 'searches orders.comments' do
      expect(described_class.resolve('comments:"hi there"')).to eq([@order_upload])
    end

    it 'supports multiple comments' do
      expect(described_class.resolve("comments:'has begun' comments:X884")).to eq([@order_restore, @order_upload])
    end
  end

  context 'with query keyword :completed' do
    it 'searches for "today"' do
      expect(described_class.resolve('completed:today')).to eq(
        [@order_idrive_one3, @order_upload3]
      )
    end

    it 'searches whole day for format YYYY-MM-DD' do
      expect(described_class.resolve('completed:2015-10-02')).to eq([])
    end

    it 'searches exact for format YYYY-MM-DDTHH:MM:SS' do
      expect(described_class.resolve('completed:"2015-10-01T12:30:01"')).to eq([])
    end
  end

  context 'with query keyword :created' do
    it 'searches for "today"' do
      expect(described_class.resolve('created:today')).to eq(
        [
          @order_ibackup_restore2,
          @order_ibackup_restore,
          @order_ibackup_upload2,
          @order_ibackup_upload,
          @order_idrive360_restore,
          @order_idrive360_upload,
          @order_idrive_bmr_restore,
          @order_idrive_bmr_upload,
          @order_idrive_bmr,
          @order_idrive_one2,
          @order_idrive_one,
          @order_restore2,
          @order_restore,
          @order_upload2,
          @order_idrive_one3,
          @order_upload3
        ]
      )
    end

    it 'searches whole day for format YYYY-MM-DD' do
      expect(described_class.resolve('created:2015-10-01')).to eq([@order_upload])
      expect(described_class.resolve('created:2015-10-02')).to eq([])
    end

    it 'searches exact for format YYYY-MM-DDTHH:MM:SS' do
      expect(described_class.resolve('created:"2015-10-01T12:30:00"')).to eq([@order_upload])
      expect(described_class.resolve('created:"2015-10-01T12:30:01"')).to eq([])
    end

    it 'searches > date' do
      expect(described_class.resolve('created:>2015-10-02')).to eq(
        [
          @order_ibackup_restore2,
          @order_ibackup_restore,
          @order_ibackup_upload2,
          @order_ibackup_upload,
          @order_idrive360_restore,
          @order_idrive360_upload,
          @order_idrive_bmr_restore,
          @order_idrive_bmr_upload,
          @order_idrive_bmr,
          @order_idrive_one2,
          @order_idrive_one,
          @order_restore2,
          @order_restore,
          @order_upload2,
          @order_idrive_one3,
          @order_upload3
        ]
      )
    end
  end

  context 'with query keyword :customer' do
    it 'searches customers.email' do
      expect(described_class.resolve('customer:joe@johnson.com')).to eq(
        [@order_idrive_one, @order_restore, @order_upload]
      )
    end

    it 'searches customers.name' do
      expect(described_class.resolve('customer:"joe johnson"')).to eq(
        [@order_idrive_one, @order_restore, @order_upload]
      )
    end

    it 'searches customers.server' do
      expect(described_class.resolve('customer:evs234.idrive.com')).to eq(
        [@order_idrive_one, @order_restore, @order_upload]
      )
    end

    it 'searches customers.username' do
      expect(described_class.resolve('customer:joe_johnson')).to eq([@order_idrive_one, @order_restore, @order_upload])
    end
  end

  context 'with query keyword :drive' do
    it 'searches drives.identification_number' do
      expect(described_class.resolve('drive:48297XJH')).to eq([@order_ibackup_upload])
    end

    it 'searches drives.serial' do
      expect(described_class.resolve('drive:MSVE4827')).to eq([@order_ibackup_upload])
    end
  end

  context 'with query keyword :id' do
    it 'matches orders.id' do
      expect(described_class.resolve("id:#{@order_upload.id}")).to eq([@order_upload])
    end

    it 'matches multiple ids' do
      query = "id:#{@order_restore.id} id:#{@order_upload.id}"
      expect(described_class.resolve(query)).to eq([@order_restore, @order_upload])
    end
  end

  context 'with query keyword :is' do
    it 'filters by open status' do
      expect(described_class.resolve('is:open')).to eq(
        [
          @order_ibackup_restore2,
          @order_ibackup_restore,
          @order_ibackup_upload2,
          @order_ibackup_upload,
          @order_idrive360_restore,
          @order_idrive360_upload,
          @order_idrive_bmr_restore,
          @order_idrive_bmr_upload,
          @order_idrive_bmr,
          @order_idrive_one2,
          @order_idrive_one,
          @order_restore2,
          @order_restore,
          @order_upload2,
          @order_upload
        ]
      )
    end

    it 'filters by closed status' do
      expect(described_class.resolve('is:closed')).to eq([@order_idrive_one3, @order_upload3])
    end
  end

  context 'with query keyword :order_type' do
    describe 'idrive express upload' do
      let(:idrive_express_upload_orders) { [@order_upload2, @order_upload, @order_upload3] }

      it 'finds with underscores' do
        expect(described_class.resolve('order_type:idrive_upload')).to eq(idrive_express_upload_orders)
      end

      it 'finds with underscores (long)' do
        expect(described_class.resolve('order_type:idrive_express_upload')).to eq(idrive_express_upload_orders)
      end

      it 'finds with dashes' do
        expect(described_class.resolve('order_type:idrive-express-upload')).to eq(idrive_express_upload_orders)
      end

      it 'finds by name' do
        expect(described_class.resolve('order_type:"idrive upload"')).to eq(idrive_express_upload_orders)
      end

      it 'finds by name (long)' do
        expect(described_class.resolve("order_type:'idrive express upload'")).to eq(idrive_express_upload_orders)
      end
    end

    describe 'idrive express restore' do
      let(:idrive_express_restore_orders) { [@order_restore2, @order_restore] }

      it 'finds with underscores' do
        expect(described_class.resolve('order_type:idrive_restore')).to eq(idrive_express_restore_orders)
      end

      it 'finds with underscores (long)' do
        expect(described_class.resolve('order_type:idrive_express_restore')).to eq(idrive_express_restore_orders)
      end

      it 'finds with dashes' do
        expect(described_class.resolve('order_type:idrive-express-restore')).to eq(idrive_express_restore_orders)
      end

      it 'finds by name' do
        expect(described_class.resolve('order_type:"idrive restore"')).to eq(idrive_express_restore_orders)
      end

      it 'finds by name (long)' do
        expect(described_class.resolve("order_type:'idrive express restore'")).to eq(idrive_express_restore_orders)
      end
    end

    describe 'idrive one' do
      let(:idrive_one_orders) { [@order_idrive_one2, @order_idrive_one, @order_idrive_one3] }

      it 'finds with underscores' do
        expect(described_class.resolve('order_type:idrive_one')).to eq(idrive_one_orders)
      end

      it 'finds with dashes' do
        expect(described_class.resolve('order_type:idrive-one')).to eq(idrive_one_orders)
      end

      it 'finds by name' do
        expect(described_class.resolve('order_type:one')).to eq(idrive_one_orders)
      end

      it 'finds by name (long)' do
        expect(described_class.resolve('order_type:"idrive one"')).to eq(idrive_one_orders)
      end
    end

    describe 'idrive bmr' do
      let(:idrive_bmr_orders) { [@order_idrive_bmr] }

      it 'finds with underscores' do
        expect(described_class.resolve('order_type:idrive_bmr')).to eq(idrive_bmr_orders)
      end

      it 'finds with dashes' do
        expect(described_class.resolve('order_type:idrive-bmr')).to eq(idrive_bmr_orders)
      end

      it 'finds by name' do
        expect(described_class.resolve('order_type:bmr')).to eq(idrive_bmr_orders)
      end

      it 'finds by name (long)' do
        expect(described_class.resolve('order_type:"idrive bmr"')).to eq(idrive_bmr_orders)
      end
    end

    describe 'idrive bmr express upload' do
      let(:idrive_bmr_upload_orders) { [@order_idrive_bmr_upload] }

      it 'finds with underscores' do
        expect(described_class.resolve('order_type:idrive_bmr_upload')).to eq(idrive_bmr_upload_orders)
      end

      it 'finds with underscores (long)' do
        expect(described_class.resolve('order_type:idrive_bmr_express_upload')).to eq(idrive_bmr_upload_orders)
      end

      it 'finds with dashes' do
        expect(described_class.resolve('order_type:idrive-bmr-express-upload')).to eq(idrive_bmr_upload_orders)
      end

      it 'finds by name' do
        expect(described_class.resolve('order_type:"idrive bmr upload"')).to eq(idrive_bmr_upload_orders)
      end

      it 'finds by name (long)' do
        expect(described_class.resolve("order_type:'idrive bmr express upload'")).to eq(idrive_bmr_upload_orders)
      end
    end

    describe 'idrive bmr express restore' do
      let(:idrive_bmr_restore_orders) { [@order_idrive_bmr_restore] }

      it 'finds with underscores' do
        expect(described_class.resolve('order_type:idrive_bmr_restore')).to eq(idrive_bmr_restore_orders)
      end

      it 'finds with underscores (long)' do
        expect(described_class.resolve('order_type:idrive_bmr_express_restore')).to eq(idrive_bmr_restore_orders)
      end

      it 'finds with dashes' do
        expect(described_class.resolve('order_type:idrive-bmr-express-restore')).to eq(idrive_bmr_restore_orders)
      end

      it 'finds by name' do
        expect(described_class.resolve('order_type:"idrive bmr restore"')).to eq(idrive_bmr_restore_orders)
      end

      it 'finds by name (long)' do
        expect(described_class.resolve("order_type:'idrive bmr express restore'")).to eq(idrive_bmr_restore_orders)
      end
    end

    describe 'idrive360 express upload' do
      let(:idrive360_upload_orders) { [@order_idrive360_upload] }

      it 'finds with underscores' do
        expect(described_class.resolve('order_type:idrive360_upload')).to eq(idrive360_upload_orders)
      end

      it 'finds with underscores (long)' do
        expect(described_class.resolve('order_type:idrive360_express_upload')).to eq(idrive360_upload_orders)
      end

      it 'finds with dashes' do
        expect(described_class.resolve('order_type:idrive360-express-upload')).to eq(idrive360_upload_orders)
      end

      it 'finds by name' do
        expect(described_class.resolve('order_type:"idrive360 upload"')).to eq(idrive360_upload_orders)
      end

      it 'finds by name (long)' do
        expect(described_class.resolve("order_type:'idrive360 express upload'")).to eq(idrive360_upload_orders)
      end

      it 'finds by name (space)' do
        expect(described_class.resolve("order_type:'idrive 360 express upload'")).to eq(idrive360_upload_orders)
      end
    end

    describe 'idrive360 express restore' do
      let(:idrive360_restore_orders) { [@order_idrive360_restore] }

      it 'finds with underscores' do
        expect(described_class.resolve('order_type:idrive360_restore')).to eq(idrive360_restore_orders)
      end

      it 'finds with underscores (long)' do
        expect(described_class.resolve('order_type:idrive360_express_restore')).to eq(idrive360_restore_orders)
      end

      it 'finds with dashes' do
        expect(described_class.resolve('order_type:idrive360-express-restore')).to eq(idrive360_restore_orders)
      end

      it 'finds by name' do
        expect(described_class.resolve('order_type:"idrive360 restore"')).to eq(idrive360_restore_orders)
      end

      it 'finds by name (long)' do
        expect(described_class.resolve("order_type:'idrive360 express restore'")).to eq(idrive360_restore_orders)
      end

      it 'finds by name (space)' do
        expect(described_class.resolve("order_type:'idrive 360 express restore'")).to eq(idrive360_restore_orders)
      end
    end

    describe 'ibackup express upload' do
      let(:ibackup_express_upload_orders) { [@order_ibackup_upload2, @order_ibackup_upload] }

      it 'finds with underscores' do
        expect(described_class.resolve('order_type:ibackup_upload')).to eq(ibackup_express_upload_orders)
      end

      it 'finds with underscores (long)' do
        expect(described_class.resolve('order_type:ibackup_express_upload')).to eq(ibackup_express_upload_orders)
      end

      it 'finds with dashes' do
        expect(described_class.resolve('order_type:ibackup-express-upload')).to eq(ibackup_express_upload_orders)
      end

      it 'finds by name' do
        expect(described_class.resolve('order_type:"ibackup upload"')).to eq(ibackup_express_upload_orders)
      end

      it 'finds by name (long)' do
        expect(described_class.resolve("order_type:'ibackup express upload'")).to eq(ibackup_express_upload_orders)
      end
    end

    describe 'ibackup express restore' do
      let(:ibackup_express_restore_orders) { [@order_ibackup_restore2, @order_ibackup_restore] }

      it 'finds with underscores' do
        expect(described_class.resolve('order_type:ibackup_restore')).to eq(ibackup_express_restore_orders)
      end

      it 'finds with underscores (long)' do
        expect(described_class.resolve('order_type:ibackup_express_restore')).to eq(ibackup_express_restore_orders)
      end

      it 'finds with dashes' do
        expect(described_class.resolve('order_type:ibackup-express-restore')).to eq(ibackup_express_restore_orders)
      end

      it 'finds by name' do
        expect(described_class.resolve('order_type:"ibackup restore"')).to eq(ibackup_express_restore_orders)
      end

      it 'finds by name (long)' do
        expect(described_class.resolve("order_type:'ibackup express restore'")).to eq(ibackup_express_restore_orders)
      end
    end

    context 'with random words' do
      it 'finds by single word' do
        expect(described_class.resolve('order_type:upload')).to eq(
          [@order_ibackup_upload2, @order_ibackup_upload, @order_idrive360_upload, @order_idrive_bmr_upload,
           @order_upload2, @order_upload, @order_upload3]
        )
      end

      it 'finds by multiple words' do
        expect(described_class.resolve('order_type:"express restore"')).to eq(
          [@order_ibackup_restore2, @order_ibackup_restore, @order_idrive360_restore,
           @order_idrive_bmr_restore, @order_restore2, @order_restore]
        )
      end
    end
  end

  context 'with query keyword :size' do
    it 'searches orders.size' do
      expect(described_class.resolve('size:1tb')).to eq([@order_idrive_one2, @order_idrive_one, @order_upload2])
    end

    it 'supports fractional values' do
      expect(described_class.resolve('size:2.5Tb')).to eq([@order_ibackup_upload])
    end

    it 'supports multiple sizes' do
      expect(described_class.resolve('size:1TB size:2TB')).to eq(
        [@order_idrive_one2, @order_idrive_one, @order_upload2, @order_idrive_one3]
      )
    end
  end

  context 'with query keyword :state' do
    it 'searches states.label' do
      expect(described_class.resolve('state:"verification ok"')).to eq([@order_idrive_one])
    end

    it 'supports multiple labels' do
      expect(described_class.resolve('state:"restore started" state:shipping')).to eq(
        [@order_ibackup_upload2, @order_restore2, @order_restore, @order_upload2, @order_upload]
      )
    end
  end

  context 'with query keyword :updated' do
    it 'searches for "today"' do
      expect(described_class.resolve('updated:today')).to eq(
        [
          @order_ibackup_restore2,
          @order_ibackup_restore,
          @order_ibackup_upload2,
          @order_ibackup_upload,
          @order_idrive360_restore,
          @order_idrive360_upload,
          @order_idrive_bmr_restore,
          @order_idrive_bmr_upload,
          @order_idrive_bmr,
          @order_idrive_one2,
          @order_idrive_one,
          @order_restore2,
          @order_restore,
          @order_upload2,
          @order_idrive_one3,
          @order_upload3
        ]
      )
    end

    it 'searches whole day for format YYYY-MM-DD' do
      expect(described_class.resolve('updated:2015-10-05')).to eq([@order_upload])
    end

    it 'searches exact for format YYYY-MM-DDTHH:MM:SS' do
      expect(described_class.resolve('updated:"2015-10-01T12:30:01"')).to eq([])
    end
  end

  context 'with query keyword :user' do
    it 'searches users.name' do
      expect(described_class.resolve('user:Percyjokavich')).to eq([@order_upload])
    end

    it 'searches users.email' do
      expect(described_class.resolve('user:danniemundo@jast.name')).to eq([@order_upload])
    end
  end
end
