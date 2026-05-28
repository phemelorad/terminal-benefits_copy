# Brought Forward Counter Feature

## Summary
Added a "Brought Forward" counter to the home dashboard that tracks entries from previous months that are still pending or in-progress and carried over to the current month.

## What is "Brought Forward"?

Brought Forward entries are applications that:
1. **Were submitted in previous months** (before the current month)
2. **Are still pending/in-progress** (not yet completed or paid)

These are typically:
- Applications submitted close to month-end that couldn't be completed in time
- Applications with delays or pending documentation
- Applications awaiting approval or payment

## Implementation Details

### 1. New Function: `getBroughtForwardApps()`
```javascript
function getBroughtForwardApps() {
  const now = new Date();
  const currentMonthKey = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
  
  // Entries from previous months that are still pending/in-progress
  return allApps.filter(a => {
    const submittedMonth = a.submitted_at?.substring(0, 7);
    // Must be from a previous month
    if (!submittedMonth || submittedMonth >= currentMonthKey) return false;
    
    // Must be pending or in-progress (not completed/paid)
    const status = a.status?.toLowerCase() || '';
    const isPending = status === 'pending' || 
                      status === 'in progress' || 
                      status === 'submitted' ||
                      status === 'under review' ||
                      !a.actual_date_paid; // No payment date means still pending
    
    return isPending;
  });
}
```

### 2. New Stat Card
Added a new stat card between "Total Applications" and "Compliant":
- **Icon**: 📥 (inbox with arrow)
- **Label**: "Brought Forward"
- **Color**: Blue (#2563eb)
- **Sub-label**: "From previous months"
- **Value**: Count of brought forward entries

### 3. Updated Layout
- Changed stats row from 4 cards to 5 cards
- Updated grid layout: `grid-template-columns: repeat(5, 1fr)`
- Added responsive breakpoints:
  - Desktop (>1100px): 5 cards in a row
  - Tablet (900-1100px): 3 cards per row
  - Mobile tablet (600-900px): 2 cards per row
  - Mobile phone (<600px): 1 card per row

### 4. Updated `renderStats()` Function
- Calls `getBroughtForwardApps()` to get the count
- Updates the `#s-brought-forward` element with the count

## Visual Design

**Card Appearance:**
- Border-top: 3px solid blue (#2563eb)
- Value color: Blue (#2563eb)
- Icon: 📥 (inbox with downward arrow)
- Matches the design pattern of other stat cards

**Card Order:**
1. Total Applications (Gold)
2. **Brought Forward (Blue)** ← NEW
3. Compliant (Green)
4. Non-Compliant (Red)
5. Pending/In Progress (Blue-gray)

## Business Logic

### What Counts as "Brought Forward"?

An entry is brought forward if:
- `submitted_at` is from a previous month (e.g., April when current month is May)
- AND one of the following is true:
  - `status` is "Pending"
  - `status` is "In Progress"
  - `status` is "Submitted"
  - `status` is "Under Review"
  - `actual_date_paid` is null/empty (no payment made yet)

### What Does NOT Count?

Entries are NOT brought forward if:
- They were submitted in the current month
- They have been completed/paid (have an `actual_date_paid`)
- They have a final status like "Paid", "Completed", "Rejected"

## Use Cases

### Monthly Reporting
- Shows workload carried over from previous months
- Helps identify bottlenecks and delays
- Tracks month-end submissions that spill over

### Performance Tracking
- High brought forward count may indicate:
  - Processing delays
  - Month-end rush submissions
  - Pending documentation issues
  - Approval bottlenecks

### Workload Management
- Helps managers understand current month workload
- Distinguishes between new submissions and carried-over work
- Enables better resource allocation

## Example Scenarios

### Scenario 1: Month-End Submission
- Application submitted on April 28th
- Still pending on May 1st
- **Result**: Counted as "Brought Forward" in May

### Scenario 2: Delayed Processing
- Application submitted on March 15th
- Awaiting documentation in April
- Still pending on May 1st
- **Result**: Counted as "Brought Forward" in May

### Scenario 3: Completed Application
- Application submitted on April 20th
- Paid on April 30th
- **Result**: NOT counted as brought forward (completed)

### Scenario 4: Current Month Submission
- Application submitted on May 5th
- Still pending on May 10th
- **Result**: NOT brought forward (current month submission, counted in "Pending")

## Testing Recommendations

1. **Test with no brought forward entries**: Verify shows "0"
2. **Test with pending entries from last month**: Verify they appear in count
3. **Test with paid entries from last month**: Verify they DON'T appear in count
4. **Test at month boundary**: Verify correct calculation on first day of new month
5. **Test responsive layout**: Verify cards display correctly on mobile/tablet/desktop
6. **Test with multiple months**: Verify entries from 2+ months ago are counted

## Future Enhancements (Optional)

1. **Breakdown by Month**: Show how many from last month, 2 months ago, etc.
2. **Aging Report**: Show average age of brought forward entries
3. **Click-through**: Make card clickable to show list of brought forward entries
4. **Alert Threshold**: Highlight if brought forward count exceeds a threshold
5. **Trend Chart**: Show brought forward trend over time
