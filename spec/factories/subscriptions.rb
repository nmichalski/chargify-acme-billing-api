FactoryBot.define do
  factory :subscription do
    next_billing_date { Date.today + 1.month }
    plan
    customer
  end
end
