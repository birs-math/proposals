# Automatic Invitation Expiration System

## Overview

This system automatically expires invitations that have passed their deadline, freeing up workshop capacity and improving the admin experience by eliminating the need for manual cancellation.

## Features

### Automatic Expiration
- **Daily Job**: `ExpireInvitationsJob` runs automatically to expire overdue invitations
- **Smart Detection**: Only expires pending invitations past their deadline
- **Status Management**: Updates invitation status to 'expired' and records expiration timestamp
- **Capacity Management**: Expired invitations don't count against workshop capacity limits

### Admin Notifications
- **Email Alerts**: Lead organizers receive detailed notifications when invitations expire
- **Summary Reports**: Shows expired invitations by type (organizers vs participants)
- **Capacity Updates**: Displays available spots after expiration

### Admin Interface
- **New Tab**: "Expired Invitations" tab in the admin dashboard
- **Detailed View**: Shows all expired invitations with proposal and person details
- **Quick Actions**: Links to view proposals and resend invitations
- **Summary Statistics**: Count of expired invitations and affected proposals

## Technical Implementation

### Database Changes
- Added `expired_at` timestamp column to `invites` table
- Added index on `deadline_date` and `status` for efficient querying
- Added `expired: 4` status to invitation enum

### Models
- **Invite Model**: Added expiration logic and scopes
- **Proposal Model**: Updated capacity calculations to exclude expired invitations
- **Helpers**: Updated `confirmed_participants` to exclude expired invitations

### Jobs
- **ExpireInvitationsJob**: Main job that expires overdue invitations and sends notifications
- **InvitationExpirationMailer**: Handles email notifications to lead organizers

### Admin Interface
- **New Route**: `/submitted_proposals/expired_invitations`
- **New Controller Action**: `expired_invitations` in `SubmittedProposalsController`
- **New View**: `expired_invitations.turbo_stream.erb`

## Usage

### Manual Execution
```bash
# Run expiration job manually
bin/rails runner "ExpireInvitationsJob.perform_now"

# Or use the rake task
bin/rails birs:expire_invitations

# Show pending invitations that will expire soon
bin/rails birs:show_pending_expirations
```

### Scheduled Execution
For production, set up a cron job or use your hosting platform's scheduler:

```bash
# Cron job example (runs daily at 2 AM)
0 2 * * * cd /path/to/app && RAILS_ENV=production bin/rails runner "ExpireInvitationsJob.perform_now"
```

### Heroku Scheduler
Add to your Heroku app:
```bash
bin/rails runner "ExpireInvitationsJob.perform_now"
```

## Configuration

### Environment Variables
No additional environment variables required. The system uses existing email configuration.

### Customization
- **Expiration Period**: Modify the `deadline_date` logic in the Invite model
- **Notification Content**: Edit email templates in `app/views/invitation_expiration_mailer/`
- **Job Frequency**: Change the scheduled job timing in your scheduler

## Testing

### Unit Tests
- `spec/models/invite_spec.rb`: Tests for expiration logic
- `spec/jobs/expire_invitations_job_spec.rb`: Tests for the job
- `spec/mailers/invitation_expiration_mailer_spec.rb`: Tests for email notifications

### Manual Testing
```bash
# Create test invitations with past deadlines
bin/rails console
invite = Invite.last
invite.update!(deadline_date: 1.day.ago, status: 'pending')

# Run expiration
bin/rails runner "ExpireInvitationsJob.perform_now"

# Check results
Invite.where(status: 'expired')
```

## Benefits

1. **Improved Admin Experience**: No more manual cancellation of expired invitations
2. **Automatic Capacity Management**: Spots free up automatically when invitations expire
3. **Better Visibility**: Clear view of expired invitations and available capacity
4. **Reduced Manual Work**: Automated process reduces admin overhead
5. **Better Analytics**: Track invitation response patterns and timing

## Migration Notes

### Database Migration
Run the migration to add the `expired_at` column:
```bash
bin/rails db:migrate
```

### Existing Data
- Existing invitations are not affected
- Only new expirations will be tracked with the `expired_at` timestamp
- The system works with existing invitation data

## Troubleshooting

### Common Issues

1. **Job Not Running**: Check your scheduler configuration
2. **Emails Not Sending**: Verify email configuration in your environment
3. **Capacity Not Updating**: Ensure the `confirmed_participants` helper excludes expired invitations

### Debugging
```bash
# Check for expired invitations
bin/rails console
Invite.where(status: 'expired').count

# Check job logs
tail -f log/development.log | grep ExpireInvitationsJob
```

## Future Enhancements

1. **Configurable Expiration Periods**: Different deadlines for different invitation types
2. **Grace Periods**: Allow extensions before automatic expiration
3. **Bulk Actions**: Admin tools for bulk invitation management
4. **Advanced Analytics**: Detailed reporting on invitation patterns
5. **Integration**: Connect with external calendar systems for deadline management
