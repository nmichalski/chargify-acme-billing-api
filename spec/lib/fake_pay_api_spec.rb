require 'rails_helper'

RSpec.describe FakePayApi do
  let(:api_token) { "abcdef123456" }
  let(:price)     { "100" }
  let(:successful_rest_response_body) { { success: true, token: api_token, error_code: nil }.to_json }
  let(:failed_rest_response_body) { { success: false, token: nil, error_code: 1000001 }.to_json }

  describe '.submit_purchase_request_with_credit_card' do
    let(:cc_number) { "1111222233334444" }
    let(:exp_month) { "01" }
    let(:exp_year)  { "2030" }
    let(:cvv)       { "123" }
    let(:zipcode)   { "12345" }
    let(:valid_cc_payload) do
      {
        amount: price,
        card_number: cc_number,
        cvv: cvv,
        expiration_month: exp_month,
        expiration_year: exp_year,
        zip_code: zipcode,
      }
    end
    let(:valid_args) do
      {
        credit_card_number: cc_number,
        expiration_month: exp_month,
        expiration_year: exp_year,
        cvv: cvv,
        zipcode: zipcode,
        price: price
      }
    end

    it 'makes RESTful call with payload of credit card info' do
      allow(FakePayApi).to receive(:parse_response)
      expect(RestClient).to receive(:post).with(FakePayApi::PURCHASE_URL, valid_cc_payload, FakePayApi.send(:authorization_header))
      FakePayApi.submit_purchase_request_with_credit_card(valid_args)
    end

    it 'gracefully handles RestClient exceptions' do
      allow(FakePayApi).to receive(:parse_response)
      expect(RestClient).to receive(:post).and_raise(RestClient::ExceptionWithResponse)
      expect { FakePayApi.submit_purchase_request_with_credit_card(valid_args) }.not_to raise_error
    end

    it 'upon success, returns Hash where :success is true, :token is present, and :error is nil' do
      mock_response = double(body: successful_rest_response_body)
      allow(FakePayApi).to receive(:make_request_to_api).and_return(mock_response)
      expect(
        FakePayApi.submit_purchase_request_with_credit_card(valid_args)
      ).to eql({ success: true, token: api_token, error: nil })
    end

    it 'upon failure, returns Hash where :success is false, :token is nil, and :error has PaymentProcessingError' do
      mock_response = double(body: failed_rest_response_body)
      allow(FakePayApi).to receive(:make_request_to_api).and_return(mock_response)
      expect(
        FakePayApi.submit_purchase_request_with_credit_card(valid_args)
      ).to eql({ success: false, token: nil, error: "PaymentProcessingError: Invalid credit card number" })
    end
  end

  describe '.submit_purchase_request_with_token' do
    let(:valid_token_payload) { { amount: price, token: api_token } }
    let(:valid_args) { { price: price, token: api_token } }

    it 'makes RESTful call with payload of token info' do
      allow(FakePayApi).to receive(:parse_response)
      expect(RestClient).to receive(:post).with(FakePayApi::PURCHASE_URL, valid_token_payload, FakePayApi.send(:authorization_header))
      FakePayApi.submit_purchase_request_with_token(valid_args)
    end

    it 'gracefully handles RestClient exceptions' do
      allow(FakePayApi).to receive(:parse_response)
      expect(RestClient).to receive(:post).and_raise(RestClient::ExceptionWithResponse)
      expect { FakePayApi.submit_purchase_request_with_token(valid_args) }.not_to raise_error
    end

    it 'upon success, returns Hash where :success is true, :token is present, and :error is nil' do
      mock_response = double(body: successful_rest_response_body)
      allow(FakePayApi).to receive(:make_request_to_api).and_return(mock_response)
      expect(
        FakePayApi.submit_purchase_request_with_token(valid_args)
      ).to eql({ success: true, token: api_token, error: nil })
    end

    it 'upon failure, returns Hash where :success is false, :token is nil, and :error has PaymentProcessingError' do
      mock_response = double(body: failed_rest_response_body)
      allow(FakePayApi).to receive(:make_request_to_api).and_return(mock_response)
      expect(
        FakePayApi.submit_purchase_request_with_token(valid_args)
      ).to eql({ success: false, token: nil, error: "PaymentProcessingError: Invalid credit card number" })
    end
  end
end
