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
    fake_pay_response = FakePayApi.submit_purchase_request(
      credit_card_number: billing_credit_card_number,
      expiration_month:   billing_expiration_month,
      expiration_year:    billing_expiration_year,
      cvv:                billing_cvv,
      zipcode:            billing_zipcode,
      price:              self.plan.price
    )

    parse_fake_pay_response(fake_pay_response)
  end

  private

  def parse_fake_pay_response(response)
    if response[:success]
      self.fake_pay_token = response[:token]
      self.next_billing_date = Date.today + 1.month

      if self.save
        { success: true, errors: nil }
      else
        { success: false, errors: self.errors }
      end
    else
      { success: false, errors: response[:error] }
    end
  end
end
