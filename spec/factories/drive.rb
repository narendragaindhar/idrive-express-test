require 'securerandom'

FactoryBot.define do
  factory :drive do
    sequence :identification_number do |n|
      "#{SecureRandom.hex.upcase}-#{n}"
    end
    sequence :serial do |n|
      "#{SecureRandom.hex.upcase}-#{n}"
    end
    active { true }
    in_use { false }
    size { 2_199_023_255_552 } # 2TB
  end
end
