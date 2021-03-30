class Proposal < ApplicationRecord
  belongs_to :location
  belongs_to :proposal_type
  has_one :proposal_answer
end
