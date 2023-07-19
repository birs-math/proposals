class Email < ApplicationRecord
  validates :subject, :body, presence: true
  belongs_to :proposal

  before_create :unwrap_cc_emails

  has_many_attached :files

  def update_status(proposal, status)
    case status
    when 'Revision'
      if proposal.may_requested?
        proposal.requested!
        update_version
        return true
      end
    when 'Revision SPC'
      if proposal.may_requested_spc?
        proposal.requested_spc!
        update_version
        return true
      end
    when 'Reject'
      if proposal.may_decision?
        proposal.decision!
        proposal.update(outcome: 'Rejected')
        return true
      end
    when 'Approval'
      if proposal.may_decision?
        proposal.decision!
        proposal.update(outcome: 'Approved')
        return true
      end
    when 'Decision'
      if proposal.may_decision?
        proposal.decision!
        return true
      end
    end
    false
  end

  def send_email
    ProposalMailer.with(email_data: self).staff_send_emails.deliver_now
  end

  def email_organizers(organizers_email = nil)
    proposal_mailer(proposal.lead_organizer.email, proposal.lead_organizer.fullname)

    @organizers_email = organizers_email
    send_organizers_email if @organizers_email.present?
  end

  def to_action_mailer_hash
    {
      to: to_email,
      subject: subject,
      cc: string_to_a(cc_email),
      bcc: string_to_a(bcc_email)
    }
  end

  def to_email
    recipient || proposal.lead_organizer.email
  end

  def recipient_fullname_or_email
    Person.find_by(email: to_email)&.fullname || to_email
  end

  def string_to_a(emails_string)
    emails_string&.split(',')&.map(&:squish) || []
  end

  private

  def unwrap_cc_emails
    self.cc_email = json_to_a(cc_email).join(', ')
  end

  def proposal_mailer(email_address, organizer_name)
    ProposalMailer.with(email_data: self, email: email_address,
                        organizer: organizer_name)
                  .new_staff_send_emails.deliver_now
  end

  def send_organizers_email
    @organizers_email&.each do |email|
      next if email.nil?

      organizer = Invite.find_by(email: email)
      next if organizer.nil?

      proposal_mailer(organizer.email, organizer.person.fullname)
    end
  end

  def update_version
    version = proposal.answers.maximum(:version).to_i
    answers = Answer.where(proposal_id: proposal.id, version: version)
    answers.each do |answer|
      answer = answer.dup
      answer.save
      version = answer.version + 1
      answer.update(version: version)
    end
  end

  # SubmittedProposalsController#approve_decline_proposals and SubmittedProposalsController#send_emails
  # return email#cc_email in form of json and just string, so we try unwrap it before cc_email hits db
  def json_to_a(emails_string)
    return [] if emails_string.blank?

    JSON.parse(emails_string).map(&:values).flatten
  rescue JSON::ParserError, TypeError
    string_to_a(emails_string)
  end
end
