class Faq < ApplicationRecord
  validates :question, :answer, presence: true
  has_rich_text :answer
  acts_as_list
  default_scope { order(position: :asc) }
end
