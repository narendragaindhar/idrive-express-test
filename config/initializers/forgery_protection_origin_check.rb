# Enable origin-checking CSRF mitigation. Rails < 5.X had false.
Rails.application.config.action_controller.forgery_protection_origin_check = true
