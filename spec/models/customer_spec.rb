require 'rails_helper'

RSpec.describe Customer do
  let(:product) { create(:product_idrive) }
  let(:customer) do
    build_stubbed(:customer, name: 'Berneice Aufderhar', product: product,
                             username: 'berneice_aufderhar1')
  end

  describe '.search' do
    let!(:customer_1) { create(:customer, name: 'Avery Billings', email: 'billings@example.com', username: 'gretchen') }
    let!(:customer_2) { create(:customer, name: 'Charlie Dockens', email: 'dockens@company.biz', username: 'mozell') }

    it 'returns customers matching email' do
      expect(described_class.search('billin')).to eq([customer_1])
    end

    it 'returns customers matching name' do
      expect(described_class.search('Avery')).to eq([customer_1])
    end

    it 'returns customers matching username' do
      expect(described_class.search('moze')).to eq([customer_2])
    end

    it 'matches name field anywhere in the query' do
      expect(described_class.search('illing')).to eq([customer_1])
    end

    it 'matches email field starting in the query' do
      expect(described_class.search('example')).to eq([])
    end

    it 'matches username field starting in the query' do
      expect(described_class.search('zell')).to eq([])
    end

    it 'does not filter if nothing provided' do
      expect(described_class.search(nil)).to eq([customer_1, customer_2])
    end
  end

  describe '#email=' do
    it 'lowercases the value' do
      customer = build(:customer, email: 'USER@DOMAIN.COM')
      expect(customer.email).to eq('user@domain.com')
    end
  end

  describe '#high_priority?' do
    before do
      stub_const('Customer::HIGH_PRIORITY_MINIMUM', 3)
    end

    it 'returns false if Customer.value does not have the minumum value' do
      expect(build(:customer, priority: 0).high_priority?).to be(false)
    end

    it 'returns true if Customer.value has a minumum value' do
      expect(build(:customer, priority: 3).high_priority?).to be(true)
    end
  end

  describe '#human_phone' do
    it 'returns a human friendly version of the phone' do
      expect(create(:customer, phone: '1234567890').human_phone).to eq('123-456-7890')
    end

    it 'works if it is not present' do
      expect(create(:customer, phone: '').human_phone).to eq('')
    end

    it 'works if it is nil' do
      expect(create(:customer, phone: nil).human_phone).to eq(nil)
    end
  end

  describe '#label' do
    it 'returns a succinct label of customer' do
      expect(customer.label).to eq('Berneice Aufderhar (berneice_aufderhar1)')
    end
  end

  describe '#normal_priority?' do
    before do
      stub_const('Customer::PRIORITY_MINIMUM', 1)
    end

    it 'returns false if Customer.value does not have the minumum value' do
      expect(build(:customer, priority: 0).normal_priority?).to be(false)
    end

    it 'returns true if Customer.value has a minumum value' do
      expect(build(:customer, priority: 1).normal_priority?).to be(true)
    end
  end

  describe '#product' do
    it 'returns the association' do
      expect(customer.product).to eq(product)
    end
  end

  describe '#save' do
    it 'ensures uniqueness of username field' do
      username = 'cool_username'
      create(:customer, username: username)
      expect do
        create(:customer, username: username)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#username=' do
    it 'lowercases the value' do
      customer = build(:customer, username: 'USERNAME')
      expect(customer.username).to eq('username')
    end
  end

  describe '#validate' do
    describe 'email' do
      it 'is required (nil)' do
        expect(build(:customer, email: nil)).not_to be_valid
      end

      it 'is required (blank)' do
        expect(build(:customer, email: '')).not_to be_valid
      end
    end

    describe 'name' do
      it 'is required (nil)' do
        expect(build(:customer, name: nil)).not_to be_valid
      end

      it 'is required (blank)' do
        expect(build(:customer, name: '')).not_to be_valid
      end
    end

    describe 'phone' do
      it 'allows blank phone' do
        expect(build(:customer, phone: '').valid?).to be(true)
      end

      it 'allows nil phone' do
        expect(build(:customer, phone: nil).valid?).to be(true)
      end
    end

    describe 'priority' do
      it 'is required (nil)' do
        expect(build(:customer, priority: nil)).not_to be_valid
      end

      it 'is required (blank)' do
        expect(build(:customer, priority: '')).not_to be_valid
      end

      it 'must be a number' do
        expect(build(:customer, priority: 'a')).not_to be_valid
      end

      it 'must be a greater than 0' do
        expect(build(:customer, priority: -1)).not_to be_valid
      end
    end

    describe 'product' do
      it 'is required (nil)' do
        expect(build(:customer, product: nil)).not_to be_valid
      end
    end

    describe 'quota' do
      it 'is required (nil)' do
        expect(build(:customer, quota: nil)).not_to be_valid
      end

      it 'is required (blank)' do
        expect(build(:customer, quota: '')).not_to be_valid
      end

      it 'must be a number' do
        expect(build(:customer, quota: 'a')).not_to be_valid
      end

      it 'must be a greater than 0' do
        expect(build(:customer, quota: -1)).not_to be_valid
      end
    end

    describe 'username' do
      it 'is required (nil)' do
        expect(build(:customer, username: nil)).not_to be_valid
      end

      it 'is required (blank)' do
        expect(build(:customer, username: '')).not_to be_valid
      end

      it 'is unique within product scope' do
        username = 'cool_username'
        create(:customer, username: username)
        expect(build(:customer, username: username)).not_to be_valid
      end

      it 'allows same :username for different products' do
        username = 'el_user'
        create(:customer, username: username, product: product)
        expect(build(:customer, username: username, product: create(:product_ibackup))).to be_valid
      end
    end
  end

  describe '#more_than_one_open_order?' do
    let!(:customer) { create(:customer) }
    let!(:order_1) { create(:order_with_drive, customer: customer, completed_at: nil) }
    let!(:order_2) { create(:order_with_drive, customer: customer, completed_at: nil) }

    context 'when customer has more than one open orders' do
      it 'returns true' do
        expect(customer.more_than_one_open_order?).to be true
      end
    end

    context 'when customer has only one open order' do
      it 'returns false' do
        customer.orders.last.destroy
        expect(customer.more_than_one_open_order?).to be false
      end
    end

    context 'when customer has one open and one completed order' do
      it 'returns false' do
        order_1.update(completed_at: Time.current)
        expect(customer.more_than_one_open_order?).to be false
      end
    end

    context 'when customer has only completed orders' do
      it 'returns false' do
        order_1.update(completed_at: Time.current)
        order_2.update(completed_at: Time.current)
        expect(customer.more_than_one_open_order?).to be false
      end
    end

    context 'when customer has no orders' do
      it 'returns false' do
        customer.orders.delete_all
        expect(customer.more_than_one_open_order?).to be false
      end
    end
  end
end
