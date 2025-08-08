class ExpireInvitationsJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting ExpireInvitationsJob at #{DateTime.current}"
    
    expired_invitations = Invite.expire_overdue_invitations
    
    if expired_invitations.any?
      Rails.logger.info "Expired #{expired_invitations.count} invitations"
    else
      Rails.logger.info "No invitations to expire"
    end
    
    Rails.logger.info "Completed ExpireInvitationsJob at #{DateTime.current}"
  end
end
