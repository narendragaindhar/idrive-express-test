idrive_one = OrderType.find_by!(key: 'idrive_one')

[
  {
    label: 'Status update',
    description: 'Additional information during the processing of the order',
    key: 'idrive_one_status_update',
    percentage: 50,
    public_by_default: false,
    notify_by_default: false
  },
  {
    label: 'Shipping label generated',
    description: 'USPS tracking number: XXXX',
    key: 'idrive_one_shipping_label_generated',
    percentage: 80,
    public_by_default: false,
    notify_by_default: false
  }
].each do |attrs|
  state = State.find_by(key: attrs[:key])
  if state
    Rails.logger.info "Found state ##{state.id}: \"#{state.label}\" key=#{state.key}"
  else
    sql = <<-SQL
        `order_type_id` = ? AND
        `label` LIKE ?
    SQL
    state = State.where(sql, idrive_one.id, "%#{attrs[:label]}%").first!
    state.update!(key: attrs[:key])
    Rails.logger.info "Updated state ##{state.id}: \"#{state.label}\" key=#{state.key}"
  end
rescue ActiveRecord::RecordNotFound
  state = State.create!(order_type: idrive_one, **attrs)
  Rails.logger.info "Created state ##{state.id}: \"#{state.label}\" key=#{state.key}"
end
