class InviteMailer < ApplicationMailer
  def invite_email
    @invite = params[:invite]

    @proposal = @invite.proposal
    @person = @invite.person

    mail(to: @person.email, subject: "BIRS Proposal: Invite for #{@invite.invited_as?}")
  end

  def invite_acceptance
    @invite = params[:invite]
    @existing_co_organizers = params[:co_organizers]

    @existing_co_organizers.prepend(" and ") if @existing_co_organizers.present?
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
    @existing_co_organizers = params[:co_organizers]

    @existing_co_organizers.prepend(" and ") if @existing_co_organizers.present?
    @proposal = @invite.proposal
    @person = @invite.person

    mail(to: @person.email, subject: "Please Respond – BIRS Proposal: Invite for #{@invite.invited_as?}")
  end
end
