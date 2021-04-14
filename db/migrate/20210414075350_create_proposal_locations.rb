class CreateProposalLocations < ActiveRecord::Migration[6.1]
  def change
    create_table :proposal_locations do |t|
      t.references :location, null: false, foreign_key: true
      t.references :proposal, null: false, foreign_key: true

      t.timestamps
    end
  end
end
