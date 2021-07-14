class AddIndexOnEmailInPeople < ActiveRecord::Migration[6.1]
  def change
    add_index :people, :email, unique: true
  end
end
