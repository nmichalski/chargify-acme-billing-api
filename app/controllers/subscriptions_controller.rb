class SubscriptionsController < ApplicationController
  def index
    subscriptions = Subscription.all
    render json: subscriptions
  end

  def create
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
