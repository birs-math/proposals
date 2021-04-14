class ProposalLocation < ApplicationRecord
  belongs_to :location
  belongs_to :proposal
end
