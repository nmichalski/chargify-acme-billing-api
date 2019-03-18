FactoryBot.define do
  factory :subscription do
    shipping_name     { "John Doe" }
    shipping_address  { "123 Main St, Anytown, CA" }
    shipping_zipcode  { "12345" }
    fake_pay_token    { "abcdef123456" }
    next_billing_date { Date.today + 1.month }
    plan

    trait :with_credit_card do
      billing_credit_card_number { "1111222233334444" }
      billing_expiration_month   { "01" }
      billing_expiration_year    { "2030" }
      billing_cvv                { "123" }
      billing_zipcode            { "12345" }
    end
  end
end
