require 'rails_helper'

RSpec.describe OrderPolicy, type: :policy do
  let(:default_user) { create(:user) }
  let!(:order_upload) { create(:order_upload) }
  let!(:order_restore) { create(:order_restore) }
  let!(:order_idrive_one) { create(:order_idrive_one) }
  let!(:order_idrive_bmr) { create(:order_idrive_bmr) }
  let!(:order_idrive_bmr_upload) { create(:order_idrive_bmr_upload) }
  let!(:order_idrive_bmr_restore) { create(:order_idrive_bmr_restore) }
  let!(:order_idrive360_upload) { create(:order_idrive360_upload) }
  let!(:order_idrive360_restore) { create(:order_idrive360_restore) }
  let!(:order_ibackup_upload) { create(:order_ibackup_upload) }
  let!(:order_ibackup_restore) { create(:order_ibackup_restore) }

  context 'with no roles' do
    permissions :create?, :new?, :show?, :update?, :edit?, :bulk_update? do
      it 'denies access to idrive upload orders' do
        expect(described_class).not_to permit(default_user, order_upload)
      end

      it 'denies access to idrive restore orders' do
        expect(described_class).not_to permit(default_user, order_restore)
      end

      it 'denies access to idrive one orders' do
        expect(described_class).not_to permit(default_user, order_idrive_one)
      end

      it 'denies access to idrive bmr orders' do
        expect(described_class).not_to permit(default_user, order_idrive_bmr)
      end

      it 'denies access to idrive bmr upload orders' do
        expect(described_class).not_to permit(default_user, order_idrive_bmr_upload)
      end

      it 'denies access to idrive bmr restore orders' do
        expect(described_class).not_to permit(default_user, order_idrive_bmr_restore)
      end

      it 'denies access to idrive360 upload orders' do
        expect(described_class).not_to permit(default_user, order_idrive360_upload)
      end

      it 'denies access to idrive360 restore orders' do
        expect(described_class).not_to permit(default_user, order_idrive360_restore)
      end

      it 'denies access to ibackup upload orders' do
        expect(described_class).not_to permit(default_user, order_ibackup_upload)
      end

      it 'denies access to ibackup restore orders' do
        expect(described_class).not_to permit(default_user, order_ibackup_restore)
      end

      it 'denies access to bulk update' do
        expect(described_class).not_to permit(default_user, Order.all)
      end
    end
  end

  context 'with role `idrive_employee`' do
    let(:user) do
      default_user.roles << create(:role_idrive_employee)
      default_user
    end

    permissions :create?, :new?, :show?, :update?, :edit?, :bulk_update? do
      it 'allows access to idrive upload orders' do
        expect(described_class).to permit(user, order_upload)
      end

      it 'allows access to idrive restore orders' do
        expect(described_class).to permit(user, order_restore)
      end

      it 'allows access to idrive one orders' do
        expect(described_class).to permit(user, order_idrive_one)
      end

      it 'allows access to idrive bmr orders' do
        expect(described_class).to permit(user, order_idrive_bmr)
      end

      it 'allows access to idrive bmr upload orders' do
        expect(described_class).to permit(user, order_idrive_bmr_upload)
      end

      it 'allows access to idrive bmr restore orders' do
        expect(described_class).to permit(user, order_idrive_bmr_restore)
      end

      it 'allows access to idrive360 upload orders' do
        expect(described_class).to permit(user, order_idrive360_upload)
      end

      it 'allows access to idrive360 restore orders' do
        expect(described_class).to permit(user, order_idrive360_restore)
      end

      it 'allows access to ibackup upload orders' do
        expect(described_class).to permit(user, order_ibackup_upload)
      end

      it 'allows access to ibackup restore orders' do
        expect(described_class).to permit(user, order_ibackup_restore)
      end
    end
  end

  context 'with role `super_user`' do
    let(:user) do
      default_user.roles << create(:role_super_user)
      default_user
    end

    permissions :create?, :new?, :show?, :update?, :edit?, :bulk_update? do
      it 'allows access to idrive upload orders' do
        expect(described_class).to permit(user, order_upload)
      end

      it 'allows access to idrive restore orders' do
        expect(described_class).to permit(user, order_restore)
      end

      it 'allows access to idrive one orders' do
        expect(described_class).to permit(user, order_idrive_one)
      end

      it 'allows access to idrive bmr orders' do
        expect(described_class).to permit(user, order_idrive_bmr)
      end

      it 'allows access to idrive bmr upload orders' do
        expect(described_class).to permit(user, order_idrive_bmr_upload)
      end

      it 'allows access to idrive bmr restore orders' do
        expect(described_class).to permit(user, order_idrive_bmr_restore)
      end

      it 'allows access to idrive360 upload orders' do
        expect(described_class).to permit(user, order_idrive360_upload)
      end

      it 'allows access to idrive360 restore orders' do
        expect(described_class).to permit(user, order_idrive360_restore)
      end

      it 'allows access to ibackup upload orders' do
        expect(described_class).to permit(user, order_ibackup_upload)
      end

      it 'allows access to ibackup restore orders' do
        expect(described_class).to permit(user, order_ibackup_restore)
      end
    end
  end

  context 'with role `support_agent`' do
    let(:user) do
      default_user.roles << create(:role_support_agent)
      default_user
    end

    permissions :create?, :new?, :update?, :edit? do
      it 'denies access to idrive upload orders' do
        expect(described_class).not_to permit(user, order_upload)
      end

      it 'denies access to idrive restore orders' do
        expect(described_class).not_to permit(user, order_restore)
      end

      it 'denies access to idrive one orders' do
        expect(described_class).not_to permit(user, order_idrive_one)
      end

      it 'denies access to idrive bmr orders' do
        expect(described_class).not_to permit(user, order_idrive_bmr)
      end

      it 'denies access to idrive bmr upload orders' do
        expect(described_class).not_to permit(user, order_idrive_bmr_upload)
      end

      it 'denies access to idrive bmr restore orders' do
        expect(described_class).not_to permit(user, order_idrive_bmr_restore)
      end

      it 'denies access to idrive360 upload orders' do
        expect(described_class).not_to permit(user, order_idrive360_upload)
      end

      it 'denies access to idrive360 restore orders' do
        expect(described_class).not_to permit(user, order_idrive360_restore)
      end

      it 'denies access to ibackup upload orders' do
        expect(described_class).not_to permit(user, order_ibackup_upload)
      end

      it 'denies access to ibackup restore orders' do
        expect(described_class).not_to permit(user, order_ibackup_restore)
      end
    end

    permissions :show? do
      it 'allows access to idrive upload orders' do
        expect(described_class).to permit(user, order_upload)
      end

      it 'allows access to idrive restore orders' do
        expect(described_class).to permit(user, order_restore)
      end

      it 'allows access to idrive one orders' do
        expect(described_class).to permit(user, order_idrive_one)
      end

      it 'allows access to idrive bmr orders' do
        expect(described_class).to permit(user, order_idrive_bmr)
      end

      it 'allows access to idrive bmr upload orders' do
        expect(described_class).to permit(user, order_idrive_bmr_upload)
      end

      it 'allows access to idrive bmr restore orders' do
        expect(described_class).to permit(user, order_idrive_bmr_restore)
      end

      it 'allows access to idrive360 upload orders' do
        expect(described_class).to permit(user, order_idrive360_upload)
      end

      it 'allows access to idrive360 restore orders' do
        expect(described_class).to permit(user, order_idrive360_restore)
      end

      it 'allows access to ibackup upload orders' do
        expect(described_class).to permit(user, order_ibackup_upload)
      end

      it 'allows access to ibackup restore orders' do
        expect(described_class).to permit(user, order_ibackup_restore)
      end
    end
  end

  context 'with role `idrive_one_contractor`' do
    let(:user) do
      default_user.roles << create(:role_idrive_one_contractor)
      default_user
    end

    permissions :create?, :new? do
      it 'denies access' do
        expect(described_class).not_to permit(user, Order.new)
      end
    end

    permissions :show?, :update?, :edit? do
      it 'denies access to idrive upload orders' do
        expect(described_class).not_to permit(user, order_upload)
      end

      it 'denies access to idrive restore orders' do
        expect(described_class).not_to permit(user, order_restore)
      end

      it 'allows access to idrive one orders' do
        expect(described_class).to permit(user, order_idrive_one)
      end

      it 'denies access to idrive bmr orders' do
        expect(described_class).not_to permit(user, order_idrive_bmr)
      end

      it 'denies access to idrive bmr upload orders' do
        expect(described_class).not_to permit(user, order_idrive_bmr_upload)
      end

      it 'denies access to idrive bmr restore orders' do
        expect(described_class).not_to permit(user, order_idrive_bmr_restore)
      end

      it 'denies access to idrive360 upload orders' do
        expect(described_class).not_to permit(user, order_idrive360_upload)
      end

      it 'denies access to idrive360 restore orders' do
        expect(described_class).not_to permit(user, order_idrive360_restore)
      end

      it 'denies access to ibackup upload orders' do
        expect(described_class).not_to permit(user, order_ibackup_upload)
      end

      it 'denies access to ibackup restore orders' do
        expect(described_class).not_to permit(user, order_ibackup_restore)
      end
    end

    permissions :bulk_update? do
      it 'allows access to bulk update' do
        expect(described_class).to permit(user)
      end
    end
  end

  context 'with role `bmr_agent`' do
    let(:user) do
      default_user.roles << create(:role_bmr_agent)
      default_user
    end

    permissions :create?, :new? do
      it 'denies access' do
        expect(described_class).not_to permit(user, Order.new)
      end
    end

    permissions :show?, :update?, :edit? do
      it 'denies access to idrive upload orders' do
        expect(described_class).not_to permit(user, order_upload)
      end

      it 'denies access to idrive restore orders' do
        expect(described_class).not_to permit(user, order_restore)
      end

      it 'denies access to idrive one orders' do
        expect(described_class).not_to permit(user, order_idrive_one)
      end

      it 'allows access to idrive bmr orders' do
        expect(described_class).to permit(user, order_idrive_bmr)
      end

      it 'allows access to idrive bmr upload orders' do
        expect(described_class).to permit(user, order_idrive_bmr_upload)
      end

      it 'allows access to idrive bmr restore orders' do
        expect(described_class).to permit(user, order_idrive_bmr_restore)
      end

      it 'denies access to idrive360 upload orders' do
        expect(described_class).not_to permit(user, order_idrive360_upload)
      end

      it 'denies access to idrive360 restore orders' do
        expect(described_class).not_to permit(user, order_idrive360_restore)
      end

      it 'denies access to ibackup upload orders' do
        expect(described_class).not_to permit(user, order_ibackup_upload)
      end

      it 'denies access to ibackup restore orders' do
        expect(described_class).not_to permit(user, order_ibackup_restore)
      end
    end

    permissions :bulk_update? do
      it 'allows access to bulk update' do
        expect(described_class).to permit(user)
      end
    end
  end

  permissions '.scope' do
    let(:user) { default_user }
    let(:scope) { OrderQuery.resolve(nil) }
    let(:policy_scope) { described_class::Scope.new(user, scope).resolve }

    context 'with no roles' do
      it 'hides all orders' do
        expect(policy_scope).to eq([])
      end
    end

    context 'with the wrong roles' do
      it 'hides all orders' do
        user.roles << create(:role, key: :some_role, name: 'A role')
        expect(policy_scope).to eq([])
      end
    end

    context 'with role `idrive_employee`' do
      it 'shows all order types' do
        user.roles << create(:role_idrive_employee)
        expect(policy_scope).to eq(
          [
            order_ibackup_restore,
            order_ibackup_upload,
            order_idrive360_restore,
            order_idrive360_upload,
            order_idrive_bmr_restore,
            order_idrive_bmr_upload,
            order_idrive_bmr,
            order_idrive_one,
            order_restore,
            order_upload
          ]
        )
      end
    end

    context 'with role `super_user`' do
      it 'shows all order types' do
        user.roles << create(:role_super_user)
        expect(policy_scope).to eq(
          [
            order_ibackup_restore,
            order_ibackup_upload,
            order_idrive360_restore,
            order_idrive360_upload,
            order_idrive_bmr_restore,
            order_idrive_bmr_upload,
            order_idrive_bmr,
            order_idrive_one,
            order_restore,
            order_upload
          ]
        )
      end
    end

    context 'with role `support_agent`' do
      it 'shows all order types' do
        user.roles << create(:role_support_agent)
        expect(policy_scope).to eq(
          [
            order_ibackup_restore,
            order_ibackup_upload,
            order_idrive360_restore,
            order_idrive360_upload,
            order_idrive_bmr_restore,
            order_idrive_bmr_upload,
            order_idrive_bmr,
            order_idrive_one,
            order_restore,
            order_upload
          ]
        )
      end
    end

    context 'with role `role_idrive_one_contractor`' do
      it 'shows idrive one order types' do
        user.roles << create(:role_idrive_one_contractor)
        expect(policy_scope).to eq([order_idrive_one])
      end
    end

    context 'with role `bmr_agent`' do
      it 'shows idrive bmr order types' do
        user.roles << create(:role_bmr_agent)
        expect(policy_scope).to eq(
          [
            order_idrive_bmr_restore,
            order_idrive_bmr_upload,
            order_idrive_bmr
          ]
        )
      end
    end
  end
end
