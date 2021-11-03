class EmailTemplate < ApplicationRecord
  validates :title, :subject, :body, :email_type, presence: true

  enum email_type: { revision_round_1_type: 0, reject_type: 1, approval_type: 2, decision_email_type: 3,
                     organizer_invitation_type: 4, participant_invitation_type: 5,
                     revision_round_2_type: 6 }
end
