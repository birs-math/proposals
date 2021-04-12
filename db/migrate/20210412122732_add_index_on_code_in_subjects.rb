class AddIndexOnCodeInSubjects < ActiveRecord::Migration[6.1]
  def change
  	add_index :subjects, :code, unique: true
  end
end
