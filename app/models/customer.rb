class Customer < ApplicationRecord
  has_many :subscriptions

  validates :shipping_name, presence: true
  validates :shipping_address, presence: true
  validates :shipping_zipcode, presence: true
  validates :fake_pay_token, presence: true

  attr_accessor \
    :billing_credit_card_number,
    :billing_expiration_month,
    :billing_expiration_year,
    :billing_cvv,
    :billing_zipcode

  def validate_before_initial_payment
    return [] if self.persisted?

    required_attributes = [
      :shipping_name,
      :shipping_address,
      :shipping_zipcode,
      :billing_credit_card_number,
      :billing_expiration_month,
      :billing_expiration_year,
      :billing_cvv,
      :billing_zipcode,
    ]
    required_attributes.select { |attr_name| self.send(attr_name).blank? }
  end
end
