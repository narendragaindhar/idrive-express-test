FactoryBot.define do
  factory :order_state do
    order
    user
    state
    comments do
      ['', Faker::Lorem.sentence, Faker::Lorem.sentences(rand(1..10)).join("\n")].sample
    end
    did_notify { false }
    is_public { false }
  end
end
