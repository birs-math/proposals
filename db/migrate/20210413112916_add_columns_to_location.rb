class AddColumnsToLocation < ActiveRecord::Migration[6.1]
  def change
    change_table :locations do |t|
      t.string :code
      t.string :city
      t.string :country
    end
  end
end
