class CreateProposalFieldsSingleChoices < ActiveRecord::Migration[6.1]
  def change
    create_table :proposal_fields_single_choices do |t|
      t.string :statement

      t.timestamps
    end
  end
end
