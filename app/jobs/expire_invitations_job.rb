class ExpireInvitationsJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting ExpireInvitationsJob at #{DateTime.current}"
    
    expired_invitations = Invite.expire_overdue_invitations
    
    if expired_invitations.any?
      Rails.logger.info "Expired #{expired_invitations.count} invitations"
      
      # Group expired invitations by proposal for efficient notification
      expired_invitations.group_by(&:proposal).each do |proposal, invitations|
        notify_lead_organizer(proposal, invitations)
      end
    else
      Rails.logger.info "No invitations to expire"
    end
    
    Rails.logger.info "Completed ExpireInvitationsJob at #{DateTime.current}"
  end

  private

  def notify_lead_organizer(proposal, expired_invitations)
    return unless proposal&.lead_organizer&.email

    InvitationExpirationMailer.with(
      proposal: proposal,
      expired_invitations: expired_invitations,
      lead_organizer: proposal.lead_organizer
    ).expiration_notification.deliver_later
  rescue => e
    Rails.logger.error "Failed to send expiration notification for proposal #{proposal&.id}: #{e.message}"
  end
end
