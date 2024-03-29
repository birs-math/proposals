class ProposalMailer < ApplicationMailer
  def proposal_submission
    @proposal = params[:proposal]
    proposal_pdf = params[:file]
    email = @proposal.lead_organizer.email
    @organizer = @proposal.lead_organizer.fullname

    attachments["#{@proposal.code}-proposal.pdf"] = proposal_pdf

    proposal_mail(email)
  end

  def staff_send_emails
    @email = params[:email_data]
    @recipient_name = @email.recipient_fullname_or_email

    preview_placeholders if @email.proposal.decision_email_sent?

    mail_attachments

    mail(**@email.to_action_mailer_hash)
  end

  # TODO: we don't need two similar methods
  def new_staff_send_emails
    @email = params[:email_data]
    preview_placeholders if @email.proposal.decision_email_sent?
    @organizer = params[:organizer]
    mail_attachments

    mail(**@email.to_action_mailer_hash.merge(to: params[:email]))
  end

  private

  def proposal_mail(email)
    if @proposal.submitted?
      mail(to: email, subject: "BIRS Proposal #{@proposal.code}: #{@proposal.title}",
           cc: @proposal.birs_emails)
    else
      mail(to: email, subject: "BIRS Proposal #{@proposal.code}: #{@proposal.title}")
    end
  end

  def mail_attachments
    return unless @email.files.attached?

    @email.files.each do |file|
      attachments[file.blob.filename.to_s] = {
        mime_type: file.blob.content_type,
        content: file.blob.download
      }
    end
  end

  def preview_placeholders
    return if @email.proposal&.code.blank?

    subject_placeholder
    body_placeholders
  end

  def subject_placeholder
    template_subject = @email&.subject
    return if template_subject.blank?

    placeholder = { "[PROPOSAL NUMBER]" => @email.proposal&.code }
    placeholder.each { |k, v| template_subject.gsub!(k, v) }
  end

  def body_placeholders
    @template_body = @email&.body
    return if @template_body.blank?

    placing_holders
  end

  def placing_holders
    placeholders = { "[WORKSHOP CODE]" => @email.proposal&.code,
                     "[WORKSHOP TITLE]" => @email.proposal&.title,
                     "[WORKSHOP ASSIGNED_LOCATION]" => @email.proposal&.assigned_location&.name.to_s,
                     "[WORKSHOP LEAD_ORGANIZER_NAME]" => "#{@email.proposal.lead_organizer.firstname}
                      #{@email.proposal.lead_organizer.lastname}",
                     "[WORKSHOP LEAD_ORGANIZER_EMAIL]" => @email.proposal.lead_organizer.email,
                     "[WORKSHOP SUPPORTING_ORGANIZER_NAME]" => @email.proposal.invites.where(invited_as: "Organizer")
                                                                     .map do |p|
                                                                 "#{p.firstname} #{p.lastname}"
                                                               end.join(', '),
                     "[WORKSHOP SUPPORTING_ORGANIZER_EMAIL]" => @email.cc_email,
                     "[INSERT ASSIGNED DATES]" => workshop_date_range(@email.proposal&.assigned_date),
                     "[INSERT APPLIED DATES]" => workshop_date_range(@email.proposal&.applied_date) }
    placeholders.each { |k, v| @template_body.gsub!(k, v) }
  end

  def workshop_date_range(date)
    date ? "#{date} to #{date + 5.days}" : ''
  end
end
