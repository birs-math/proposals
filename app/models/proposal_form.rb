class ProposalForm < ApplicationRecord
  validates :title, presence: true
  belongs_to :proposal_type
  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'
  has_many(:proposal_fields,
           -> { order(position: :asc) },
           inverse_of: :proposal_form, dependent: :destroy)
  enum status: { draft: 0, active: 1, inactive: 2 }

  scope :active_form, ->(id) { where(proposal_type_id: id, status: :active).order(created_at: :asc).last }
  default_scope { order(created_at: :desc) }

  def highest_field_position
    proposal_fields.maximum(:position).to_i
  end
end
