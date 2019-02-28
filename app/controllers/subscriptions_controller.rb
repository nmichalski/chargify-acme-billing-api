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

    subscription = Subscription.new(subscription_params)
    payment_response = subscription.submit_initial_payment

    if payment_response[:success]
      render json: subscription, status: :created
    else
      render json: { errors: payment_response[:errors] }, status: :unprocessable_entity
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
      :billing_credit_card_number,
      :billing_expiration_month,
      :billing_expiration_year,
      :billing_cvv,
      :billing_zipcode,
    ])
  end
end
