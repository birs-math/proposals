class Location < ApplicationRecord
  has_many :location_proposal_types, dependent: :destroy
  has_many :proposal_types, through: :location_proposal_types
  has_many :proposals, dependent: :destroy
end
