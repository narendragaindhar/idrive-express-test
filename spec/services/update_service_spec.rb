require 'rails_helper'

RSpec.describe UpdateService do
  let(:order) { build_stubbed(:order_upload) }
  let(:state) { build_stubbed(:state_upload_started) }
  let(:order_state) { build_stubbed(:order_state, order: order, state: state, is_public: true) }

  describe '.perform' do
    context 'with an IDrive order' do
      it 'notifies the IDrive API of the changes' do
        expect_any_instance_of(IDriveUpdateService).to receive(:enabled?).and_return(true)
        expect_any_instance_of(IDriveUpdateService).to receive(:perform).and_return(true)
        expect(described_class.perform(order_state)).to eq(true)
      end

      it 'returns false if it fails' do
        expect_any_instance_of(IDriveUpdateService).to receive(:enabled?).and_return(true)
        expect_any_instance_of(IDriveUpdateService).to receive(:perform).and_return(false)
        expect(described_class.perform(order_state)).to eq(false)
      end

      it 'does not notify the IDrive API if it is disabled' do
        expect_any_instance_of(IDriveUpdateService).to receive(:enabled?).and_return(false)
        expect(described_class.perform(order_state)).to eq(true)
      end
    end

    context 'with an IDrive360 order' do
      let(:order) { build_stubbed(:order_idrive360_upload) }
      let(:state) { build_stubbed(:state_idrive360_upload) }

      it 'notifies the IDrive360 API of the changes' do
        expect_any_instance_of(IDrive360UpdateService).to receive(:enabled?).and_return(true)
        expect_any_instance_of(IDrive360UpdateService).to receive(:perform).and_return(true)
        expect(described_class.perform(order_state)).to eq(true)
      end

      it 'returns false if it fails' do
        expect_any_instance_of(IDrive360UpdateService).to receive(:enabled?).and_return(true)
        expect_any_instance_of(IDrive360UpdateService).to receive(:perform).and_return(false)
        expect(described_class.perform(order_state)).to eq(false)
      end

      it 'does not notify the IDrive360 API if it is disabled' do
        expect_any_instance_of(IDrive360UpdateService).to receive(:enabled?).and_return(false)
        expect(described_class.perform(order_state)).to eq(true)
      end
    end

    context 'with an IBackup order' do
      let(:order) { build_stubbed(:order_ibackup_upload) }
      let(:state) { build_stubbed(:state_ibackup_upload_started) }

      it 'notifies the IBackup API of the changes' do
        expect_any_instance_of(IBackupUpdateService).to receive(:enabled?).and_return(true)
        expect_any_instance_of(IBackupUpdateService).to receive(:perform).and_return(true)
        expect(described_class.perform(order_state)).to eq(true)
      end

      it 'returns false if it fails' do
        expect_any_instance_of(IBackupUpdateService).to receive(:enabled?).and_return(true)
        expect_any_instance_of(IBackupUpdateService).to receive(:perform).and_return(false)
        expect(described_class.perform(order_state)).to eq(false)
      end

      it 'does not notify the IBackup API if it is disabled' do
        expect_any_instance_of(IBackupUpdateService).to receive(:enabled?).and_return(false)
        expect(described_class.perform(order_state)).to eq(true)
      end
    end
  end

  describe '#initialize' do
    before do
      allow_any_instance_of(described_class).to receive(:product).and_return('IProduct')
    end

    it 'does not initialize proxy settings if not present in environment' do
      allow(ENV).to receive('fetch').with('FIXIE_URL', '').and_return('')
      expect(described_class).not_to receive(:http_proxy)

      described_class.new(order_state)
    end

    it 'can be initialized with proxy_url from environment' do
      allow(ENV).to receive('fetch').with('FIXIE_URL', '').and_return('http://user:pass@fixie.com:80')
      expect(described_class).to receive(:http_proxy).with('fixie.com', 80, 'user', 'pass')

      described_class.new(order_state)
    end

    it 'can be initialized with proxy_url keyword arg' do
      expect(described_class).to receive(:http_proxy).with('myproxy.com', 80, 'user', 'pass')
      described_class.new(order_state, proxy_url: 'http://user:pass@myproxy.com:80')
    end
  end

  describe '#perform' do
    let(:updater) { described_class.new(order_state) }

    before do
      allow_any_instance_of(described_class).to receive(:product).and_return('IProduct')
      allow_any_instance_of(described_class).to receive(:url).and_return('https://www.iproduct.com/api')
      allow_any_instance_of(described_class).to receive(:auth_token).and_return('super_secret')
    end

    it 'returns true when the update succeeds' do
      dbl = double
      expect(dbl).to receive(:code).and_return(200)
      expect(described_class).to receive(:post) do |url, **_kwargs|
        expect(url).to eq('https://www.iproduct.com/api')
        dbl
      end

      expect(updater.perform).to eq(true)
    end

    it 'returns false when the update fails with invalid data' do
      dbl = double
      expect(dbl).to receive(:code).twice.and_return(500)
      expect(dbl).to receive(:headers).and_return({})
      expect(dbl).to receive(:body).and_return('Oh noes server error!')
      expect(described_class).to receive(:post).and_return(dbl)
      expect(updater.perform).to eq(false)
    end
  end
end
