class CreateFlights < ActiveRecord::Migration[5.1]
  def change
    create_table :flights do |t|
      t.string :origin
      t.string :destination
      t.numeric :price

      t.timestamps
    end
  end
end
