require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:role_super_user) { create(:role_super_user) }

  context 'with no roles' do
    permissions :create?, :new? do
      it 'denies access if user does not have any roles' do
        expect(described_class).not_to permit(user, build(:user))
      end
    end

    permissions :index? do
      it 'is denied' do
        expect(described_class).not_to permit(user, User.all)
      end
    end

    permissions :edit?, :show?, :update? do
      it 'is denied' do
        expect(described_class).not_to permit(user, user2)
      end

      it 'is permitted only to itself' do
        expect(described_class).to permit(user, user)
      end
    end
  end

  context 'with role super_user' do
    before do
      user.roles << role_super_user
    end

    permissions :create?, :new? do
      it 'is permitted' do
        expect(described_class).to permit(user, build(:user))
      end
    end

    permissions :index? do
      it 'is permitted' do
        expect(described_class).to permit(user, User.all)
      end
    end

    permissions :show? do
      it 'is permitted' do
        expect(described_class).to permit(user, user2)
      end
    end

    permissions :edit?, :update? do
      it 'is denied' do
        expect(described_class).not_to permit(user, user2)
      end
    end
  end

  context 'with role idrive_employee' do
    before do
      user.roles << create(:role_idrive_employee)
    end

    permissions :create?, :new? do
      it 'is permitted' do
        expect(described_class).to permit(user, build(:user))
      end
    end

    permissions :index? do
      it 'is permitted' do
        expect(described_class).to permit(user, User.all)
      end
    end

    permissions :show? do
      it 'is permitted' do
        expect(described_class).to permit(user, user2)
      end
    end

    permissions :edit?, :update? do
      it 'is denied' do
        expect(described_class).not_to permit(user, user2)
      end
    end
  end

  describe '#permitted_attributes' do
    it 'defines a restricted set of attributes for create action' do
      expect(described_class.new(user, build(:user)).permitted_attributes).to eq(%i[email name])
    end

    it 'denies any attributes for update action if not the user' do
      expect(described_class.new(user, user2).permitted_attributes).to eq([])
    end

    it 'allows all attributes for update action for same user' do
      expect(described_class.new(user, user).permitted_attributes).to eq(
        %i[email name password password_confirmation]
      )
    end
  end
end
