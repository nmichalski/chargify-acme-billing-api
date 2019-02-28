class SubscriptionsController < ApplicationController
  def index
    subscriptions = Subscription.all
    render json: subscriptions
  end

  def create
    error_message = validate_create_subscription_params
    if error_message.present?
      render json: { errors: error_message }, status: :unprocessable_entity
      return
    end

    plan = Plan.find(params[:plan_id])
    fake_pay_response = FakePayApi.submit_purchase_request(
      credit_card_number: params[:billing_credit_card_number],
      expiration_month:   params[:billing_expiration_month],
      expiration_year:    params[:billing_expiration_year],
      cvv:                params[:billing_cvv],
      zipcode:            params[:billing_zipcode],
      price:              plan.price
    )

    if fake_pay_response[:success]
      subscription = Subscription.new(subscription_params)
      subscription.fake_pay_token = fake_pay_response[:token]
      subscription.next_billing_date = Date.today + 1.month

      if subscription.save
        render json: subscription, status: :created
        return
      else
        render json: { errors: subscription.errors }, status: :unprocessable_entity
        return
      end
    else
      render json: { errors: fake_pay_response[:error] }, status: :unprocessable_entity
    end
  end

  def show
    subscription = Subscription.find(params[:id])
    render json: subscription
  end

  def update
    # to be implemented...
  end

  def destroy
    # to be implemented...
  end

  private

  def validate_create_subscription_params
    required_params = [
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
    submitted_params = params.keys.map(&:to_sym)
    missing_params = required_params - submitted_params

    missing_params.present? ? "#{missing_params.join(', ')} must be provided" : nil
  end

  def subscription_params
    params.permit([
      :plan_id,
      :shipping_name,
      :shipping_address,
      :shipping_zipcode,
    ])
  end
end
