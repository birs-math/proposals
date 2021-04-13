class SubjectCategory < ApplicationRecord
  validates :name, presence: true
  has_many :subjects
end
