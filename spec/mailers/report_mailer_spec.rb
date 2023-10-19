require 'rails_helper'

RSpec.describe ReportMailer, type: :mailer do
  let(:report) do
    query = <<~SQL
      SELECT `orders`.`id`
      FROM `orders`
      LEFT JOIN `customers` ON `orders`.`customer_id` = `customers`.`id`
      WHERE `customers`.`priority` > 1
      ORDER BY `orders`.`id` ASC
      LIMIT 10
    SQL
    build_stubbed(
      :report,
      name: 'Newest business orders',
      description: 'The newest orders from priority accounts',
      query: query,
      recipients: 'user1@idrive.com, user2@idrive.com',
      frequency: 'daily'
    )
  end

  describe '#report_results' do
    let(:mail) { described_class.report_results(report).deliver_now }

    it 'renders the subject' do
      expect(mail.subject).to eq('Express daily report: Newest business orders')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq(['user1@idrive.com', 'user2@idrive.com'])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['noreply@idrive.com'])
    end

    it 'renders the report name' do
      expect(mail.body.encoded).to match(report.name)
    end

    it 'renders the report description' do
      expect(mail.body.encoded).to match(report.description)
    end

    it 'has a table for holding the results' do
      expect(mail.body.encoded).to match('<table')
    end

    describe 'attachment' do
      let(:attachment) { mail.attachments[0] }

      it 'exists' do
        expect(attachment).to be_an_instance_of(Mail::Part)
      end

      it 'is a csv' do
        expect(attachment.content_type).to match('text/csv')
      end

      it 'is named for the report' do
        expect(attachment.filename).to eq('newest-business-orders.csv')
      end
    end
  end
end
