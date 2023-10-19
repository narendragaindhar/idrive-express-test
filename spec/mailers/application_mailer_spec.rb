require 'rails_helper'

RSpec.describe ApplicationMailer, type: :mailer do
  describe '::IDRIVE' do
    it 'has product specific mailer info' do
      expect(ApplicationMailer::IDRIVE).to eq(
        from: 'IDrive <noreply@idrive.com>',
        reply_to: 'IDrive Support <support@idrive.com>'
      )
    end
  end

  describe '::IBACKUP' do
    it 'has product specific mailer info' do
      expect(ApplicationMailer::IBACKUP).to eq(
        from: 'IBackup <noreply@ibackup.com>',
        reply_to: 'IBackup Support <support@ibackup.com>'
      )
    end
  end

  describe '.defaults_for' do
    let(:order_type_upload) { build_stubbed(:order_type_idrive_upload) }
    let(:order_type_restore) { build_stubbed(:order_type_idrive_restore) }
    let(:order_type_idrive_one) { build_stubbed(:order_type_idrive_one) }
    let(:order_type_ibackup_upload) { build_stubbed(:order_type_ibackup_upload) }
    let(:order_type_ibackup_restore) { build_stubbed(:order_type_ibackup_restore) }

    it 'returns idrive defaults for an idrive upload order' do
      expect(described_class.defaults_for(order_type_upload)).to eq(ApplicationMailer::IDRIVE)
    end

    it 'returns idrive defaults for an idrive restore order' do
      expect(described_class.defaults_for(order_type_restore)).to eq(ApplicationMailer::IDRIVE)
    end

    it 'returns idrive defaults for an idrive one order' do
      expect(described_class.defaults_for(order_type_idrive_one)).to eq(ApplicationMailer::IDRIVE)
    end

    it 'returns ibackup defaults for an ibackup upload order' do
      expect(described_class.defaults_for(order_type_ibackup_upload)).to eq(ApplicationMailer::IBACKUP)
    end

    it 'returns ibackup defaults for an ibackup restore order' do
      expect(described_class.defaults_for(order_type_ibackup_restore)).to eq(ApplicationMailer::IBACKUP)
    end
  end
end
