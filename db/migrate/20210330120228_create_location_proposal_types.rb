class CreateLocationProposalTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :location_proposal_types do |t|
      t.references :location, null: false, foreign_key: true
      t.references :proposal_type, null: false, foreign_key: true

      t.timestamps
    end
  end
end
