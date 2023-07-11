class AddLiquidFlagToEmailTemplates < ActiveRecord::Migration[6.1]
  def change
    add_column :email_templates, :liquid_template, :boolean, default: false
  end
end
