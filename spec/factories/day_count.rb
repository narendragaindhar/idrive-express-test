FactoryBot.define do
  factory :day_count do
    order
    count { 0 }
    is_final { false }
    updated_at { 24.hours.ago }
  end
end
