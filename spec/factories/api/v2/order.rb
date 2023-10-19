FactoryBot.define do
  factory :api_v2_order, class: Hash do
    skip_create

    transient do
      comments { ['', Faker::Lorem.sentence, Faker::Lorem.sentences(rand(1..10)).join("\n")].sample }
      username { Faker::Internet.user_name }
      email { Faker::Internet.email }
      name { Faker::Name.name }
      quota { rand(52_428_800..21_990_232_555_520) }
      server { "evs#{rand(1..1500)}.idrive.com" }
      max_size { quota - rand(1..quota) }
      destination do
        { key: %w[alchemy viawest_1 office].sample }
      end
      order_type do
        { key: %w[upload restore].sample }
      end
    end

    order do
      {
        comments: comments,
        max_size: max_size,
        os: %w[Windows Mac Linux].sample,
        needs_review: false,
        customer: {
          username: username,
          email: email,
          name: name,
          phone: Faker::PhoneNumber.phone_number,
          server: server,
          quota: quota,
          created_at: 4.weeks.ago.strftime('%Y-%m-%d %H:%M:%S'),
          priority: 0
        },
        destination: destination,
        express_kind: order_type,
        address: {
          recipient: name,
          organization: Faker::Company.name,
          address: Faker::Address.street_address,
          city: Faker::Address.city,
          zip: Faker::Address.zip_code,
          country: Faker::Address.country
        }
      }
    end

    factory :api_v2_order_upload do
      transient do
        destination do
          { key: %w[alchemy viawest_1].sample }
        end
        order_type do
          { key: 'upload' }
        end
      end
    end

    factory :api_v2_order_restore do
      transient do
        destination do
          { key: 'office' }
        end
        order_type do
          { key: 'restore' }
        end
      end
    end
  end
end
