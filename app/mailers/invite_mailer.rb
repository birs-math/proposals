class InviteMailer < ApplicationMailer
  def invited_as_text(invite)
    return "a Supporting Organizer for" if invite.humanize_invited_as.downcase.match?('organizer')

    "a Participant in"
  end

  def invite_email
    invite = params[:invite]

    template = case invite.invited_as&.downcase
               when 'organizer'
                 EmailTemplate.organizer_invitation_type.first
               when 'participant'
                 EmailTemplate.participant_invitation_type.first
               else
                 raise ActiveRecord::RecordNotFound
               end

    liquid_email(template)

    if params[:lead_organizer_copy].present?
      lead_organizer = invite.proposal.lead_organizer
      mail(to: lead_organizer.email, subject: @subject)
    else
      mail(to: invite.email, subject: @subject)
    end
  end

  def invite_acceptance
    template = EmailTemplate.confirmation_of_interest.first

    invite = params[:invite]

    liquid_email(template)

    mail(to: invite.email, subject: @subject)
  end

  def invite_decline
    @invite = params[:invite]
    @proposal = @invite.proposal
    @person = @invite.person

    mail(to: @person.email, subject: t('invite_mailer.invite_decline.subject'))
  end

  def invite_uncertain
    template = EmailTemplate.invite_uncertain.first

    invite = params[:invite]

    liquid_email(template)

    mail(to: invite.email, subject: @subject)
  end

  def invite_reminder
    invite = params[:invite]
    
    # Set up instance variables for the .erb template
    @invite = invite
    @proposal = invite.proposal
    @person = invite.person
    
    # Create reminder email body (similar to original invitation)
    @subject = "Reminder: Invitation to #{@proposal.title}"
    @body = "Dear #{@person.fullname},\n\n" +
            "This is a reminder that you have been invited to participate #{invited_as_text(invite)} " +
            "#{@proposal.title}.\n\n" +
            "Proposal Code: #{@proposal.code}\n\n" +
            "Please respond to your invitation by visiting: #{invite_url(invite, host: ENV['APPLICATION_HOST'])}\n\n" +
            "Best regards,\nBIRS Team"

    mail(to: invite.email, subject: @subject)
  end

  private

  def liquid_email(template)
    @context = InviteMailerContext.call(params)
    @subject = template.render(:subject, context: @context)
    @body = template.render(:body, context: @context)
  end
end
