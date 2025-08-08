namespace :birs do
  desc "Expire overdue invitations"
  task expire_invitations: :environment do
    puts "Starting invitation expiration process..."
    
    expired_count = Invite.expire_overdue_invitations.count
    
    if expired_count > 0
      puts "Successfully expired #{expired_count} invitations"
      
      # Group and display expired invitations by proposal
      expired_invitations = Invite.where(status: 'expired').includes(:proposal, :person)
      expired_invitations.group_by(&:proposal).each do |proposal, invitations|
        puts "\nProposal: #{proposal.title} (#{proposal.code})"
        puts "Lead Organizer: #{proposal.lead_organizer&.fullname}"
        
        organizers = invitations.select { |invite| invite.invited_as == 'Organizer' }
        participants = invitations.select { |invite| invite.invited_as == 'Participant' }
        
        if organizers.any?
          puts "  Expired Organizers:"
          organizers.each do |invite|
            puts "    - #{invite.firstname} #{invite.lastname} (#{invite.email})"
          end
        end
        
        if participants.any?
          puts "  Expired Participants:"
          participants.each do |invite|
            puts "    - #{invite.firstname} #{invite.lastname} (#{invite.email})"
          end
        end
      end
    else
      puts "No invitations to expire"
    end
    
    puts "\nExpiration process completed."
  end

  desc "Run the expiration job (same as rake task but via job system)"
  task run_expiration_job: :environment do
    puts "Running ExpireInvitationsJob..."
    ExpireInvitationsJob.perform_now
    puts "Job completed."
  end

  desc "Show pending invitations that will expire soon"
  task show_pending_expirations: :environment do
    puts "Pending invitations that will expire soon:"
    puts "=" * 50
    
    # Show invitations expiring in the next 7 days
    upcoming_expirations = Invite.where(status: 'pending')
                                 .where('deadline_date BETWEEN ? AND ?', 
                                        DateTime.current.beginning_of_day, 
                                        DateTime.current.beginning_of_day + 7.days)
                                 .includes(:proposal, :person)
                                 .order(:deadline_date)
    
    if upcoming_expirations.any?
      upcoming_expirations.group_by(&:proposal).each do |proposal, invitations|
        puts "\nProposal: #{proposal.title} (#{proposal.code})"
        puts "Lead Organizer: #{proposal.lead_organizer&.fullname}"
        
        invitations.each do |invite|
          days_until_expiry = (invite.deadline_date.to_date - Date.current).to_i
          puts "  - #{invite.firstname} #{invite.lastname} (#{invite.email}) - #{invite.invited_as}"
          puts "    Expires in #{days_until_expiry} days (#{invite.deadline_date.strftime('%Y-%m-%d')})"
        end
      end
    else
      puts "No invitations expiring in the next 7 days"
    end
  end
end
