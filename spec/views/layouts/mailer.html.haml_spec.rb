require 'rails_helper'

RSpec.describe 'layouts/mailer.html.haml', type: :view do
  helper MailHelper

  let(:order) { create(:order_upload) }

  before do
    assign(:order, order)
    render
  end

  it 'has a header image' do
    expect(rendered).to have_tag('img[src*="/assets/email/idrive/header"]')
  end

  it 'signs off' do
    expect(rendered).to have_tag('p', text: /Thanks,.+The IDrive Team/im)
  end

  it 'tells user to email support' do
    expect(rendered).to have_tag('p', text: /Contact us at/) do
      with_tag('a', text: 'support@idrive.com')
    end
  end

  it 'has the company name in the footer' do
    expect(rendered).to have_tag('a', text: 'IDrive Inc.')
  end

  context 'when order is not defined' do
    let(:order) { nil }

    it 'defaults to idrive header image' do
      expect(rendered).to have_tag('img[src*="/assets/email/idrive/header"]')
    end

    it 'defaults to idrive sign off' do
      expect(rendered).to have_tag('p', text: /Thanks,.+The IDrive Team/im)
    end

    it 'tells user to email support' do
      expect(rendered).to have_tag('p', text: /Contact us at/) do
        with_tag('a', text: 'support@idrive.com')
      end
    end

    it 'has the company name in the footer' do
      expect(rendered).to have_tag('a', text: 'IDrive Inc.')
    end
  end

  context 'with an idrive restore order' do
    let(:order) { create(:order_restore) }

    it 'has a header image' do
      expect(rendered).to have_tag('img[src*="/assets/email/idrive/header"]')
    end

    it 'signs off' do
      expect(rendered).to have_tag('p', text: /Thanks,.+The IDrive Team/im)
    end

    it 'tells user to email support' do
      expect(rendered).to have_tag('p', text: /Contact us at/) do
        with_tag('a', text: 'support@idrive.com')
      end
    end

    it 'has the company name in the footer' do
      expect(rendered).to have_tag('a', text: 'IDrive Inc.')
    end
  end

  context 'with an idrive one order' do
    let(:order) { create(:order_idrive_one) }

    it 'has a header image' do
      expect(rendered).to have_tag('img[src*="/assets/email/idrive/header"]')
    end

    it 'signs off' do
      expect(rendered).to have_tag('p', text: /Thanks,.+The IDrive Team/im)
    end

    it 'tells user to email support' do
      expect(rendered).to have_tag('p', text: /Contact us at/) do
        with_tag('a', text: 'support@idrive.com')
      end
    end

    it 'has the company name in the footer' do
      expect(rendered).to have_tag('a', text: 'IDrive Inc.')
    end
  end

  context 'with an ibackup upload order' do
    let(:order) { create(:order_ibackup_upload) }

    it 'has a header image' do
      expect(rendered).to have_tag('img[src*="/assets/email/ibackup/header"]')
    end

    it 'signs off' do
      expect(rendered).to have_tag('p', text: /Thanks,.+The IBackup Team/im)
    end

    it 'tells user to email support' do
      expect(rendered).to have_tag('p', text: /Contact us at/) do
        with_tag('a', text: 'support@ibackup.com')
      end
    end

    it 'has the company name in the footer' do
      expect(rendered).to have_tag('a', text: 'Pro Softnet Corporation')
    end
  end

  context 'with an ibackup restore order' do
    let(:order) { create(:order_ibackup_restore) }

    it 'has a header image' do
      expect(rendered).to have_tag('img[src*="/assets/email/ibackup/header"]')
    end

    it 'signs off' do
      expect(rendered).to have_tag('p', text: /Thanks,.+The IBackup Team/im)
    end

    it 'tells user to email support' do
      expect(rendered).to have_tag('p', text: /Contact us at/) do
        with_tag('a', text: 'support@ibackup.com')
      end
    end

    it 'has the company name in the footer' do
      expect(rendered).to have_tag('a', text: 'Pro Softnet Corporation')
    end
  end
end
