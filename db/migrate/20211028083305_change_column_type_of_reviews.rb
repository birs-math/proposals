class ChangeColumnTypeOfReviews < ActiveRecord::Migration[6.1]
  def change
    change_column :reviews, :review_date, :string
  end
end
