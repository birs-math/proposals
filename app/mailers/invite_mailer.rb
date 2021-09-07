class InviteMailer < ApplicationMailer
  # rubocop:disable Metrics/AbcSize
  def invite_email
    @invite = params[:invite]
    @lead_organizer = params[:lead_organizer]
    @body = params[:body]
    email_placeholders

    if @cc_emails.present?
      mail(to: @person.email, subject: "BIRS Proposal: Invite for #{@invite.invited_as?}",
           cc: @cc_emails&.split(', ')&.map { |val| val })
    else
      mail(to: @person.email, subject: "BIRS Proposal: Invite for #{@invite.invited_as?}")
    end
  end
  # rubocop:enable Metrics/AbcSize

  def invite_acceptance
    @invite = params[:invite]
    @existing_organizers = params[:organizers]

    @existing_organizers.prepend(", ") if @existing_organizers.present?
    @existing_organizers = @existing_organizers.strip.delete_suffix(",")
    @existing_organizers = @existing_organizers.sub(/.*\K,/, ' and') if @existing_organizers.present?
    @proposal = @invite.proposal
    @person = @invite.person

    mail(to: @person.email, subject: 'BIRS Proposal: RSVP Confirmation')
  end

  def invite_decline
    @invite = params[:invite]
    @proposal = @invite.proposal
    @person = @invite.person

    mail(to: @person.email, subject: 'Invite Declined')
  end

  def invite_reminder
    @invite = params[:invite]
    @existing_organizers = params[:organizers]

    @existing_organizers.prepend(", ") if @existing_organizers.present?
    @existing_organizers = @existing_organizers.sub(/.*\K,/, ' and') if @existing_organizers.present?
    @proposal = @invite.proposal
    @person = @invite.person

    mail(to: @person.email, subject: "Please Respond – BIRS Proposal: Invite for #{@invite.invited_as?}")
  end

  private

  def email_placeholders
    placeholders = { "invited_as" => @invite&.invited_as?&.downcase.to_s,
                     "invite_deadline_date" => @invite&.deadline_date&.to_date.to_s, "123" => @invite&.code.to_s }
    placeholders.each { |k, v| @body.gsub!(k, v) }
    @cc_emails = params[:cc_email]
    @proposal = @invite.proposal
    @person = @invite.person
  end
end
