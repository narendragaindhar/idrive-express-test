begin
  r = Role.create!(key: 'bmr_agent', name: 'Bmr agent',
                   description: 'A BMR agent can manage and update IDrive BMR orders')
  Rails.logger.info "Created new role: #{r.name}"
rescue ActiveRecord::RecordInvalid
  Rails.logger.info 'Record already exists: role BMR agent'
end
