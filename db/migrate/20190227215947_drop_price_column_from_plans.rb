class DropPriceColumnFromPlans < ActiveRecord::Migration[5.2]
  def change
    remove_column :plans, :price
  end
end
