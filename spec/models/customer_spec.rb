require 'rails_helper'

RSpec.describe Customer, type: :model do
  it 'has a valid factory' do
    expect(build(:subscription)).to be_valid
  end

  describe 'ActiveModel validations' do
    it { is_expected.to validate_presence_of(:shipping_name) }
    it { is_expected.to validate_presence_of(:shipping_address) }
    it { is_expected.to validate_presence_of(:shipping_zipcode) }
    it { is_expected.to validate_presence_of(:fake_pay_token) }
  end
end
