require 'rails_helper'

RSpec.describe ReportingJob, type: :job do
  let(:report) do
    create(:report, frequency: 'daily', recipients: 'user1@idrive.com')
  end

  it 'can be queued with a frequency' do
    expect do
      described_class.perform_later('daily')
    end.to have_enqueued_job.with('daily')
  end

  it 'can be queued with a report' do
    expect do
      described_class.perform_later(report)
    end.to have_enqueued_job.with(report)
  end

  describe '#perform' do
    let(:mailer) { instance_double('Mailer', deliver_now: true) }

    context 'with a frequency' do
      before do
        report
        create(:report, frequency: 'daily', recipients: 'user2@idrive.com, user3@idrive.com')
        create(:report, frequency: 'daily')
        create(:report, frequency: 'weekly')
      end

      it 'emails all the reports matching the frequency' do
        expect(ReportMailer).to receive(:report_results).twice.and_return(mailer)
        described_class.perform_now('daily')
      end
    end

    context 'with a report' do
      it 'emails it' do
        expect(ReportMailer).to receive(:report_results).with(report).and_return(mailer)
        described_class.perform_now(report)
      end
    end
  end
end
