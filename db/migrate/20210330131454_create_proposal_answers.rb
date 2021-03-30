class CreateProposalAnswers < ActiveRecord::Migration[6.1]
  def change
    create_table :proposal_answers do |t|
      t.references :proposal, null: false, foreign_key: true

      t.timestamps
    end
  end
end
