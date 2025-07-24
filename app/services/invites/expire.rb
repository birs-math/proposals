module Invites
  class Expire
    include Callable
    
    def call
      expired_count = 0
      
      expired_invites.find_each do |invite|
        if invite.update(status: :expired)
          expired_count += 1
          log_expiration(invite)
        end
      end
      
      { expired_count: expired_count }
    end
    
    private
    
    def expired_invites
      Invite.pending.where('deadline_date < ?', Time.zone.now)
    end
    
    def log_expiration(invite)
      Rails.logger.info("Expired invitation #{invite.code} for #{invite.email}")
    end
  end
end