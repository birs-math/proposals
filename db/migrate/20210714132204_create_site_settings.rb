class CreateSiteSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :site_settings do |t|
      t.text :guideline
      t.timestamps
    end
  end
end
