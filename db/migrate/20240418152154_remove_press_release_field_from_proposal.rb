class RemovePressReleaseFieldFromProposal < ActiveRecord::Migration[6.1]
  def change
    remove_column :proposals, :press_release, :text
  end
end
