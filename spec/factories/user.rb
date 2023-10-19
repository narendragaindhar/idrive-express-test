FactoryBot.define do
  factory :user do
    sequence :email do |n|
      "#{Faker::Internet.user_name}#{n}@#{Faker::Internet.domain_name}"
    end
    name { Faker::Name.name }
    password { 'password' }
  end
end
