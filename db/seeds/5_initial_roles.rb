# we only support 2 roles right now
begin
  Role.create!(key: 'super_user', name: 'Super User',
               description: 'The super user has permission to control all aspects of the site')
rescue ActiveRecord::RecordInvalid
  # we good
end

idrive_employee = Role.find_or_create_by!(key: 'idrive_employee', name: 'IDrive Employee',
                                          description: 'An employee of IDrive can do all normal tasks on the site')

# everyone gets to be an employee!
User.where(
  <<~SQL
       `email` LIKE "%idrive%"
    OR `email` LIKE "%softnet%"
    OR `email` LIKE "%prosoft%"
    OR `email` LIKE "%streamnet%"
  SQL
).find_each do |user|
  user.roles << idrive_employee
rescue ActiveRecord::RecordNotUnique
  # we good
end
