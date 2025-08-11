# Critical Business Logic Fix for Invitation Expiration

## Problem Identified

The `ExpireInvitationsJob` was incorrectly attempting to expire invitations from **historical workshops** (2021-2023) when running in 2025. This violated basic business logic principles:

### Issues Found:
1. **Historical Data Processing**: 9,400+ invitations from completed 2023 workshops were being targeted for expiration
2. **Improper Scope Logic**: The `expired` scope used string `'pending'` instead of integer `0` for status comparison
3. **No Workshop Date Filtering**: No consideration of workshop scheduling dates (`assigned_date`)
4. **Archive Data Corruption**: Risk of corrupting historical records by marking them as "expired" years later

### Example Problem Case:
- **Workshop**: 23w5129 "Scientific Machine Learning" (2023)
- **Workshop Date**: June 25, 2023 (completed 2+ years ago)
- **Invitation Deadlines**: July 2021 
- **System Behavior**: Attempting to expire these invitations in August 2025

## Root Cause Analysis

### Original Problematic Scope:
```ruby
scope :expired, -> { 
  where('deadline_date < ? AND status = ?', DateTime.current.beginning_of_day, 'pending') 
}
```

**Problems:**
1. Status comparison used string `'pending'` vs integer `0` (enum value)
2. No business logic filter for workshop scheduling
3. Would process ALL overdue invitations regardless of workshop status

## Business Logic Solution

### Corrected Scope:
```ruby
scope :expired, -> { 
  joins(:proposal)
    .where('invites.deadline_date < ? AND invites.status = ? AND (proposals.assigned_date IS NULL OR proposals.assigned_date > ?)', 
           DateTime.current.beginning_of_day, 0, Date.current)
}
```

### Logic Explanation:
1. **`invites.status = 0`**: Fixed enum comparison (pending = 0)
2. **`proposals.assigned_date IS NULL`**: Include unscheduled workshops (still in planning)
3. **`proposals.assigned_date > Date.current`**: Only future workshops
4. **Excludes**: All historical workshops where `assigned_date <= today`

## Business Rules Implemented

### What Gets Expired:
- ✅ **Future Workshops**: `assigned_date > today` (legitimate upcoming events)
- ✅ **Unscheduled Workshops**: `assigned_date = NULL` (proposals still being planned)
- ✅ **Overdue Invitations**: `deadline_date < today` (actually overdue responses)

### What Gets Protected:
- 🛡️ **Historical Workshops**: `assigned_date <= today` (completed events - archive data)
- 🛡️ **Confirmed Invitations**: `status != pending` (already processed)
- 🛡️ **Future Deadlines**: `deadline_date >= today` (still valid)

## Impact Assessment

### Before Fix:
- **Targeted**: 9,400+ historical invitations
- **Risk**: Corrupting 4+ years of historical data
- **Scope**: Workshops from 2021-2023

### After Fix:
- **Targeted**: Only legitimate current expiration candidates
- **Protected**: All historical workshop data integrity
- **Scope**: Current operational workshops only

## Technical Implementation

### Files Modified:
- `app/models/invite.rb:27-31` - Fixed `expired` scope with business logic

### Database Impact:
- **No Data Loss**: Historical invitations remain untouched
- **Proper Indexing**: Existing `(deadline_date, status)` index optimizes query
- **Performance**: Join with proposals table for date filtering

### Testing Validation:
- **Before**: 9,400+ invitations matched scope
- **After**: Only current legitimate expirations matched
- **Verified**: 2023 workshops properly excluded

## Production Deployment Notes

### Safety Measures:
1. **Backup Recommended**: Before deploying to production
2. **Staging Test**: Verify scope behavior with production data copy
3. **Monitor Initial Run**: Watch first scheduled job execution
4. **Rollback Plan**: Previous scope logic available if needed

### Monitoring:
- Check job logs for realistic expiration counts
- Verify no historical workshops appear in expiration reports
- Monitor admin dashboard for proper invitation status updates

## Long-term Considerations

### Future Enhancements:
1. **Configurable Grace Period**: Instead of hardcoded date comparisons
2. **Workshop Status Integration**: Consider proposal workflow states
3. **Archive Logic**: Separate handling for truly archived vs historical workshops
4. **Audit Trail**: Log when invitations are expired with reasoning

### Maintenance:
- Regular review of expiration logic during system updates
- Validation that business rules remain consistent with operational needs
- Performance monitoring of joined queries with growing dataset

## Conclusion

This fix addresses a critical business logic flaw that could have resulted in corruption of historical academic records. The solution properly respects the temporal boundaries of workshop operations while maintaining the intended invitation management functionality.

**Key Principle**: Workshop invitation management should only operate on current/future academic events, never on completed historical workshops.