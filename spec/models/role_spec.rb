require 'rails_helper'

RSpec.describe Role do
  describe '.by_name' do
    it 'is ordered by name' do
      role_c = create(:role, name: 'C role', description: 'C role description', key: :c_role)
      role_a = create(:role, name: 'A role', description: 'A role description', key: :a_role)
      role_b = create(:role, name: 'B role', description: 'B role description', key: :b_role)

      expect(described_class.by_name).to eq([role_a, role_b, role_c])
    end
  end

  describe '.create' do
    it 'performs the desired works' do
      expect(create(:role_idrive_employee)).to be_instance_of(described_class)
    end
  end

  describe '#validate' do
    describe 'key' do
      it 'is required (nil)' do
        expect(build(:role_idrive_employee, key: nil).valid?).to be(false)
      end

      it 'is required (blank)' do
        expect(build(:role_idrive_employee, key: '').valid?).to be(false)
      end

      it 'only allows sane characters for the key' do
        expect(build(:role_idrive_employee, key: '$%^&*').valid?).to be(false)
      end

      it 'is unique' do
        role_key = 'cool_role'
        create(:role, key: role_key, name: 'Role 1', description: 'This is my first role')
        expect do
          create(:role, key: role_key, name: 'Role 2', description: 'This is my second role')
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    describe 'name' do
      it 'is required (nil)' do
        expect(build(:role_idrive_employee, name: nil).valid?).to be(false)
      end

      it 'is required (blank)' do
        expect(build(:role_idrive_employee, name: '').valid?).to be(false)
      end
    end

    describe 'description' do
      it 'is required (nil)' do
        expect(build(:role_idrive_employee, description: nil).valid?).to be(false)
      end

      it 'is required (blank)' do
        expect(build(:role_idrive_employee, description: '').valid?).to be(false)
      end
    end
  end
end
