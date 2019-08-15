class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions do |t|
      t.numeric :total_price
      t.string :transaction_token
      t.references :flight, foreign_key: true

      t.timestamps
    end
  end
end
