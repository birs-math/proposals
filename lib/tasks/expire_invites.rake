namespace :birs do
  desc "Expire old pending invites"
  task expire_invites: :environment do
    puts "Starting invitation expiration process..."
    
    result = Invites::Expire.call
    expired_count = result[:expired_count]
    
    if expired_count > 0
      puts "Expired #{expired_count} invitations"
    else
      puts "No invitations expired"
    end
    
    puts "Invitation expiration process completed"
  end
end