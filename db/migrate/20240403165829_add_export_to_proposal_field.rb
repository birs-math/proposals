class AddExportToProposalField < ActiveRecord::Migration[6.1]
  def change
    add_column :proposal_fields, :export, :boolean, default: false, null: false
  end
end
