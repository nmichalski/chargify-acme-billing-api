FactoryBot.define do
  factory :customer do
    shipping_name    { "Jane Doe" }
    shipping_address { "123 Main St, Anywhere, CA" }
    shipping_zipcode { "12345" }
    fake_pay_token   { "abcdef123456" }

    trait :with_credit_card do
      billing_credit_card_number { "1111222233334444" }
      billing_expiration_month   { "01" }
      billing_expiration_year    { "2030" }
      billing_cvv                { "123" }
      billing_zipcode            { "12345" }
    end
  end
end
