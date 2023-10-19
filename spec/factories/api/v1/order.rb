FactoryBot.define do
  factory :api_v1_order, class: Hash do
    skip_create

    transient do
      username { Faker::Internet.user_name }
      email { Faker::Internet.email }
      name { Faker::Name.name }
      quota { rand(52_428_800..21_990_232_555_520) }
      server { "evs#{rand(1..1500)}.idrive.com" }
      max_upload_size { quota - rand(1..quota) }
    end

    order do
      {
        comments: ['', Faker::Lorem.sentence, Faker::Lorem.sentences(rand(1..10)).join("\n")].sample,
        max_upload_size: max_upload_size,
        os: %w[Windows Mac Linux].sample,
        needs_review: false
      }
    end
    customer do
      {
        username: username,
        email: email,
        name: name,
        phone: Faker::PhoneNumber.phone_number,
        server: server,
        quota: quota,
        created_at: 4.weeks.ago.strftime('%Y-%m-%d %H:%M:%S'),
        priority: 0
      }
    end
    datacenter do
      { key: %w[alchemy viawest_1].sample }
    end
    express_kind do
      { key: 'upload' }
    end
    address do
      {
        recipient: name,
        organization: Faker::Company.name,
        address: Faker::Address.street_address,
        city: Faker::Address.city,
        zip: Faker::Address.zip_code,
        country: Faker::Address.country
      }
    end
  end
end
