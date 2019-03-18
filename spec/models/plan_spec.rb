require 'rails_helper'

RSpec.describe Plan, type: :model do
  it 'has a valid factory' do
    expect(build(:plan)).to be_valid
  end

  describe 'ActiveModel validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:price) }
  end
end
