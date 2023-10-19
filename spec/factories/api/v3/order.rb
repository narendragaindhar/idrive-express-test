FactoryBot.define do
  factory :api_v3_order, class: Hash do
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
        if order_type[:key] == 'idrive_one'
          nil
        else
          %w[Windows Mac Linux].sample
        end
      end
      quota { rand(52_428_800..21_990_232_555_520) }
      phone { [Faker::PhoneNumber.phone_number, '', nil].sample }
      server { "evs#{rand(1..1500)}.idrive.com" }
      size do
        if order_type[:key] == 'idrive_one'
          # 128GB,          256GB,           1TB,               2TB
          [137_438_953_472, 274_877_906_944, 1_099_511_627_776, 2_199_023_255_552].sample
        else
          quota - rand(1..quota)
        end
      end
      destination do
        dest = if order_type[:key] == 'upload'
                 %w[alchemy viawest_1].sample
               else
                 'office'
               end
        {
          key: dest
        }
      end
      order_type do
        { key: %w[upload restore idrive_one].sample }
      end
      address do
        country = order_type[:key] == 'idrive_one' ? 'USA' : Faker::Address.country
        {
          recipient: name,
          organization: Faker::Company.name,
          address: Faker::Address.street_address,
          city: Faker::Address.city,
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

    factory :api_v3_order_upload do
      transient do
        order_type do
          { key: 'upload' }
        end
      end
    end

    factory :api_v3_order_restore do
      transient do
        order_type do
          { key: 'restore' }
        end
      end
    end

    factory :api_v3_order_idrive_one do
      transient do
        order_type do
          { key: 'idrive_one' }
        end
      end
    end
  end
end
