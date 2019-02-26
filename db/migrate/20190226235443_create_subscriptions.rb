class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.string :shipping_name
      t.string :shipping_address
      t.string :shipping_zipcode
      t.string :fakepay_token
      t.references :plan, foreign_key: true

      t.timestamps
    end
  end
end
