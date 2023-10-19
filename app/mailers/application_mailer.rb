class ApplicationMailer < ActionMailer::Base
  IDRIVE = {
    from: 'IDrive <noreply@idrive.com>',
    reply_to: 'IDrive Support <support@idrive.com>'
  }.freeze
  IBACKUP = {
    from: 'IBackup <noreply@ibackup.com>',
    reply_to: 'IBackup Support <support@ibackup.com>'
  }.freeze

  EMAIL_ERRORS = [IOError, Net::SMTPAuthenticationError, Net::SMTPServerBusy,
                  Net::SMTPUnknownError, Net::SMTPFatalError,
                  Net::SMTPSyntaxError].freeze

  default IDRIVE
  helper :mail
  layout 'mailer'

  # return mailing defaults for a specific order type
  def self.defaults_for(order_type)
    if order_type.product.is? :ibackup
      IBACKUP
    else
      IDRIVE
    end
  end
end
