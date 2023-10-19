FactoryBot.define do
  factory :customer do
    sequence :username do |n|
      "#{Faker::Internet.user_name}_#{n}"
    end
    sequence :email do |n|
      "#{Faker::Internet.user_name}#{n}@#{Faker::Internet.domain_name}"
    end
    name { Faker::Name.name }
    phone { [Faker::PhoneNumber.phone_number, '', nil].sample }
    server do
      "evsweb#{rand(1..1050)}.#{product.try(:is?, :ibackup) ? 'ibackup' : 'idrive'}.com"
    end
    priority { 0 }
    quota { 2_199_023_255_552 } # 2TB
    created_at { 2.weeks.ago }
    product do
      Product.find_by(name: :idrive) || association(:product_idrive)
    end
  end
end
