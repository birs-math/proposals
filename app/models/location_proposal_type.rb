class LocationProposalType < ApplicationRecord
  belongs_to :location
  belongs_to :proposal_type
end
