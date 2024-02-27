class Role < ApplicationRecord
  validates :name, presence: true
  enum role_type: { staff_role: 0, applicant_role: 1 }

  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles
  has_many :role_privileges, dependent: :destroy
  has_many :proposal_roles, dependent: :destroy

  accepts_nested_attributes_for :role_privileges, reject_if: :all_blank, allow_destroy: true

  LEAD_ORGANIZER = 'lead_organizer'.freeze

  class << self
    def organizer
      find_or_create_by!(name: LEAD_ORGANIZER)
    end
  end
end
