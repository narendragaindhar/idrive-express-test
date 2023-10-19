require 'rails_helper'

RSpec.describe 'layouts/mailer.text.haml', type: :view do
  let(:order) { create(:order_upload) }

  before do
    assign(:order, order)
    render
  end

  it 'signs off' do
    expect(rendered).to match(/Thanks,\nThe IDrive Team/im)
  end

  it 'tells user to email support' do
    expect(rendered).to match(/Contact us at support@idrive.com/)
  end

  context 'when order is not defined' do
    let(:order) { nil }

    it 'signs off' do
      expect(rendered).to match(/Thanks,\nThe IDrive Team/im)
    end

    it 'tells user to email support' do
      expect(rendered).to match(/Contact us at support@idrive.com/)
    end
  end

  context 'with an idrive restore order' do
    let(:order) { create(:order_restore) }

    it 'signs off' do
      expect(rendered).to match(/Thanks,\nThe IDrive Team/im)
    end

    it 'tells user to email support' do
      expect(rendered).to match(/Contact us at support@idrive.com/)
    end
  end

  context 'with an idrive one order' do
    let(:order) { create(:order_idrive_one) }

    it 'signs off' do
      expect(rendered).to match(/Thanks,\nThe IDrive Team/im)
    end

    it 'tells user to email support' do
      expect(rendered).to match(/Contact us at support@idrive.com/)
    end
  end

  context 'with an ibackup upload order' do
    let(:order) { create(:order_ibackup_upload) }

    it 'signs off' do
      expect(rendered).to match(/Thanks,\nThe IBackup Team/im)
    end

    it 'tells user to email support' do
      expect(rendered).to match(/Contact us at support@ibackup.com/)
    end
  end

  context 'with an ibackup restore order' do
    let(:order) { create(:order_ibackup_restore) }

    it 'signs off' do
      expect(rendered).to match(/Thanks,\nThe IBackup Team/im)
    end

    it 'tells user to email support' do
      expect(rendered).to match(/Contact us at support@ibackup.com/)
    end
  end
end
