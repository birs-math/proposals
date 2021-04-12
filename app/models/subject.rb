class Subject < ApplicationRecord
  validates :code, uniqueness: true

  belongs_to :subject_category
  has_many :ams_subjects
end
