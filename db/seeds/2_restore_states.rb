# restore states

begin
  order_type = OrderType
rescue NameError
  order_type = ExpressKind # old model name
end

begin
  restore = order_type.find_by! key: 'restore'
rescue ActiveRecord::RecordNotFound
  restore = order_type.create!(key: 'restore', name: 'IDrive Express Restore')
end

# rubocop:disable Metrics/LineLength
State.create!(order_type: restore, percentage: 14, key: 'restore_order_created', is_drive_event: false, label: 'Order created', description: 'Your IDrive Express restore order has been received', public_by_default: true, notify_by_default: true)
State.create!(order_type: restore, percentage: 16, is_drive_event: false, label: 'No drive available', description: 'No drives are available at this datacenter.', public_by_default: false, notify_by_default: false)
State.create!(order_type: restore, percentage: 28, is_drive_event: true, label: 'Drive mounted on server', description: 'Your drive has been attached to our servers. Your restore will start shortly.', public_by_default: false, notify_by_default: false)
State.create!(order_type: restore, percentage: 42, is_drive_event: true, label: 'Restore started', description: 'Your data restore has begun.', public_by_default: true, notify_by_default: true)
State.create!(order_type: restore, percentage: 49, is_drive_event: false, label: 'Restore restarted', description: 'Your data restore is still ongoing.', public_by_default: false, notify_by_default: false)
State.create!(order_type: restore, percentage: 56, is_drive_event: true, label: 'Data download completed', description: 'A copy of your data has finished downloading off our servers. Your drive will be shipped to you soon.', public_by_default: true,  notify_by_default: true)
State.create!(order_type: restore, percentage: 63, is_drive_event: false, label: 'International shipping fee', description: "Thank you for your your interest in using the Express Service. Before we process your order, since this is shipping internationally, we wanted to make sure you were aware of the additional shipping costs of the order. In your location, the expected cost for this is $XX.XX USD.\n\nThe charge for shipping would be applied to your IDrive Account, on the same card on file. Please reply confirming you accept these charges, and we will process your request. If you decline, we will cancel your Express order, but your Online Backup account will be unaffected. If you have any questions, please let us know.", public_by_default: true, notify_by_default: true)
State.create!(order_type: restore, percentage: 70, is_drive_event: false, label: 'Shipping label generated', description: "USPS sent tracking number: XXXX\n\nUSPS return tracking number: XXXX", public_by_default: false, notify_by_default: false)
State.create!(order_type: restore, percentage: 84, is_drive_event: true, label: 'Drive shipped', description: 'Your drive with a copy of your data has been shipped! Your tracking number is XXXXX. Please allow 2-3 days for delivery.', public_by_default: true, notify_by_default: true)
State.create!(order_type: restore, percentage: 91, is_drive_event: true, label: 'Drive return delayed', description: 'It has been a while since your order has shipped. To avoid being charged for the drive, please ship it back to us as soon as possible.', public_by_default: true, notify_by_default: true)
State.create!(order_type: restore, percentage: 100, key: 'restore_order_completed', is_drive_event: true, label: 'Restore completed', description: 'We have received your IDrive Express drive back at our offices. This completes your order. Thank you for using IDrive Express!', public_by_default: true, notify_by_default: true)
State.create!(order_type: restore, percentage: 100, key: 'restore_order_drive_never_returned', is_drive_event: true, label: 'Drive never returned', description: 'You have been charged due to failure to return your IDrive Express drive back to us.', public_by_default: true, notify_by_default: true)
State.create!(order_type: restore, percentage: 100, key: 'restore_order_cancelled', is_drive_event: false, label: 'Order cancelled', description: 'Your order has been cancelled', public_by_default: true, notify_by_default: true)
# rubocop:enable Metrics/LineLength
