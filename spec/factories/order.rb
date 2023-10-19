FactoryBot.define do
  factory :order, aliases: [:order_upload] do
    address
    order_type do
      OrderType.find_by(key: :idrive_upload) || association(:order_type_idrive_upload)
    end
    customer
    destination do
      Destination.find_by(key: 'viawest_1') || association(:destination_viawest_1)
    end
    size { customer.present? ? customer.quota - rand(1..customer.quota) : 1_099_511_627_776 }
    os { %w[Windows Mac Linux].sample }
    comments { [nil, '', Faker::Lorem.sentence, Faker::Lorem.sentences.join("\n")].sample }
    needs_review { false }

    before(:create) do
      State.find_by(key: 'upload_order_created') || create(:state_initial)
    end

    factory :order_with_drive do
      drive
    end

    factory :order_with_day_count do
      day_count
    end

    # restore order
    factory :order_restore do
      order_type do
        OrderType.find_by(key: :idrive_restore) || association(:order_type_idrive_restore)
      end
      destination do
        Destination.find_by(key: 'office') || association(:destination_office)
      end

      before(:create) do
        State.find_by(key: 'restore_order_created') || create(:state_restore_initial)
      end

      factory :order_restore_with_drive do
        drive
      end

      factory :order_restore_with_day_count do
        day_count
      end
    end

    # idrive one order
    factory :order_idrive_one do
      address { association(:address, country: 'USA') }
      order_type do
        OrderType.find_by(key: 'idrive_one') || association(:order_type_idrive_one)
      end
      destination do
        Destination.find_by(key: 'office') || association(:destination_office)
      end
      size do
        # 128GB,          256GB,           1TB,               2TB
        [137_438_953_472, 274_877_906_944, 1_099_511_627_776, 2_199_023_255_552].sample
      end
      comments { size < 1_099_511_627_776 ? 'SSD' : 'HDD' }

      before(:create) do
        State.find_by(key: 'idrive_one_order_created') || create(:state_idrive_one_initial)
      end

      factory :order_idrive_one_with_drive do
        drive
      end
    end

    factory :order_idrive_bmr do
      order_type do
        OrderType.find_by(key: :idrive_bmr) || association(:order_type_idrive_bmr)
      end
      destination do
        Destination.find_by(key: :office) || association(:destination_office)
      end
      size do
        # 6TB,              8TB,               10TB,               20TB
        [6_597_069_766_656, 8_796_093_022_208, 10_995_116_277_760, 21_990_232_555_520].sample
      end

      before(:create) do
        State.find_by(key: :idrive_bmr_order_created) || create(:state_idrive_bmr_order_created)
      end

      factory :order_idrive_bmr_with_drive do
        drive
      end
    end

    factory :order_idrive_bmr_upload do
      order_type do
        OrderType.find_by(key: :idrive_bmr_upload) || association(:order_type_idrive_bmr_upload)
      end
      destination do
        Destination.find_by(key: :alchemy) || association(:destination_alchemy)
      end
      size do
        # 6TB,              8TB,               10TB,               20TB
        [6_597_069_766_656, 8_796_093_022_208, 10_995_116_277_760, 21_990_232_555_520].sample
      end

      before(:create) do
        State.find_by(key: :idrive_bmr_upload_order_created) || create(:state_idrive_bmr_upload_order_created)
      end
    end

    factory :order_idrive_bmr_restore do
      order_type do
        OrderType.find_by(key: :idrive_bmr_restore) || association(:order_type_idrive_bmr_restore)
      end
      destination do
        Destination.find_by(key: :alchemy) || association(:destination_alchemy)
      end
      size do
        # 6TB,              8TB,               10TB,               20TB
        [6_597_069_766_656, 8_796_093_022_208, 10_995_116_277_760, 21_990_232_555_520].sample
      end

      before(:create) do
        State.find_by(key: :idrive_bmr_restore_order_created) || create(:state_idrive_bmr_restore_order_created)
      end
    end

    factory :order_idrive360_upload do
      order_type do
        OrderType.find_by(key: :idrive360_upload) || association(:order_type_idrive360_upload)
      end
      destination do
        Destination.find_by(key: 'alchemy') || association(:destination_alchemy)
      end

      before(:create) do
        State.find_by(key: :idrive360_upload_order_created) || create(:state_idrive360_upload_order_created)
      end

      factory :order_idrive360_upload_with_drive do
        drive
      end
    end

    factory :order_idrive360_restore do
      order_type do
        OrderType.find_by(key: :idrive360_restore) || association(:order_type_idrive360_restore)
      end
      destination do
        Destination.find_by(key: 'alchemy') || association(:destination_alchemy)
      end

      before(:create) do
        State.find_by(key: :idrive360_restore_order_created) || create(:state_idrive360_restore_order_created)
      end

      factory :order_idrive360_restore_with_drive do
        drive
      end
    end

    factory :order_ibackup_upload do
      order_type do
        OrderType.find_by(key: :ibackup_upload) || association(:order_type_ibackup_upload)
      end
      destination do
        Destination.find_by(key: 'alchemy') || association(:destination_alchemy)
      end

      before(:create) do
        State.find_by(key: 'ibackup_upload_order_created') || create(:state_ibackup_upload_initial)
      end

      factory :order_ibackup_upload_with_drive do
        drive
      end
    end

    factory :order_ibackup_restore do
      order_type do
        OrderType.find_by(key: :ibackup_restore) || association(:order_type_ibackup_restore)
      end
      destination do
        Destination.find_by(key: 'alchemy') || association(:destination_alchemy)
      end

      before(:create) do
        State.find_by(key: 'ibackup_restore_order_created') || create(:state_ibackup_restore_initial)
      end

      factory :order_ibackup_restore_with_drive do
        drive
      end
    end
  end
end
