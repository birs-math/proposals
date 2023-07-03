class InviteMailer < ApplicationMailer
  def invited_as_text(invite)
    return "a Supporting Organizer for" if invite.humanize_invited_as.downcase.match?('organizer')

    "a Participant in"
  end

  def invite_email
    template = case params[:invited_as].downcase
               when 'organizer'
                 EmailTemplate.organizer_invitation_type.first
               when 'participant'
                 EmailTemplate.participant_invitation_type.first
               else
                 raise ActiveRecord::RecordNotFound
               end

    invite = params[:invite]

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
    template = EmailTemplate.invite_reminder.first

    invite = params[:invite]

    liquid_email(template)

    mail(to: invite.email, subject: @subject)
  end

  private

  def liquid_email(template)
    @context = InviteMailerContext.call(params)
    @subject = template.render(:subject, context: @context)
    @body = template.render(:body, context: @context)
  end
end
