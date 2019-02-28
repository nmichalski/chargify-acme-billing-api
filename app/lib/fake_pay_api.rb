class FakePayApi

  BASE_URL = "https://www.fakepay.io/purchase"

  class << self
    def submit_purchase_request(credit_card_number:, expiration_month:, expiration_year:, cvv:, zipcode:, price:)
      payload = {
        amount: price,
        card_number: credit_card_number,
        cvv: cvv,
        expiration_month: expiration_month,
        expiration_year: expiration_year,
        zip_code: zipcode,
      }

      begin
        response = RestClient.post(
          BASE_URL,
          payload,
          authorization_header
        )
      rescue RestClient::ExceptionWithResponse => exception
        response = exception.response
      end

      parse_response(response)
    end

    private

    def authorization_header
      { "Authorization" => "Token token=#{ENV["FAKE_PAY_API_KEY"]}" }
    end

    def parse_response(response)
      parsed_response = JSON.parse(response.body)
      success    = parsed_response["success"]
      token      = parsed_response["token"]
      error_code = parsed_response["error_code"]
      error_message = error_code.present? ? error_message_by_code(error_code) : nil

      { success: success, token: token, error: error_message }
    end

    def error_message_by_code(error_code)
      error_message_prefix = "PaymentProcessingError: "
      error_messages = {
        1000001 => "Invalid credit card number",
        1000002 => "Insufficient funds",
        1000003 => "CVV failure",
        1000004 => "Expired card",
        1000005 => "Invalid zip code",
        1000006 => "Invalid purchase amount",
        1000007 => "Invalid token",
        1000008 => "Invalid params: cannot specify both token and other credit card params like card_number, cvv, expiration_month, expiration_year or zip.",
      }
      error_message = error_messages[error_code]
      error_message_prefix + error_message
    end
  end
end
