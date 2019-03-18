require 'rails_helper'

RSpec.describe SubscriptionsController, type: :controller do
  describe 'GET #index' do
    let!(:subscription) { create(:subscription) }
    let(:serialized_subscription) { JSON.parse(subscription.to_json) }
    let(:expected_record_count) { Subscription.count }

    it 'returns all Subscription records' do
      get :index
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.size).to eql(expected_record_count)
      expect(json_response).to include(serialized_subscription)
    end
  end

  describe 'GET #show' do
    let!(:subscription) { create(:subscription) }
    let(:serialized_subscription) { JSON.parse(subscription.to_json(include: :customer)) }
    let(:valid_params) { { id: subscription.id } }

    it 'returns Subscription with given ID' do
      get :show, params: valid_params
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response).to eql(serialized_subscription)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:valid_params_with_new_customer) do
        {
          plan_id: create(:plan).id,
          customer_attributes: attributes_for(:customer, :with_credit_card),
        }
      end
      let(:valid_params_with_existing_customer) do
        {
          plan_id: create(:plan).id,
          customer_id: create(:customer).id,
        }
      end
      let(:fake_pay_response) do
        {
          success: true,
          token: attributes_for(:customer)[:fake_pay_token],
          error: nil
        }
      end

      it 'given a new customer, increments Subscription.count by 1' do
        allow(FakePayApi).to receive(:submit_purchase_request_with_credit_card).and_return(fake_pay_response)
        expect { post :create, params: valid_params_with_new_customer }.to change { Subscription.count }.by(1)
      end

      it 'given an existing customer, increments Subscription.count by 1' do
        allow(FakePayApi).to receive(:submit_purchase_request_with_token).and_return(fake_pay_response)
        expect { post :create, params: valid_params_with_existing_customer }.to change { Subscription.count }.by(1)
      end

      it 'given a new customer, returns the newly created subscription record' do
        allow(FakePayApi).to receive(:submit_purchase_request_with_credit_card).and_return(fake_pay_response)
        post :create, params: valid_params_with_new_customer
        expect(response).to have_http_status(:created)
        newest_subscription = Subscription.last
        serialized_subscription = JSON.parse(newest_subscription.to_json(include: :customer))
        json_response = JSON.parse(response.body)
        expect(json_response).to eql(serialized_subscription)
      end

      it 'given an existing customer, returns the newly created subscription record' do
        allow(FakePayApi).to receive(:submit_purchase_request_with_token).and_return(fake_pay_response)
        post :create, params: valid_params_with_existing_customer
        expect(response).to have_http_status(:created)
        newest_subscription = Subscription.last
        serialized_subscription = JSON.parse(newest_subscription.to_json(include: :customer))
        json_response = JSON.parse(response.body)
        expect(json_response).to eql(serialized_subscription)
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { {} }

      it 'returns error message listing missing parameters' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to include("plan_id")
        expect(json_response["errors"]).to include("shipping_name")
        expect(json_response["errors"]).to include("shipping_address")
        expect(json_response["errors"]).to include("shipping_zipcode")
        expect(json_response["errors"]).to include("billing_credit_card_number")
        expect(json_response["errors"]).to include("billing_expiration_month")
        expect(json_response["errors"]).to include("billing_expiration_year")
        expect(json_response["errors"]).to include("billing_cvv")
        expect(json_response["errors"]).to include("billing_zipcode")
      end
    end
  end
end
