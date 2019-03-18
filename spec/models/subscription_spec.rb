require 'rails_helper'

RSpec.describe Subscription, type: :model do
  it 'has a valid factory' do
    expect(build(:subscription)).to be_valid
  end

  describe 'ActiveModel validations' do
    it { is_expected.to validate_presence_of(:shipping_name) }
    it { is_expected.to validate_presence_of(:shipping_address) }
    it { is_expected.to validate_presence_of(:shipping_zipcode) }
    it { is_expected.to validate_presence_of(:fake_pay_token) }
    it { is_expected.to validate_presence_of(:next_billing_date) }
  end

  let(:valid_token)   { "abcdef123456" }
  let(:error_message) { "Generic Error" }
  let(:successful_fake_pay_response) { { success: true,  token: valid_token, error: nil } }
  let(:failed_fake_pay_response)     { { success: false, token: nil,         error: error_message } }

  describe '#submit_initial_payment' do
    let(:subscription) { build(:subscription, :with_credit_card, fake_pay_token: nil, next_billing_date: nil, plan: create(:plan)) }

    it 'upon success of FakePayApi, sets the fake_pay_token and next_billing_date' do
      allow(FakePayApi).to receive(:submit_purchase_request_with_credit_card).and_return(successful_fake_pay_response)
      subscription.submit_initial_payment
      expect(subscription.fake_pay_token).to eql(valid_token)
      expect(subscription.next_billing_date).to eql(Date.today + 1.month)
    end

    it 'upon success of FakePayApi, returns a Hash where :success is true and :errors is nil' do
      allow(FakePayApi).to receive(:submit_purchase_request_with_credit_card).and_return(successful_fake_pay_response)
      expect(subscription.submit_initial_payment).to eq({ success: true, errors: nil })
    end

    it 'upon failure of FakePayApi, returns a Hash where :success is false and :errors has a message' do
      allow(FakePayApi).to receive(:submit_purchase_request_with_credit_card).and_return(failed_fake_pay_response)
      expect(subscription.submit_initial_payment).to eq({ success: false, errors: error_message })
    end

    it 'upon failure to save record, returns a Hash where :success is false and :errors has messages' do
      allow(FakePayApi).to receive(:submit_purchase_request_with_credit_card).and_return(successful_fake_pay_response)
      allow(subscription).to receive(:save).and_return(false)
      allow(subscription).to receive(:errors).and_return(error_message)
      expect(subscription.submit_initial_payment).to eq({ success: false, errors: error_message })
    end
  end

  describe '#renew_payment' do
    let(:subscription) { create(:subscription, fake_pay_token: valid_token) }

    it 'upon success of FakePayApi, sets the fake_pay_token and next_billing_date' do
      allow(FakePayApi).to receive(:submit_purchase_request_with_token).and_return(successful_fake_pay_response)
      subscription.renew_payment
      expect(subscription.fake_pay_token).to eql(valid_token)
      expect(subscription.next_billing_date).to eql(Date.today + 1.month)
    end

    it 'upon success of FakePayApi, returns a Hash where :success is true and :errors is nil' do
      allow(FakePayApi).to receive(:submit_purchase_request_with_token).and_return(successful_fake_pay_response)
      expect(subscription.renew_payment).to eq({ success: true, errors: nil })
    end

    it 'upon failure of FakePayApi, returns a Hash where :success is false and :errors has a message' do
      allow(FakePayApi).to receive(:submit_purchase_request_with_token).and_return(failed_fake_pay_response)
      expect(subscription.renew_payment).to eq({ success: false, errors: error_message })
    end

    it 'upon failure to save record, returns a Hash where :success is false and :errors has messages' do
      allow(FakePayApi).to receive(:submit_purchase_request_with_token).and_return(successful_fake_pay_response)
      allow(subscription).to receive(:save).and_return(false)
      allow(subscription).to receive(:errors).and_return(error_message)
      expect(subscription.renew_payment).to eq({ success: false, errors: error_message })
    end
  end
end
