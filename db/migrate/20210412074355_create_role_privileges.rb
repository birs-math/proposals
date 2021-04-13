class CreateRolePrivileges < ActiveRecord::Migration[6.1]
  def change
    create_table :role_privileges do |t|
      t.references :role, null: false, foreign_key: true
      t.string :privilege_name
      t.string :permission_type

      t.timestamps
    end
  end
end
