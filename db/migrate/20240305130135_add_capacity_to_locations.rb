class AddCapacityToLocations < ActiveRecord::Migration[6.1]
  def change
    add_column :locations, :capacity, :integer
  end
end
