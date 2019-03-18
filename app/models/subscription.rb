class Subscription < ApplicationRecord
  belongs_to :plan
  belongs_to :customer
  accepts_nested_attributes_for :customer

  validates :next_billing_date, presence: true

  def submit_initial_payment
    missing_attributes = check_for_missing_attributes_before_purchase
    return { success: false, errors: "#{missing_attributes.join(', ')} must be provided" } if missing_attributes.present?

    if customer.persisted?
      fake_pay_response = submit_fake_pay_purchase_with_token
    else
      fake_pay_response = submit_fake_pay_purchase_with_credit_card
    end

    process_fake_pay_response(fake_pay_response)
  end

  def renew_payment
    fake_pay_response = submit_fake_pay_purchase_with_token

    process_fake_pay_response(fake_pay_response)
  end

  private

  def check_for_missing_attributes_before_purchase
    missing_subscription_attributes = validate_before_initial_payment
    self.customer ||= Customer.new
    missing_customer_attributes = customer.validate_before_initial_payment
    missing_subscription_attributes + missing_customer_attributes
  end

  def validate_before_initial_payment
    required_attributes = [
      :plan_id,
    ]
    required_attributes.select { |attr_name| self.send(attr_name).blank? }
  end

  def submit_fake_pay_purchase_with_token
    FakePayApi.submit_purchase_request_with_token(
      token: customer.fake_pay_token,
      price: plan.price
    )
  end

  def submit_fake_pay_purchase_with_credit_card
    FakePayApi.submit_purchase_request_with_credit_card(
      credit_card_number: customer.billing_credit_card_number,
      expiration_month:   customer.billing_expiration_month,
      expiration_year:    customer.billing_expiration_year,
      cvv:                customer.billing_cvv,
      zipcode:            customer.billing_zipcode,
      price:              plan.price
    )
  end

  def process_fake_pay_response(response)
    return { success: false, errors: response[:error] } unless response[:success]

    customer.fake_pay_token = response[:token]
    self.next_billing_date = Date.today + 1.month

    if self.save
      { success: true, errors: nil }
    else
      { success: false, errors: self.errors }
    end
  end
end
