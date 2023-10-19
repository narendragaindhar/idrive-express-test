# rubocop:disable Metrics/LineLength
# idrive one

# order type
begin
  idrive_one = OrderType.find_by!(key: 'idrive_one')
  Rails.logger.info "Order type already exists: ##{idrive_one.id} #{idrive_one.name}"
rescue ActiveRecord::RecordNotFound
  idrive_one = OrderType.create!(key: 'idrive_one', name: 'IDrive One')
  Rails.logger.info "Order type created: #{idrive_one.name}"
end

# states
states_created = 0
[
  { order_type: idrive_one, percentage: 20, key: 'idrive_one_order_created', label: 'Order created', description: 'We have received your order and have started processing it. It will ship soon!', is_drive_event: false, public_by_default: true, notify_by_default: true },
  { order_type: idrive_one, percentage: 40, label: 'Account verification OK', description: 'Account is paid and in good standing. No red flags found. OK to ship.', is_drive_event: false, public_by_default: false, notify_by_default: false },
  { order_type: idrive_one, percentage: 40, label: 'Account verification failed', description: 'The order will not be shipped because the user\'s account has failed verification.', is_drive_event: false, public_by_default: false, notify_by_default: false },
  { order_type: idrive_one, percentage: 60, label: 'Drive assembled and formatted', description: 'Your IDrive One has been assembled and formatted for use.', is_drive_event: false, public_by_default: false, notify_by_default: false },
  { order_type: idrive_one, percentage: 80, label: 'Shipping label generated', description: 'USPS tracking number: XXXX', is_drive_event: false, public_by_default: false, notify_by_default: false },
  { order_type: idrive_one, percentage: 100, key: 'idrive_one_order_shipped', label: 'Order shipped', description: 'Your IDrive One has been shipped and your order is complete! Your tracking number is XXXXX. Please allow 2-3 days for delivery.', is_drive_event: true, public_by_default: true, notify_by_default: true },
  { order_type: idrive_one, percentage: 100, key: 'idrive_one_order_cancelled', label: 'Order cancelled', description: 'Your IDrive One order has been cancelled.', is_drive_event: false, public_by_default: true, notify_by_default: true }
].each do |state_attrs|
  state = State.find_by!(state_attrs)
  Rails.logger.info "State already exists: ##{state.id} #{state.label}"
rescue ActiveRecord::RecordNotFound
  state = State.create!(state_attrs)
  Rails.logger.info "State created: #{state.label}"
  states_created += 1
end
Rails.logger.info "States created for #{idrive_one.name}: #{states_created}"

# role
begin
  role = Role.find_by!(key: 'idrive_one_contractor')
  Rails.logger.info "Role already exists: ##{role.id} #{role.name}"
rescue ActiveRecord::RecordNotFound
  role = Role.create!(key: 'idrive_one_contractor', name: 'IDrive One contractor', description: 'An IDrive One contractor helps in building and fulfilling IDrive One orders')
  Rails.logger.info "Role created: #{role.name}"
end
# rubocop:enable Metrics/LineLength
