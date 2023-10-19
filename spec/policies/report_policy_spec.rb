require 'rails_helper'

RSpec.describe ReportPolicy, type: :policy do
  let(:report) { build_stubbed(:report) }
  let(:reports) { [report] }
  let(:user) { create(:user) }
  let(:role_reporting) { create(:role_reporting) }
  let(:role_super_user) { create(:role_super_user) }

  context 'with no roles' do
    permissions :create?, :new? do
      it 'denies access if user does not have any roles' do
        expect(described_class).not_to permit(user, build(:report))
      end
    end

    permissions :index? do
      it 'is denied' do
        expect(described_class).not_to permit(user, reports)
      end
    end

    permissions :destroy?, :edit?, :preview?, :run?, :show?, :update? do
      it 'is denied' do
        expect(described_class).not_to permit(user, report)
      end
    end
  end

  context 'with role reporting' do
    before do
      user.roles << role_reporting
    end

    permissions :create?, :new? do
      it 'is permitted' do
        expect(described_class).to permit(user, build(:report))
      end
    end

    permissions :index? do
      it 'is permitted' do
        expect(described_class).to permit(user, reports)
      end
    end

    permissions :destroy?, :edit?, :preview?, :run?, :show?, :update? do
      it 'is permitted' do
        expect(described_class).to permit(user, report)
      end
    end
  end

  context 'with role super_user' do
    before do
      user.roles << role_super_user
    end

    permissions :create?, :new? do
      it 'is permitted' do
        expect(described_class).to permit(user, build(:report))
      end
    end

    permissions :index? do
      it 'is permitted' do
        expect(described_class).to permit(user, reports)
      end
    end

    permissions :destroy?, :edit?, :preview?, :run?, :show?, :update? do
      it 'is permitted' do
        expect(described_class).to permit(user, report)
      end
    end
  end
end
