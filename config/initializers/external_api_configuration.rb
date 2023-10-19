module IDriveExpress
  class Application < Rails::Application
    # idrive
    raise 'Environmental variable not set: "IDRIVE_UPDATE_API_TOKEN"' if ENV['IDRIVE_UPDATE_API_TOKEN'].blank?

    config.x.idrive_api.auth_token = ENV['IDRIVE_UPDATE_API_TOKEN']
    raise 'Environmental variable not set: "IDRIVE_UPDATE_URL"' if ENV['IDRIVE_UPDATE_URL'].blank?

    config.x.idrive_api.update_url = ENV['IDRIVE_UPDATE_URL']
    config.x.idrive_api.enabled = ENV['IDRIVE_UPDATE_API_ENABLED'] == 'true'

    # ibackup
    raise 'Environmental variable not set: "IBACKUP_UPDATE_API_TOKEN"' if ENV['IBACKUP_UPDATE_API_TOKEN'].blank?

    config.x.ibackup_api.auth_token = ENV['IBACKUP_UPDATE_API_TOKEN']
    raise 'Environmental variable not set: "IBACKUP_UPDATE_URL"' if ENV['IBACKUP_UPDATE_URL'].blank?

    config.x.ibackup_api.update_url = ENV['IBACKUP_UPDATE_URL']
    config.x.ibackup_api.enabled = ENV['IBACKUP_UPDATE_API_ENABLED'] == 'true'

    # idrive360
    raise 'Environmental variable not set: "IDRIVE360_UPDATE_API_TOKEN"' if ENV['IDRIVE360_UPDATE_API_TOKEN'].blank?

    config.x.idrive360_api.auth_token = ENV['IDRIVE360_UPDATE_API_TOKEN']
    raise 'Environmental variable not set: "IDRIVE360_UPDATE_URL"' if ENV['IDRIVE360_UPDATE_URL'].blank?

    config.x.idrive360_api.update_url = ENV['IDRIVE360_UPDATE_URL']
    config.x.idrive360_api.enabled = ENV['IDRIVE360_UPDATE_API_ENABLED'] == 'true'
  end
end
