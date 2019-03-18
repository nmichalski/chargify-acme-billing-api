class CreateCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :customers do |t|
      t.string :shipping_name
      t.string :shipping_address
      t.string :shipping_zipcode
      t.string :fake_pay_token

      t.timestamps
    end
  end
end
