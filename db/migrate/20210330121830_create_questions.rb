class CreateQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :questions do |t|
      t.string :type
      t.string :statement
      t.references :proposal_form, null: false, foreign_key: true

      t.timestamps
    end
  end
end
