class IDrive360UpdateService < UpdateService
  def enabled?
    Rails.configuration.x.idrive360_api.enabled
  end

  private

  def url
    Rails.configuration.x.idrive360_api.update_url
  end

  def auth_token
    Rails.configuration.x.idrive360_api.auth_token
  end
end
