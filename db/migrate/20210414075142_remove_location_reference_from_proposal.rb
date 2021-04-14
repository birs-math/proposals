class RemoveLocationReferenceFromProposal < ActiveRecord::Migration[6.1]
  def change
  	remove_reference :proposals, :location, index: true, foreign_key: true
  end
end
