# Configure scheduled jobs for the application
# This runs the invitation expiration job daily at 2 AM

if Rails.env.production? || Rails.env.staging?
  # In production/staging, we'll use a proper scheduler like cron or Heroku Scheduler
  # For now, we'll just log that the job should be scheduled
  Rails.logger.info "ExpireInvitationsJob should be scheduled to run daily at 2 AM"
  
  # Example cron job (add to your server's crontab):
  # 0 2 * * * cd /path/to/app && RAILS_ENV=production bin/rails runner "ExpireInvitationsJob.perform_now"
else
  # In development, we can run the job manually or set up a simple scheduler
  Rails.logger.info "ExpireInvitationsJob available for manual execution in development"
end

# Alternative: Use a gem like whenever or sidekiq-scheduler for more sophisticated scheduling
# For now, we'll rely on external schedulers (cron, Heroku Scheduler, etc.)
