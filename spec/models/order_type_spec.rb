require 'rails_helper'

RSpec.describe OrderType do
  let(:order_type_upload) { create(:order_type_idrive_upload) }
  let(:order_type_restore) { create(:order_type_idrive_restore) }
  let(:order_type_idrive_one) { create(:order_type_idrive_one) }
  let(:order_type_ibackup_upload) { create(:order_type_ibackup_upload) }
  let(:order_type_ibackup_restore) { create(:order_type_ibackup_restore) }

  describe '.product' do
    it 'returns the association' do
      expect(order_type_upload.product).to eq(Product.find_by(name: :idrive))
    end
  end

  describe '#full_name' do
    it 'returns the full name of idrive upload' do
      expect(order_type_upload.full_name).to eq('IDrive Express Upload')
    end

    it 'returns the full name of idrive restore' do
      expect(order_type_restore.full_name).to eq('IDrive Express Restore')
    end

    it 'returns the full name of idrive one' do
      expect(order_type_idrive_one.full_name).to eq('IDrive One')
    end

    it 'returns the full name of ibackup upload' do
      expect(order_type_ibackup_upload.full_name).to eq('IBackup Express Upload')
    end

    it 'returns the full name of ibackup restore' do
      expect(order_type_ibackup_restore.full_name).to eq('IBackup Express Restore')
    end
  end

  describe '#key=' do
    it 'downcases the key' do
      expect(build_stubbed(:order_type_idrive_upload, key: 'KEY').key).to eq('key')
    end
  end

  describe '#key_is?' do
    it 'checks if it is an idrive express upload' do
      expect(order_type_upload.key_is?(:idrive_upload)).to eq(true)
      expect(order_type_upload.key_is?(:idrive_restore)).to eq(false)
      expect(order_type_upload.key_is?(:idrive_one)).to eq(false)
      expect(order_type_upload.key_is?(:ibackup_upload)).to eq(false)
      expect(order_type_upload.key_is?(:ibackup_restore)).to eq(false)
    end

    it 'checks if it is an idrive express restore' do
      expect(order_type_restore.key_is?(:idrive_upload)).to eq(false)
      expect(order_type_restore.key_is?(:idrive_restore)).to eq(true)
      expect(order_type_restore.key_is?(:idrive_one)).to eq(false)
      expect(order_type_upload.key_is?(:ibackup_upload)).to eq(false)
      expect(order_type_upload.key_is?(:ibackup_restore)).to eq(false)
    end

    it 'checks if it is an idrive one' do
      expect(order_type_idrive_one.key_is?(:idrive_upload)).to eq(false)
      expect(order_type_idrive_one.key_is?(:idrive_restore)).to eq(false)
      expect(order_type_idrive_one.key_is?(:idrive_one)).to eq(true)
      expect(order_type_upload.key_is?(:ibackup_upload)).to eq(false)
      expect(order_type_upload.key_is?(:ibackup_restore)).to eq(false)
    end

    it 'checks if it is an ibackup express upload' do
      expect(order_type_ibackup_upload.key_is?(:idrive_upload)).to eq(false)
      expect(order_type_ibackup_upload.key_is?(:idrive_restore)).to eq(false)
      expect(order_type_ibackup_upload.key_is?(:idrive_one)).to eq(false)
      expect(order_type_ibackup_upload.key_is?(:ibackup_upload)).to eq(true)
      expect(order_type_ibackup_upload.key_is?(:ibackup_restore)).to eq(false)
    end

    it 'checks if it is an ibackup express restore' do
      expect(order_type_ibackup_restore.key_is?(:idrive_upload)).to eq(false)
      expect(order_type_ibackup_restore.key_is?(:idrive_restore)).to eq(false)
      expect(order_type_ibackup_restore.key_is?(:idrive_one)).to eq(false)
      expect(order_type_ibackup_restore.key_is?(:ibackup_upload)).to eq(false)
      expect(order_type_ibackup_restore.key_is?(:ibackup_restore)).to eq(true)
    end

    it 'accepts multiple keys' do
      expect(order_type_upload.key_is?(:idrive_one, :idrive_upload)).to eq(true)
      expect(order_type_upload.key_is?(:ibackup_restore, :idrive_one)).to eq(false)
    end
  end

  describe '#validate' do
    describe 'key' do
      it 'is required' do
        expect(build(:order_type_idrive_upload, key: nil)).not_to be_valid
      end

      it 'matches a simple format' do
        expect(build(:order_type_idrive_upload, key: 'bad format $$')).not_to be_valid
      end

      it 'is unique' do
        create(:order_type_idrive_upload, key: 'new_order_type')
        expect(build(:order_type_idrive_upload, key: 'new_order_type')).not_to be_valid
      end
    end

    describe 'name' do
      it 'is required' do
        expect(build(:order_type_idrive_upload, name: nil)).not_to be_valid
      end
    end

    describe 'product' do
      it 'is required' do
        expect(build(:order_type_idrive_upload, product: nil)).not_to be_valid
      end
    end
  end
end
