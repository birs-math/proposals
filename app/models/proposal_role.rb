class ProposalRole < ApplicationRecord
  belongs_to :proposal
  belongs_to :role
  belongs_to :person

  scope :lead_organizer, -> { joins(:role).where(roles: { name: 'lead_organizer' }) }
end
