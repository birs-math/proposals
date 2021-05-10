class ProposalForm < ApplicationRecord
  validates :title, presence: true
  belongs_to :proposal_type
  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'
  has_many :proposal_fields, dependent: :destroy
  enum status: { draft: 0, active: 1 }
end
