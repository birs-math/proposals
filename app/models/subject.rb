class Subject < ApplicationRecord
  validates :code, uniqueness: true
  validates :title, :code, presence: true

  belongs_to :subject_category
  has_many :ams_subjects
end
