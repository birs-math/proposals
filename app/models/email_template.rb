class EmailTemplate < ApplicationRecord
  include BirsLiquid::Markup
  validates :title, :subject, :body, :email_type, presence: true

  enum email_type: {
    revision_type: 0,
    reject_type: 1,
    approval_type: 2,
    decision_email_type: 3,
    organizer_invitation_type: 4,
    participant_invitation_type: 5,
    revision_spc_type: 6,
    invite_reminder: 7,
    confirmation_of_interest: 8,
    invite_uncertain: 9
  }

  def liquid_template?
    liquid_template
  end
end
