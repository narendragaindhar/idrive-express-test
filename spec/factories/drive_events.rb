FactoryBot.define do
  factory :drive_event do
    drive
    event do
      ['', Faker::Lorem.sentence, Faker::Lorem.sentences(rand(1..10)).join("\n")].sample
    end
    user
  end
end
