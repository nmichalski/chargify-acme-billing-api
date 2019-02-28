class AddPriceColumnToPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :price, :integer
  end
end
