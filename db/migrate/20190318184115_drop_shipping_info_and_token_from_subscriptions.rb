class DropShippingInfoAndTokenFromSubscriptions < ActiveRecord::Migration[5.2]
  def change
    remove_column :subscriptions, :shipping_name, :string
    remove_column :subscriptions, :shipping_address, :string
    remove_column :subscriptions, :shipping_zipcode, :string
    remove_column :subscriptions, :fake_pay_token, :string
  end
end
