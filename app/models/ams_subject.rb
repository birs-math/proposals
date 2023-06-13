class AmsSubject < ApplicationRecord
  include Discard::Model

  validates :title, :code, presence: true
  belongs_to :subject, optional: true
  has_many :proposal_ams_subjects, dependent: :destroy
  has_many :proposals, through: :proposal_ams_subjects
  has_many :ams_subject_categories, dependent: :destroy
  has_many :subject_categories, through: :ams_subject_categories
end
