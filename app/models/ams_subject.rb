class AmsSubject < ApplicationRecord
  validates :title, :code, presence: true
  belongs_to :subject
end
