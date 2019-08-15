class ChangeTotalPriceToBeIntegerInTransactions < ActiveRecord::Migration[5.1]
  def up
    change_column :transactions, :total_price, :integer
    change_column :flights, :price, :integer
  end

  def down
    change_column :transactions, :total_price, :numeric
    change_column :flights, :price, :numeric
  end 
end
