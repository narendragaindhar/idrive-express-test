begin
  r = Role.create!(key: 'role_manager', name: 'Role manager',
                   description: 'A role manager can manage and update roles for other users of the site')
  Rails.logger.info "Created new role: #{r.name}"
rescue ActiveRecord::RecordInvalid
  Rails.logger.info 'Record already exists: role manager'
end
