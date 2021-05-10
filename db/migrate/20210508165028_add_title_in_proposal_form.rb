class AddTitleInProposalForm < ActiveRecord::Migration[6.1]
  def change
  	add_column :proposal_forms, :title, :string
  end
end
