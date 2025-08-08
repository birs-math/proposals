class AddExpiredAtToInvites < ActiveRecord::Migration[6.1]
  def change
    add_column :invites, :expired_at, :datetime
    add_index :invites, [:deadline_date, :status], name: 'index_invites_on_deadline_date_and_status'
  end
end
