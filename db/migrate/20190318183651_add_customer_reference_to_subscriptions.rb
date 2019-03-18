class AddCustomerReferenceToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_reference :subscriptions, :customer, index: true
  end
end
