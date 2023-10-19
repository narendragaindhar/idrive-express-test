class IBackupUpdateService < UpdateService
  def enabled?
    Rails.configuration.x.ibackup_api.enabled
  end

  private

  def url
    Rails.configuration.x.ibackup_api.update_url
  end

  def auth_token
    Rails.configuration.x.ibackup_api.auth_token
  end
end
