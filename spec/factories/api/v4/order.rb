FactoryBot.define do
  factory :api_v4_order, class: Hash do
    skip_create

    transient do
      comments do
        if order_type[:key] == 'idrive_one'
          size < 1_099_511_627_776 ? 'SSD' : 'HDD'
        else
          ['', Faker::Lorem.sentence, Faker::Lorem.sentences(rand(1..10)).join("\n")].sample
        end
      end
      username { Faker::Internet.user_name }
      email { Faker::Internet.email }
      name { Faker::Name.name }
      os do
        case order_type[:key]
        when 'idrive_one', 'idrive_bmr', 'idrive_bmr_upload', 'idrive_bmr_restore'
          nil
        else
          %w[Windows Mac Linux].sample
        end
      end
      quota do
        case order_type[:key]
        when 'idrive_bmr', 'idrive_bmr_upload', 'idrive_bmr_restore'
          [
            # 4TB,             6TB,               12TB,
            4_398_046_511_104, 6_597_069_766_656, 13_194_139_533_312,
            # 24TB              48TB
            26_388_279_066_624, 52_776_558_133_248
          ].sample
        else
          rand(52_428_800..21_990_232_555_520)
        end
      end
      phone { [Faker::PhoneNumber.phone_number, '', nil].sample }
      server do
        case order_type[:key]
        when 'idrive_bmr', 'idrive_bmr_upload', 'idrive_bmr_restore'
          "bmr#{rand(1..100)}.idrive.com"
        else
          "evs#{rand(1..1500)}.#{order_type[:key].match?(/ibackup/) ? 'ibackup' : 'idrive'}.com"
        end
      end
      size do
        case order_type[:key]
        when 'idrive_one'
          # 128GB,          256GB,           1TB,               2TB
          [137_438_953_472, 274_877_906_944, 1_099_511_627_776, 2_199_023_255_552].sample
        when 'idrive_bmr', 'idrive_bmr_upload', 'idrive_bmr_restore'
          quota
        else
          quota - rand(1..quota)
        end
      end
      destination do
        dest = case order_type[:key]
               when /upload/
                 %w[alchemy viawest_1 iron_mountain viatel].sample
               else
                 'office'
               end
        {
          key: dest
        }
      end
      order_type do
        {
          key: %w[idrive_upload idrive_restore idrive_one
                  idrive_bmr idrive_bmr_upload idrive_bmr_restore
                  idrive360_upload idrive360_restore ibackup_upload ibackup_restore].sample
        }
      end
      address do
        country = order_type[:key] == 'idrive_one' ? 'USA' : Faker::Address.country
        state = order_type[:key] == 'idrive_one' || country == 'USA' ? Faker::Address.state : nil
        {
          recipient: name,
          organization: Faker::Company.name,
          address: Faker::Address.street_address,
          city: Faker::Address.city,
          state: state,
          zip: Faker::Address.zip_code,
          country: country
        }
      end
    end

    order do
      {
        comments: comments,
        size: size,
        os: os,
        needs_review: false,
        customer: {
          username: username,
          email: email,
          name: name,
          phone: phone,
          server: server,
          quota: quota,
          created_at: 4.weeks.ago.strftime('%Y-%m-%d %H:%M:%S'),
          priority: 0
        },
        destination: destination,
        order_type: order_type,
        address: address
      }
    end

    factory :api_v4_order_idrive_upload do
      transient do
        order_type do
          { key: 'idrive_upload' }
        end
      end
    end

    factory :api_v4_order_idrive_restore do
      transient do
        order_type do
          { key: 'idrive_restore' }
        end
      end
    end

    factory :api_v4_order_idrive_one do
      transient do
        order_type do
          { key: 'idrive_one' }
        end
      end
    end

    factory :api_v4_order_idrive_bmr do
      transient do
        order_type do
          { key: 'idrive_bmr' }
        end
      end
    end

    factory :api_v4_order_idrive_bmr_upload do
      transient do
        order_type do
          { key: 'idrive_bmr_upload' }
        end
      end
    end

    factory :api_v4_order_idrive_bmr_restore do
      transient do
        order_type do
          { key: 'idrive_bmr_restore' }
        end
      end
    end

    factory :api_v4_order_idrive360_upload do
      transient do
        order_type do
          { key: 'idrive360_upload' }
        end
      end
    end

    factory :api_v4_order_idrive360_restore do
      transient do
        order_type do
          { key: 'idrive360_restore' }
        end
      end
    end

    factory :api_v4_order_ibackup_upload do
      transient do
        order_type do
          { key: 'ibackup_upload' }
        end
      end
    end

    factory :api_v4_order_ibackup_restore do
      transient do
        order_type do
          { key: 'ibackup_restore' }
        end
      end
    end
  end
end
