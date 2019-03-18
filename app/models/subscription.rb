class Subscription < ApplicationRecord
  belongs_to :plan

  validates :shipping_name, presence: true
  validates :shipping_address, presence: true
  validates :shipping_zipcode, presence: true
  validates :fake_pay_token, presence: true
  validates :next_billing_date, presence: true

  attr_accessor \
    :billing_credit_card_number,
    :billing_expiration_month,
    :billing_expiration_year,
    :billing_cvv,
    :billing_zipcode

  def submit_initial_payment
    missing_attributes = validate_before_initial_payment
    return { success: false, errors: "#{missing_attributes.join(', ')} must be provided" } if missing_attributes.present?

    fake_pay_response = FakePayApi.submit_purchase_request_with_credit_card(
      credit_card_number: billing_credit_card_number,
      expiration_month:   billing_expiration_month,
      expiration_year:    billing_expiration_year,
      cvv:                billing_cvv,
      zipcode:            billing_zipcode,
      price:              self.plan.price
    )

    process_fake_pay_response(fake_pay_response)
  end

  def renew_payment
    fake_pay_response = FakePayApi.submit_purchase_request_with_token(
      token: self.fake_pay_token,
      price: self.plan.price
    )

    process_fake_pay_response(fake_pay_response)
  end

  private

  def validate_before_initial_payment
    required_attributes = [
      :plan_id,
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

  def process_fake_pay_response(response)
    return { success: false, errors: response[:error] } unless response[:success]

    self.fake_pay_token = response[:token]
    self.next_billing_date = Date.today + 1.month

    if self.save
      { success: true, errors: nil }
    else
      { success: false, errors: self.errors }
    end
  end
end
