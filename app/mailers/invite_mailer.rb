class InviteMailer < ApplicationMailer
  def invited_as_text(invite)
    return "a Supporting Organizer for" if invite.humanize_invited_as.downcase.match?('organizer')

    "a Participant in"
  end

  def invite_email
    @invite = params[:invite]
    @body = params[:body]
    replace_email_placeholders

    if params[:lead_organizer].present?
      @lead_organizer = params[:lead_organizer]
      mail(to: @lead_organizer.email, subject: "BIRS Proposal Invitation for #{@invite.humanize_invited_as}")
    else
      mail(to: @person.email, subject: "BIRS Proposal Invitation for #{@invite.humanize_invited_as}")
    end
  end

  def invite_acceptance
    template = EmailTemplate.find_by(email_type: :confirmation_of_interest)

    invite = params[:invite]
    proposal = invite.proposal
    supporting_organizers = params[:organizers]

    supporting_organizers = ", #{supporting_organizers.sub(/.*\K,/, ' and')}" if supporting_organizers.present?

    @context = {
      person_name: invite.person&.fullname,
      invited_role: invite.humanize_invited_as,
      proposal_title: proposal.title,
      organizers: "#{proposal.lead_organizer&.fullname}#{supporting_organizers}",
    }

    subject = template.render(:subject, context: @context)
    @body = template.render(:body, context: @context)

    mail(to: invite.email, subject: subject)
  end

  def invite_decline
    @invite = params[:invite]
    @proposal = @invite.proposal
    @person = @invite.person

    mail(to: @person.email, subject: t('invite_mailer.invite_decline.subject'))
  end

  def invite_uncertain
    template = EmailTemplate.find_by(email_type: :invite_uncertain)

    invite = params[:invite]
    proposal = invite.proposal

    @context = {
      person_name: invite.person&.fullname,
      proposal_title: proposal.title,
      lead_organizer: proposal.lead_organizer&.fullname
    }

    subject = template.render(:subject, context: @context)
    @body = template.render(:body, context: @context)

    mail(to: invite.email, subject: subject)
  end

  def invite_reminder
    template = EmailTemplate.find_by(email_type: :invite_reminder)

    invite = params[:invite]
    proposal = invite.proposal
    supporting_organizers = params[:organizers]

    supporting_organizers = ", #{supporting_organizers.sub(/.*\K,/, ' and')}" if supporting_organizers.present?

    @context = {
      person_name: invite.person&.fullname,
      invited_as: invited_as_text(invite),
      proposal_type: proposal.proposal_type.name,
      proposal_title: proposal.title,
      organizers: "#{proposal.lead_organizer&.fullname}#{supporting_organizers}",
      deadline_date: invite.deadline_date&.to_date,
      invite_url: invite_url(code: invite.code),
      invited_role: invite.humanize_invited_as
    }

    subject = template.render(:subject, context: @context)
    @body = template.render(:body, context: @context)

    mail(to: invite.email, subject: subject)
  end

  private

  def invite_link(invite)
    code = params[:lead_organizer].present? ? '123...' : invite&.code
    url = invite_url(code: code)
    "<a href='#{url}'>#{url}</a>"
  end

  def replace_email_placeholders
    @email_body = String.new(@body)
    placeholders = { "invite_deadline_date" => @invite&.deadline_date&.to_date.to_s,
                     "invite_url" => invite_link(@invite),
                     "invited_as" => invited_as_text(@invite) }
    placeholders.each { |k, v| @email_body.gsub!(k, v) }
    @proposal = @invite.proposal
    @person = @invite.person
  end
end
