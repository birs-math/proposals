class CreateLatexToPdfLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :latex_to_pdf_logs, id: :uuid do |t|
      t.text :log
      t.string :file_name
      t.string :mime_type
      t.timestamps
    end
  end
end
