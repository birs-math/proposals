class MoveCapacityFromLocationsToProposalType < ActiveRecord::Migration[6.1]
  def change
    remove_column :locations, :capacity, :integer
    add_column :proposal_types, :capacity, :integer
  end
end
