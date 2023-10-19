FactoryBot.define do
  factory :state, aliases: [:state_upload_started] do
    order_type do
      OrderType.find_by(key: :idrive_upload) || association(:order_type_idrive_upload)
    end
    percentage { 84 }
    label { 'Upload started' }
    description { 'Your data upload has begun.' }
    active { true }
    public_by_default { false }
    notify_by_default { false }
    is_drive_event { false }
    is_out_of_our_hands { false }
    leaves_us { false }

    factory :state_initial do
      percentage { 14 }
      label { 'Order created' }
      description { 'Your IDrive Express order has been received.' }
      key { 'upload_order_created' }
      public_by_default { true }
      notify_by_default { true }
    end

    factory :state_international_shipping_fee do
      percentage { 16 }
      label { 'International shipping fee' }
      description do
        'Thank you for your your interest in using the Express '\
                  'Service. Before we process your order, since this is '\
                  'shipping internationally, we wanted to make sure you were '\
                  'aware of the additional shipping costs of the order. In '\
                  'your location, the expected cost for this is $XX.XX USD. '\
                  'The charge for shipping would be applied to your IDrive '\
                  'Account, on the same card on file. Please reply confirming '\
                  'you accept these charges, and we will process your '\
                  'request. If you decline, we will cancel your Express '\
                  'order, but your Online Backup account will be unaffected. '\
                  'If you have any questions, please let us know. Thanks for using IDrive!'
      end
    end

    factory :state_on_hold_pre_shipped do
      percentage { 20 }
      label { 'On hold - pre shipped' }
      description do
        "One or more items require resolution before the order can be shipped\n\nThey are XXX, XXX and XXX."
      end
    end

    factory :state_shipping_label_generated do
      percentage { 28 }
      label { 'Shipping label generated' }
      description { "USPS sent tracking number: \n\nUSPS return tracking number: " }
    end

    factory :state_drive_shipped do
      percentage { 42 }
      label { 'Drive shipped' }
      key { 'upload_order_shipped' }
      description { 'Your drive has been shipped! Your tracking number is XXXXX. Please allow 2-3 days for delivery.' }
      leaves_us { true }
    end

    factory :state_drive_return_delayed do
      percentage { 49 }
      label { 'Drive return delayed' }
      key { 'upload_order_drive_return_delayed' }
      description do
        'It has been a while since your order has shipped. To '\
                  'avoid being charged for the drive, please ship it back '\
                  'to us as soon as possible.'
      end
      is_out_of_our_hands { true }
    end

    factory :state_drive_arrived_at_datacenter do
      percentage { 56 }
      label { 'Drive received at datacenter' }
      description { 'We have received your IDrive Express drive. Your data will be uploaded soon!' }
    end

    factory :state_upload_completed do
      percentage { 100 }
      label { 'Upload completed' }
      description { 'Your IDrive Express order is complete. You can now access your data in your account!' }
      key { 'upload_order_completed' }
      is_drive_event { true }
    end

    factory :state_upload_cancelled do
      percentage { 100 }
      label { 'Order cancelled' }
      description { 'Your order has been cancelled.' }
    end

    factory :state_restore, aliases: [:state_restore_restore_started] do
      order_type do
        OrderType.find_by(key: :idrive_restore) || association(:order_type_idrive_restore)
      end
      percentage { 42 }
      label { 'Restore started' }
      description { 'Your data restore has begun.' }

      factory :state_restore_initial do
        percentage { 14 }
        label { 'Order created' }
        description { 'Your IDrive Express order has been received' }
        key { 'restore_order_created' }
        public_by_default { true }
        notify_by_default { true }
      end

      factory :state_restore_international_shipping_fee do
        percentage { 63 }
        label { 'International shipping fee' }
        description do
          'Thank you for your your interest in using the Express '\
                    'Service. Before we process your order, since this is '\
                    'shipping internationally, we wanted to make sure you '\
                    'were aware of the additional shipping costs of the '\
                    'order. In your location, the expected cost for this '\
                    "is $XX.XX USD.\n\nThe charge for shipping would be "\
                    'applied to your IDrive Account, on the same card on '\
                    'file. Please reply confirming you accept these charges, '\
                    'and we will process your request. If you decline, we '\
                    'will cancel your Express order, but your Online Backup '\
                    'account will be unaffected. If you have any questions, '\
                    'please let us know.'
        end
      end

      factory :state_restore_order_shipped do
        percentage { 84 }
        label { 'Drive shipped' }
        key { 'restore_order_shipped' }
        description do
          'A drive containing a copy of your data has been '\
                    'shipped to you! Your tracking number is XXXXX. Please '\
                    'allow 2-3 days for delivery.'
        end
        leaves_us { true }
      end

      factory :state_restore_drive_return_delayed do
        percentage { 93 }
        label { 'Drive return delayed' }
        key { 'restore_order_drive_return_delayed' }
        description do
          'It has been a while since your order has shipped. To '\
                    'avoid being charged for the drive, please ship it back '\
                    'to us as soon as possible.'
        end
        is_out_of_our_hands { true }
      end

      factory :state_restore_completed do
        percentage { 100 }
        label { 'Restore completed' }
        description do
          'We have received your IDrive Express drive back at our '\
                    'offices. This completes your order. Thank you for using IDrive Express!'
        end
        key { 'restore_order_completed' }
        is_drive_event { true }
      end

      factory :state_restore_order_cancelled do
        percentage { 100 }
        label { 'Order cancelled' }
        description { 'Your order has been cancelled.' }
        key { 'restore_order_cancelled' }
      end
    end

    factory :state_idrive_one, aliases: [:state_idrive_one_assembled] do
      order_type do
        OrderType.find_by(key: :idrive_one) || association(:order_type_idrive_one)
      end
      percentage { 66 }
      label { 'Drive assembled and formatted' }
      description { 'Your IDrive One has been assembled and formatted for use' }

      factory :state_idrive_one_initial do
        percentage { 33 }
        label { 'Order created' }
        description { 'Your IDrive One order has been received' }
        key { 'idrive_one_order_created' }
        public_by_default { true }
        notify_by_default { true }
      end

      factory :state_idrive_one_account_verified do
        percentage { 40 }
        label { 'Account verification OK' }
        description { 'Account is paid and in good standing. No red flags found. OK to ship.' }
      end

      factory :state_idrive_one_status_update do
        percentage { 50 }
        label { 'Status update' }
        description { 'Additional information during the processing of the order' }
        key { 'idrive_one_status_update' }
      end

      factory :state_idrive_one_shipping_label_generated do
        percentage { 80 }
        label { 'Shipping label generated' }
        description { 'USPS tracking number: XXXX' }
        key { 'idrive_one_shipping_label_generated' }
      end

      factory :state_idrive_one_order_shipped do
        percentage { 100 }
        label { 'Drive shipped' }
        key { 'idrive_one_order_shipped' }
        description do
          'Your IDrive One has been shipped and your order is '\
                    'complete! Your tracking number is XXXXX. Please '\
                    'allow 2-3 days for delivery.'
        end
        is_drive_event { true }
        leaves_us { true }
        public_by_default { true }
        notify_by_default { true }
      end

      factory :state_idrive_one_order_cancelled do
        percentage { 100 }
        label { 'Order cancelled' }
        description { 'Your IDrive One order has been cancelled' }
        key { 'idrive_one_order_cancelled' }
        public_by_default { true }
        notify_by_default { true }
      end
    end

    factory :state_idrive_bmr do
      order_type do
        OrderType.find_by(key: :idrive_bmr) || association(:order_type_idrive_bmr)
      end
      ApplicationRecords.new('080-state_idrive_bmr').records.each do |state|
        attrs = state['core'].merge(state.fetch('update', {}))
                             .merge(state.fetch('create', {}))

        factory "state_#{attrs['key']}".downcase.to_sym do
          attrs.each do |k, v|
            next if k == 'order_type'

            send(k.to_sym, v)
          end
        end
      end
    end

    factory :state_idrive_bmr_upload do
      order_type do
        OrderType.find_by(key: :idrive_bmr_upload) || association(:order_type_idrive_bmr_upload)
      end
      ApplicationRecords.new('110-state_idrive_bmr_upload').records.each do |state|
        attrs = state['core'].merge(state.fetch('update', {}))
                             .merge(state.fetch('create', {}))

        factory "state_#{attrs['key']}".downcase.to_sym do
          attrs.each do |k, v|
            next if k == 'order_type'

            send(k.to_sym, v)
          end
        end
      end
    end

    factory :state_idrive_bmr_restore do
      order_type do
        OrderType.find_by(key: :idrive_bmr_restore) || association(:order_type_idrive_bmr_restore)
      end
      ApplicationRecords.new('120-state_idrive_bmr_restore').records.each do |state|
        attrs = state['core'].merge(state.fetch('update', {}))
                             .merge(state.fetch('create', {}))

        factory "state_#{attrs['key']}".downcase.to_sym do
          attrs.each do |k, v|
            next if k == 'order_type'

            send(k.to_sym, v)
          end
        end
      end
    end

    factory :state_idrive360_upload do
      order_type do
        OrderType.find_by(key: :idrive360_upload) || association(:order_type_idrive360_upload)
      end
      ApplicationRecords.new('130-state_idrive360_upload').records.each do |state|
        attrs = state['core'].merge(state.fetch('update', {}))
                             .merge(state.fetch('create', {}))

        factory "state_#{attrs['key']}".downcase.to_sym do
          attrs.each do |k, v|
            next if k == 'order_type'

            send(k.to_sym, v)
          end
        end
      end
    end

    factory :state_idrive360_restore do
      order_type do
        OrderType.find_by(key: :idrive360_restore) || association(:order_type_idrive360_restore)
      end
      ApplicationRecords.new('140-state_idrive360_restore').records.each do |state|
        attrs = state['core'].merge(state.fetch('update', {}))
                             .merge(state.fetch('create', {}))

        factory "state_#{attrs['key']}".downcase.to_sym do
          attrs.each do |k, v|
            next if k == 'order_type'

            send(k.to_sym, v)
          end
        end
      end
    end

    factory :state_ibackup_upload, aliases: [:state_ibackup_upload_started] do
      order_type do
        OrderType.find_by(key: :ibackup_upload) || association(:order_type_ibackup_upload)
      end
      percentage { 84 }
      label { 'Upload started' }
      description { 'Your data upload has begun.' }
      active { true }
      public_by_default { false }
      notify_by_default { false }
      is_drive_event { false }
      is_out_of_our_hands { false }
      leaves_us { false }

      factory :state_ibackup_upload_initial do
        percentage { 14 }
        label { 'Order created' }
        description { 'Your IBackup Express order has been received.' }
        key { 'ibackup_upload_order_created' }
        public_by_default { true }
        notify_by_default { true }
      end

      factory :state_ibackup_upload_international_shipping_fee do
        percentage { 16 }
        label { 'International shipping fee' }
        description do
          'Thank you for your your interest in using the IBackup '\
                    'Express service. Before we process your order, since '\
                    'this is shipping internationally, we wanted to make sure '\
                    'you were aware of the additional shipping costs of the '\
                    'order. In your location, the expected cost for this is '\
                    '$XX.XX USD. Please be advised that this only covers the '\
                    'cost of shipping the drive to you, and not the cost of '\
                    "return shipping.\n\nThe charge for shipping would be "\
                    'applied to your IBackup account, to the same card on '\
                    'file. Please send an email to support@ibackup.com '\
                    'confirming you accept these charges, and we will process '\
                    'your request. Please do not reply to this email with '\
                    'your confirmation. If you decline, we will cancel your '\
                    'Express order, but your online backup account will be '\
                    'unaffected. If you have any questions, please let us '\
                    "know by emailing us at support@ibackup.com.\n\nThanks "\
                    'for using IBackup!'
        end
        public_by_default { true }
      end

      factory :state_ibackup_upload_on_hold_pre_shipped do
        percentage { 20 }
        label { 'On hold - pre shipped' }
        description do
          'An order placed on hold before it was shipped. For '\
                    'orders that may have been made in mistake, or to '\
                    'investigate any potential red flags.'
        end
      end

      factory :state_ibackup_upload_drive_shipped do
        percentage { 42 }
        label { 'Drive shipped' }
        key { 'ibackup_upload_order_shipped' }
        description do
          'Your drive has been shipped! Your tracking number is XXXXX. Please allow 2-3 days for delivery.'
        end
        leaves_us { true }
      end

      factory :state_ibackup_upload_drive_return_delayed do
        percentage { 49 }
        label { 'Drive return delayed' }
        key { 'ibackup_upload_order_drive_return_delayed' }
        description do
          'It has been a while since your order has shipped. To '\
                    'avoid being charged for the drive, please ship it back '\
                    'to us as soon as possible.'
        end
        is_out_of_our_hands { true }
      end

      factory :state_ibackup_upload_drive_arrived_at_datacenter do
        percentage { 56 }
        label { 'Drive received at datacenter' }
        description { 'We have received your IBackup Express drive. Your data will be uploaded soon!' }
      end

      factory :state_ibackup_upload_completed do
        percentage { 100 }
        label { 'Upload completed' }
        description do
          "Your IBackup Express transfer is now complete!\n\nWe "\
                    'recommend you to verify the uploaded data online and let '\
                    'us know if you find any discrepancies. You are also now '\
                    'ready to begin performing incremental backups from your '\
                    'computer and we encourage you to start an incremental '\
                    "backup at your next convenience.\n\nThank you for "\
                    'choosing IBackup and we hope that you are satisfied with '\
                    'our service. If you have any billing, sales or technical '\
                    'questions please refer to our website (www.ibackup.com) '\
                    'or call our customer support team at 866-748-0555, '\
                    "6AM - 6PM PST, Monday - Friday.\n\nWe always appreciate "\
                    'feedback and encourage you to leave your thoughts and '\
                    'suggestions via our online feedback form: '\
                    "https://www.ibackup.com/support.htm.\n\nThanks again!"
        end
        key { 'ibackup_upload_order_completed' }
        is_drive_event { true }
      end
    end

    factory :state_ibackup_restore, aliases: [:state_ibackup_restore_restore_started] do
      order_type do
        OrderType.find_by(key: :ibackup_restore) || association(:order_type_ibackup_restore)
      end
      percentage { 42 }
      label { 'Restore started' }
      description { 'Your data restore has begun.' }

      factory :state_ibackup_restore_initial do
        percentage { 14 }
        label { 'Order created' }
        description { 'Your IDrive Express order has been received' }
        key { 'ibackup_restore_order_created' }
        public_by_default { true }
        notify_by_default { true }
      end

      factory :state_ibackup_restore_international_shipping_fee do
        percentage { 63 }
        label { 'International shipping fee' }
        description do
          'Thank you for your your interest in using the Express '\
                    'Service. Before we process your order, since this is '\
                    'shipping internationally, we wanted to make sure you '\
                    'were aware of the additional shipping costs of the '\
                    'order. In your location, the expected cost for this is '\
                    "$XX.XX USD.\n\nThe charge for shipping would be applied "\
                    'to your IDrive Account, on the same card on file. Please '\
                    'reply confirming you accept these charges, and we will '\
                    'process your request. If you decline, we will cancel '\
                    'your Express order, but your Online Backup account will '\
                    'be unaffected. If you have any questions, please let us know.'
        end
      end

      factory :state_ibackup_restore_order_shipped do
        percentage { 84 }
        label { 'Drive shipped' }
        key { 'ibackup_restore_order_shipped' }
        description do
          'A drive containing a copy of your data has been shipped '\
                    'to you! Your tracking number is XXXXX. Please allow 2-3 days for delivery.'
        end
        leaves_us { true }
      end

      factory :state_ibackup_restore_drive_return_delayed do
        percentage { 93 }
        label { 'Drive return delayed' }
        key { 'ibackup_restore_order_drive_return_delayed' }
        description do
          'It has been a while since your order has shipped. To '\
                    'avoid being charged for the drive, please ship it back to us as soon as possible.'
        end
        is_out_of_our_hands { true }
      end

      factory :state_ibackup_restore_completed do
        percentage { 100 }
        label { 'Restore completed' }
        description do
          'We have received your IDrive Express drive back at our '\
                    'offices. This completes your order. Thank you for using IDrive Express!'
        end
        key { 'ibackup_restore_order_completed' }
        is_drive_event { true }
      end

      factory :state_ibackup_restore_order_cancelled do
        percentage { 100 }
        label { 'Order cancelled' }
        description { 'Your order has been cancelled.' }
        key { 'ibackup_restore_order_cancelled' }
      end
    end
  end
end
