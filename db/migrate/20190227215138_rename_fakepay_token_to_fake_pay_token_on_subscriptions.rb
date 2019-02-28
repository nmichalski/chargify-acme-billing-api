class RenameFakepayTokenToFakePayTokenOnSubscriptions < ActiveRecord::Migration[5.2]
  def change
    rename_column :subscriptions, :fakepay_token, :fake_pay_token
  end
end
