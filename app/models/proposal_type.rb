class ProposalType < ApplicationRecord
  has_many :location_proposal_types, dependent: :destroy
  has_many :locations, through: :location_proposal_types
  has_many :forms, class_name: 'ProposalForm', dependent: :destroy
  has_many :proposals, dependent: :destroy
end
