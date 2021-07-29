class ProposalMailer < ApplicationMailer
  def proposal_submission
    proposal = params[:proposal]
    proposal_pdf = params[:file]
    email = proposal.lead_organizer.email
    @organizer = proposal.lead_organizer.fullname
    @year = proposal.year
    @code = proposal.code

    attachments["#{proposal.code}-proposal.pdf"] = proposal_pdf

    mail(to: email, subject: "BIRS Proposal #{proposal.code}: #{proposal.title}")
  end

  def staff_send_emails
    @email_data = params[:email_data]
    email = params[:email]
    @organizer = params[:organizer]
    mail(to: email, subject: @email_data.subject)
  end
end
