class Subscription < ApplicationRecord
  belongs_to :plan

  validates :plan_id, presence: true
  validates :shipping_name, presence: true
  validates :shipping_address, presence: true
  validates :shipping_zipcode, presence: true
  validates :fake_pay_token, presence: true
  validates :next_billing_date, presence: true
end
