class InvitationExpirationMailer < ApplicationMailer
  def expiration_notification
    @proposal = params[:proposal]
    @expired_invitations = params[:expired_invitations]
    @lead_organizer = params[:lead_organizer]
    
    @expired_organizers = @expired_invitations.select { |invite| invite.invited_as == 'Organizer' }
    @expired_participants = @expired_invitations.select { |invite| invite.invited_as == 'Participant' }
    
    @available_organizer_slots = @proposal.max_supporting_organizers - @proposal.supporting_organizer_invites.count
    @available_participant_slots = @proposal.max_participants - @proposal.participant_invites.count
    
    mail(
      to: @lead_organizer.email,
      subject: "Invitations Expired - #{@proposal.title}"
    )
  end
end
