class ProposalForm < ApplicationRecord
  belongs_to :proposal_type
  has_many :questions, dependent: :destroy
end
