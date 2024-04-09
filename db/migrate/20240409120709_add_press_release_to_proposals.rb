class AddPressReleaseToProposals < ActiveRecord::Migration[6.1]
  def change
    add_column :proposals, :press_release, :text
  end
end
