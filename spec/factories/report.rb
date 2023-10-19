FactoryBot.define do
  factory :report do
    name { 'Number of active orders' }
    description { 'Shows the current number of active orders' }
    query { <<~SQL }
      SELECT
          COUNT(1)
      FROM `orders`
      WHERE
          `completed_at` IS NULL
      ;
    SQL
  end
end
