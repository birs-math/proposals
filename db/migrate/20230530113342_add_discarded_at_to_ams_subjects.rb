class AddDiscardedAtToAmsSubjects < ActiveRecord::Migration[6.1]
  def change
    add_column :ams_subjects, :discarded_at, :datetime
    add_index :ams_subjects, :discarded_at
  end
end
