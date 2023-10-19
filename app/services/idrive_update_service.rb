class IDriveUpdateService < UpdateService
  def enabled?
    Rails.configuration.x.idrive_api.enabled
  end

  private

  def url
    Rails.configuration.x.idrive_api.update_url
  end

  def auth_token
    Rails.configuration.x.idrive_api.auth_token
  end
end
