class Review < ApplicationRecord
  belongs_to :person
  belongs_to :proposal
  # isQuick is ture means it's EDI review otherwise scientific
  has_many_attached :files
end
