def update_state(label, limit, leaves_us: false, is_out_of_our_hands: false)
  count = 0
  State.where('`label` LIKE ?', "%#{label}%").limit(limit).each do |state|
    Rails.logger.info "#{state.order_type.name} state should leave us: \"#{state.label}\""
    state.update! leaves_us: leaves_us, is_out_of_our_hands: is_out_of_our_hands
    count += 1
  end
  count
end

count = 0
count += update_state('drive shipped', 2, leaves_us: true)
count += update_state('received in calabasas', 1, leaves_us: true)
count += update_state('return delayed', 3, is_out_of_our_hands: true)

Rails.logger.info "Records updated: #{count}"
