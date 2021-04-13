class Location < ApplicationRecord
  validates :name, :city, :country, :code, presence: true
  has_many :proposal_type_locations, dependent: :destroy
  has_many :proposal_types, through: :proposal_type_locations
  has_many :proposals
  has_many :proposal_fields
end
