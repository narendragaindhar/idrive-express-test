# rubocop:disable Metrics/LineLength
# ibackup express

# correct existing order types
begin
  idrive_upload = OrderType.find_by!(key: 'upload')
  idrive_upload.key = 'idrive_upload'
  idrive_upload.name = 'Express Upload'
  idrive_upload.save!
  Rails.logger.info "Updated #{idrive_upload.full_name}"
rescue ActiveRecord::RecordNotFound
  Rails.logger.info 'IDrive Express Upload order type up-to-date'
end

begin
  idrive_restore = OrderType.find_by!(key: 'restore')
  idrive_restore.key = 'idrive_restore'
  idrive_restore.name = 'Express Restore'
  idrive_restore.save!
  Rails.logger.info "Updated #{idrive_restore.full_name}"
rescue ActiveRecord::RecordNotFound
  Rails.logger.info 'IDrive Express Restore order type up-to-date'
end

begin
  idrive_one = OrderType.find_by!(key: 'idrive_one', name: 'IDrive One')
  idrive_one.name = 'One'
  idrive_one.save!
  Rails.logger.info "Updated #{idrive_one.full_name}"
rescue ActiveRecord::RecordNotFound
  Rails.logger.info 'IDrive Express One order type up-to-date'
end

# new product
begin
  ibackup = Product.find_by!(name: 'IBackup')
rescue ActiveRecord::RecordNotFound
  ibackup = Product.create!(name: 'IBackup')
end

# add new express order types
begin
  ibackup_upload = OrderType.find_by!(key: 'ibackup_upload')
  Rails.logger.info "Order type already exists: ##{ibackup_upload.id} #{ibackup_upload.full_name}"
rescue ActiveRecord::RecordNotFound
  ibackup_upload = OrderType.create!(key: 'ibackup_upload', name: 'Express Upload', product: ibackup)
  Rails.logger.info "Order type created: #{ibackup_upload.full_name}"
end

begin
  ibackup_restore = OrderType.find_by!(key: 'ibackup_restore')
  Rails.logger.info "Order type already exists: ##{ibackup_restore.id} #{ibackup_restore.full_name}"
rescue ActiveRecord::RecordNotFound
  ibackup_restore = OrderType.create!(key: 'ibackup_restore', name: 'Express Restore', product: ibackup)
  Rails.logger.info "Order type created: #{ibackup_restore.full_name}"
end

# ibackup upload states
states_created = 0
[
  { key: 'ibackup_upload_order_created', percentage: 14, label: 'Order created', description: 'Your order has been received! We\'ll start working on it right away.', public_by_default: true, notify_by_default: true, is_drive_event: false },
  { percentage: 16, label: 'International shipping fee', description: "Thank you for your your interest in using the Express service. Before we process your order, since this is shipping internationally, we wanted to make sure you were aware of the additional shipping costs of the order. In your location, the expected cost for this is $XX.XX USD. Please be advised that this only covers the cost of shipping the drive to you, and not the cost of return shipping.\n\nThe charge for shipping would be applied to your IBackup account, on the same card on file. Please send an email to support@ibackup.com confirming you accept these charges, and we will process your request. If you decline, we will cancel your Express order, but your IBackup account will be unaffected. If you have any questions, please let us know by emailing us at support@ibackup.com. \n\nThanks for using IBackup!", public_by_default: true, notify_by_default: true, is_drive_event: false },
  { percentage: 16, label: 'On hold - pre shipped', description: 'An order placed on hold before it was shipped. For orders that may have been made in mistake, or to investigate any potential red flags.', public_by_default: false, notify_by_default: false, is_drive_event: false },
  { percentage: 18, label: 'Charged international shipping fee', description: 'User approved shipping fee. Charging on ticket xxx', public_by_default: true, notify_by_default: false },
  { percentage: 28, label: 'Shipping label generated', description: "USPS sent tracking number: XXXX\n\nUSPS return tracking number: XXXX", public_by_default: false, notify_by_default: false, is_drive_event: false },
  { percentage: 42, label: 'Drive shipped', description: 'Your drive has been shipped! Your USPS tracking number is XXXXX. Please allow 2-3 days for delivery.', public_by_default: true, notify_by_default: true, leaves_us: true },
  { percentage: 42, label: 'Claim filed', description: 'Notes for filing a claim for a drive lost by USPS.', public_by_default: false, notify_by_default: false },
  { key: 'ibackup_upload_order_drive_return_delayed', percentage: 49, label: 'Drive return delayed', description: 'It has been a while since your order has shipped. To avoid being charged for the drive, please ship it back to us as soon as possible.', public_by_default: true, notify_by_default: true, is_out_of_our_hands: true },
  { percentage: 49, label: 'Drive return delayed - final notice', description: 'It has been a while since your order has shipped. To avoid being charged for the drive, please ship it back to us as soon as possible.', public_by_default: true, notify_by_default: true, is_out_of_our_hands: true },
  { percentage: 52, label: 'Drive received in Calabasas', description: 'Drive received in Calabasas. Sending to datacenter XXXX.', public_by_default: false, notify_by_default: false, leaves_us: true },
  { percentage: 56, label: 'Drive received at datacenter', description: 'We have received your IBackup Express drive. Your data will be uploaded soon!', public_by_default: true, notify_by_default: true },
  { percentage: 56, label: 'Server full', description: 'No available USB ports in the server', public_by_default: false, notify_by_default: false },
  { percentage: 56, label: 'Incorrect account/server', description: 'Incorrect account/server', public_by_default: false, notify_by_default: false },
  { percentage: 56, label: 'Status update', description: "Drive in our possession.\n\nCan be used for internal or external communication between team or the customer to update the status of the order.", public_by_default: false, notify_by_default: false, is_drive_event: false },
  { percentage: 56, label: 'Status update', description: "Drive out of our possession.\n\nCan be used for internal or external communication between team or the customer to update the status of the order.", public_by_default: false, notify_by_default: false, is_out_of_our_hands: true, is_drive_event: false },
  { percentage: 56, label: 'Express upload delay', description: 'There is a problem with the Express Drive. We are currently working on resolving the issue.', public_by_default: true, notify_by_default: true },
  { percentage: 56, label: 'Drive not detected', description: 'Drive is unable to be seen/mounted by the OS.', public_by_default: false, notify_by_default: false, is_drive_event: false },
  { percentage: 56, label: 'Moving account', description: 'Moving account', public_by_default: false, notify_by_default: false },
  { percentage: 60, label: 'Waiting on upload', description: 'Waiting on upload', public_by_default: false, notify_by_default: false, is_drive_event: false },
  { percentage: 70, label: 'Drive mounted on server', description: 'Your drive has been attached to our servers. Your upload will start soon.', public_by_default: false, notify_by_default: false },
  { percentage: 70, label: 'Unable to charge replacement fee', description: 'We were not able to charge the replacement fee.', public_by_default: false, notify_by_default: false },
  { percentage: 84, label: 'Upload started', description: 'Your data upload has begun', public_by_default: true, notify_by_default: false },
  { percentage: 84, label: 'Upload still in progress', description: 'Your upload is still in progress', public_by_default: false, notify_by_default: false, is_drive_event: false },
  { percentage: 90, label: 'Charging replacement fee for drive', description: 'Charging user replacement fee for the hard drive.', public_by_default: false, notify_by_default: false },
  { key: 'ibackup_upload_order_upload_restarted', percentage: 91, label: 'Upload restarted', description: 'Your data upload is still ongoing.', public_by_default: false, notify_by_default: false },
  { key: 'ibackup_upload_order_completed', percentage: 100, label: 'Upload completed', description: "Your IBackup Express transfer is now complete!\n\nWe recommend you to verify the uploaded data in your account online and let us know if you find any discrepancies. You are also now ready to begin performing incremental backups from your computer and we encourage you to start an incremental backup at your next convenience.\n\nThank you for choosing IBackup and we hope that you are satisfied with our service. If you have any billing, sales or technical questions please refer to our website (www.ibackup.com) or call our Customer Support team at 866-748-0555, 6AM - 6PM PST, Monday - Friday.\n\nWe always appreciate feedback and encourage you to leave your thoughts and suggestions via our online feedback form: https://www.idrive.com/support.htm\n\nThanks again!", public_by_default: true, notify_by_default: true },
  { key: 'ibackup_upload_order_drive_never_returned', percentage: 100, label: 'Drive never returned', description: 'You have been charged due to failure to return your IBackup Express drive back to us.', public_by_default: true, notify_by_default: true },
  { percentage: 100, label: 'Order cancelled', description: 'Your order has been cancelled.', public_by_default: true, notify_by_default: true, is_drive_event: false },
  { percentage: 100, label: 'Unable to upload', description: 'Use this for when a customer sends a drive back raw, empty, or with a note not to use the data on the drive.', public_by_default: false, notify_by_default: false },
  { percentage: 100, label: 'Replacement charge successful', description: 'The charge for the replacement fee went through successfully. Notifying user.', public_by_default: false, notify_by_default: false }
].each do |state_attrs|
  state = State.find_by!(order_type: ibackup_upload, **state_attrs)
  Rails.logger.info "State already exists: ##{state.id} #{state.label}"
rescue ActiveRecord::RecordNotFound
  state = State.create!(order_type: ibackup_upload, **state_attrs)
  Rails.logger.info "State created: #{state.label}"
  states_created += 1
end
Rails.logger.info "States created for #{ibackup_upload.full_name}: #{states_created}"

# ibackup restore states
states_created = 0
[
  { key: 'ibackup_restore_order_created', percentage: 14, label: 'Order created', description: 'Your order has been received! We\'ll start working on it right away.', public_by_default: true, notify_by_default: true, is_drive_event: false },
  { percentage: 16, label: 'No drives available', description: 'No drives are available at this datacenter.', public_by_default: false, notify_by_default: false, is_drive_event: false },
  { percentage: 16, label: 'Notify datacenter', description: 'Please begin processing this order', public_by_default: false, notify_by_default: false },
  { percentage: 25, label: 'Status update', description: 'Pre shipping status update. Can be used for internal notes or communicating with the customer.', public_by_default: false, notify_by_default: false },
  { percentage: 28, label: 'Drive mounted on server', description: 'Your drive has been attached to our servers, and your restore will start shortly.', public_by_default: false, notify_by_default: false },
  { percentage: 28, label: 'Drive not detected', description: 'Drive is unable to be seen/mounted by the OS.', public_by_default: false, notify_by_default: false, is_drive_event: false },
  { percentage: 28, label: 'Incorrect account/server', description: 'Incorrect account/server', public_by_default: false, notify_by_default: false },
  { percentage: 28, label: 'Status update', description: 'Post shipping status update. Can be used for internal notes or communicating with the customer.', public_by_default: false, notify_by_default: false },
  { percentage: 42, label: 'Restore started', description: 'Your IBackup Express data restore has begun!', public_by_default: true, notify_by_default: true },
  { percentage: 44, label: 'Restore still in progress', description: 'Your restore is still in progress', public_by_default: false, notify_by_default: false, is_drive_event: false },
  { percentage: 49, label: 'Restore restarted', description: 'Your data restore is still ongoing.', public_by_default: false, notify_by_default: false, is_drive_event: false },
  { percentage: 56, label: 'Data download complete', description: 'A copy of your data has finished downloading from our servers. We\'ll be shipping your drive to you soon.', public_by_default: true, notify_by_default: true },
  { percentage: 63, label: 'International shipping fee', description: "Thank you for your your interest in using the Express service. Before we process your order, since this is shipping internationally, we wanted to make sure you were aware of the additional shipping costs of the order. In your location, the expected cost for this is $XX.XX USD. Please be advised that this only covers the cost of shipping the drive to you, and not the cost of return shipping.\n\nThe charge for shipping would be applied to your IBackup account, on the same card on file. Please send an email to support@ibackup.com confirming you accept these charges, and we will process your request. If you decline, we will cancel your Express order, but your IBackup account will be unaffected. If you have any questions, please let us know by emailing us at support@ibackup.com.\n\nThanks for using IBackup!", public_by_default: true, notify_by_default: true, is_drive_event: false },
  { percentage: 70, label: 'Shipping label generated', description: "USPS sent tracking number: XXXX\n\nUSPS return tracking number: XXXX", public_by_default: false, notify_by_default: false, is_drive_event: false },
  { percentage: 84, label: 'Drive shipped', description: 'A drive containing a copy of your data has been shipped to you! Your USPS tracking number is XXXXX. Please allow 2-3 days for delivery.', public_by_default: true, notify_by_default: true, leaves_us: true },
  { percentage: 91, label: 'Drive return delayed', description: 'It has been a while since your order was shipped. To avoid being charged for failing to return the drive, please ship it back to us as soon as possible.', public_by_default: true, notify_by_default: true, is_out_of_our_hands: true },
  { key: 'ibackup_restore_order_completed', percentage: 100, label: 'Restore completed', description: 'We have received your IBackup Express drive back at our offices. This completes your order. Thank you for using IBackup Express!', public_by_default: true, notify_by_default: true },
  { key: 'ibackup_restore_order_drive_never_returned', percentage: 100, label: 'Drive never returned', description: 'You have been charged for failing to return your IBackup Express drive back to us.', public_by_default: true, notify_by_default: true },
  { key: 'ibackup_restore_order_cancelled', percentage: 100, label: 'Order cancelled', description: 'Your order has been cancelled.', public_by_default: true, notify_by_default: true, is_drive_event: false }
].each do |state_attrs|
  state = State.find_by!(order_type: ibackup_restore, **state_attrs)
  Rails.logger.info "State already exists: ##{state.id} #{state.label}"
rescue ActiveRecord::RecordNotFound
  state = State.create!(order_type: ibackup_restore, **state_attrs)
  Rails.logger.info "State created: #{state.label}"
  states_created += 1
end
Rails.logger.info "States created for #{ibackup_restore.full_name}: #{states_created}"
# rubocop:enable Metrics/LineLength
