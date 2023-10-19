require 'rails_helper'

RSpec.describe User do
  let(:user) { create(:user, name: 'Adam Adamson') }

  describe '.all_by_name' do
    let(:user_b) { create(:user, name: 'Billy Borstein') }
    let(:user_c) { create(:user, name: 'Cody Collins') }
    let(:user_d) { create(:user, name: 'Dennis Denton') }
    let(:user_e) { create(:user, name: 'Evan Evanston') }
    let!(:users_excluding) { [user_b, user_c, user_e] }
    let!(:users) { [user, user_b, user_c, user_d, user_e] }

    it 'returns a collection of all users sorted by name' do
      expect(described_class.all_by_name).to match_array(users)
    end

    it 'excludes the ones passed in' do
      expect(described_class.all_by_name(user, user_d)).to match_array(users_excluding)
    end
  end

  describe '.roles' do
    it 'starts empty' do
      expect(user.roles).to be_empty
    end

    it 'can add new roles' do
      user.roles << create(:role_idrive_employee)
      expect(user.roles.size).to be 1
    end

    it 'raises an error for duplicate roles' do
      role = create(:role_idrive_employee)
      user.roles << role
      expect do
        user.roles << role
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe '#role?' do
    it 'returns false if the user does not have the role' do
      expect(user.role?(:cool_role)).to eq(false)
    end

    it 'returns true if the user does have the role' do
      user.roles << create(:role, key: 'my_role')
      expect(user.role?(:my_role)).to eq(true)
    end

    it 'returns true if the user has at lease one role' do
      user.roles << create(:role, key: 'my_role')
      expect(user.role?(:unrelated_role, :another_role, :my_role)).to eq(true)
    end
  end

  describe '#validate' do
    describe 'email' do
      it 'is required (nil)' do
        expect(build(:user, email: nil)).not_to be_valid
      end

      it 'is required (blank)' do
        expect(build(:user, email: '')).not_to be_valid
      end

      it 'looks like an email' do
        expect(build(:user, email: 'username')).not_to be_valid
      end

      it 'is <= 255 characters' do
        email = "#{'a' * 245}@domain.com"
        expect(build(:user, email: email)).not_to be_valid
      end

      it 'is unique' do
        create(:user, email: 'user@domain.com')
        expect(build(:user, email: 'user@domain.com')).not_to be_valid
      end
    end

    describe 'name' do
      it 'is required (nil)' do
        expect(build(:user, name: nil)).not_to be_valid
      end

      it 'is required (blank)' do
        expect(build(:user, name: '')).not_to be_valid
      end

      it 'is <= 255 characters' do
        name = 'a' * 256
        expect(build(:user, name: name)).not_to be_valid
      end
    end

    describe 'password' do
      context 'with a new user' do
        it 'is required (nil)' do
          expect(build(:user, password: nil)).not_to be_valid
        end

        it 'is required (blank)' do
          expect(build(:user, password: '')).not_to be_valid
        end
      end

      context 'with an existing user' do
        it 'requires confirmation' do
          user = build_stubbed(:user)
          user.assign_attributes(password: 'mypass', password_confirmation: '')
          expect(user).not_to be_valid
        end

        it 'is not required if it does not change' do
          user = build_stubbed(:user)
          user.assign_attributes(password: '', password_confirmation: '')
          expect(user).to be_valid
        end
      end
    end
  end
end
