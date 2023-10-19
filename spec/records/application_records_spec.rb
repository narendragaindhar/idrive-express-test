require 'rails_helper'

RSpec.describe ApplicationRecords do
  let(:core) { { key: :super_user } }
  let(:create_attrs) do
    {
      'name' => 'Superuser',
      'description' => 'A superuser has permission to control all aspects of the site'
    }
  end
  let(:record) do
    {
      'core' => core,
      'create' => create_attrs
    }
  end
  let(:records) { described_class.new('020-role') }

  describe '.seed!' do
    it 'creates all the records' do
      expect { described_class.seed! }.to change(Address, :count).and \
        change(Product, :count).and \
          change(Role, :count).and \
            change(Destination, :count).and \
              change(OrderType, :count).and \
                change(State, :count)
    end

    it 'is idempotent' do
      described_class.seed!
      expect { described_class.seed! }.to change(Address, :count).by(0).and \
        change(Product, :count).by(0).and \
          change(Role, :count).by(0).and \
            change(Destination, :count).by(0).and \
              change(OrderType, :count).by(0).and \
                change(State, :count).by(0)
    end

    it 'can be dry run' do
      expect { described_class.seed!(dry_run: true) }.to \
        change(Address, :count).by(0).and \
          change(Product, :count).by(0).and \
            change(Role, :count).by(0).and \
              change(Destination, :count).by(0).and \
                change(OrderType, :count).by(0).and \
                  change(State, :count).by(0)
    end
  end

  describe '#initialize' do
    it 'throws an error if the model cannot be found' do
      expect(YAML).to receive(:load_file)
        .and_return('model_class' => 'Nope', 'records' => [])
      expect { records }.to raise_error NameError
    end

    it 'throws an error if it is not an active record model' do
      expect(YAML).to receive(:load_file)
        .and_return('model_class' => 'ApplicationController', 'records' => [])
      expect { records }.to raise_error 'Not a rails model: ApplicationController'
    end
  end

  describe '#create!' do
    it 'creates a new record' do
      expect { records.create!(record) }.to change(Role, :count).from(0).to(1)
    end
  end

  describe '#find_and_update!' do
    it 'returns `false` if no drifting has occurred' do
      records.seed!
      expect(records.find_and_update!(record)).to eq(false)
    end

    context 'without update data' do
      let(:role) { Role.find_by! key: :super_user }

      before do
        records.seed!
        role.update! name: 'NOT SUPER'
      end

      it 'does not update the record if it has drifted' do
        expect do
          records.find_and_update!(record)
        end.not_to change(role, :name)
      end

      it 'returns `false`' do
        expect(records.find_and_update!(record)).to eq(false)
      end
    end

    context 'with update data' do
      let(:record) do
        {
          'core' => core,
          'update' => {
            'name' => 'Superuser'
          },
          'create' => create_attrs
        }
      end
      let(:role) { Role.find_by! key: :super_user }

      before do
        records.seed!
        role.update! name: 'NOT SUPER'
      end

      it 'updates the record if it has drifted' do
        expect do
          records.find_and_update!(record)
        end.to change { role.reload.name }.from('NOT SUPER').to('Superuser')
      end

      it 'returns `true` if it updates the record' do
        expect(records.find_and_update!(record)).to eq(true)
      end
    end
  end

  describe '#seed!' do
    it 'creates all roles' do
      expect { records.seed! }.to change(Role, :count).from(0).to(7)
    end

    it 'is idempotent' do
      records.seed!
      expect do
        records.seed!
        records.seed!
        records.seed!
      end.not_to change(Role, :count)
    end

    it 'works with associations' do
      described_class.new('010-product').seed!
      expect do
        described_class.new('040-order_type').seed!
        described_class.new('040-order_type').seed!
      end.to change(OrderType, :count).from(0).to(10)
    end

    context 'when doing a dry run' do
      let!(:role) { create(:role_super_user, name: 'SUPERRR') }

      it 'creates none' do
        records = described_class.new('020-role', dry_run: true)
        expect { records.seed! }.not_to change(Role, :count).from(1)
      end

      it 'updates none' do
        records = described_class.new('020-role', dry_run: true)
        expect { records.seed! }.not_to change(role, :name)
      end
    end
  end
end
