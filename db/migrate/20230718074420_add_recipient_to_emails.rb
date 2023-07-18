class AddRecipientToEmails < ActiveRecord::Migration[6.1]

  def change
    add_column :emails, :recipient, :string
  end
end
