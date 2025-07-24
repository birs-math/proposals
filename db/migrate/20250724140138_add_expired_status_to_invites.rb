class AddExpiredStatusToInvites < ActiveRecord::Migration[6.1]
  def up
    # No database changes needed - enum is stored as integer
    # New status value 4 will be handled by Rails enum
    
    # Immediately expire old pending invites
    execute <<-SQL
      UPDATE invites 
      SET status = 4 
      WHERE status = 0 
      AND deadline_date < CURRENT_DATE
    SQL
    
    Rails.logger.info "Updated #{Invite.where(status: 4).count} expired invitations"
  end
  
  def down
    # Convert any expired status back to pending
    execute <<-SQL
      UPDATE invites 
      SET status = 0 
      WHERE status = 4
    SQL
    
    Rails.logger.info "Reverted expired invitations back to pending"
  end
end
