# Status Page Stats - Current Month Update

## Overview
Updated the stats cards in status.html to show current month data instead of all-time data, matching the behavior of the home dashboard.

## Changes Made

### 1. Updated `updateStats()` Function
Changed from showing all-time statistics to current month statistics:

**Before:**
```javascript
function updateStats() {
  document.getElementById('s-total').textContent = allRows.length;
  document.getElementById('s-pending').textContent = allRows.filter(r=>r.status==='Pending').length;
  // ... etc
}
```

**After:**
```javascript
function updateStats() {
  // Get current month data
  const now = new Date();
  const currentMonthKey = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
  const currentMonthRows = allRows.filter(r => r.submitted_at?.substring(0, 7) === currentMonthKey);
  
  // Update stats with current month data
  document.getElementById('s-total').textContent = currentMonthRows.length;
  document.getElementById('s-pending').textContent = currentMonthRows.filter(r=>r.status==='Pending').length;
  // ... etc
}
```

### 2. Updated Sub-Label
Changed the "Total" card sub-label from "all time" to show the actual current month:

**Before:**
```html
<div class="stat-sub">all time</div>
```

**After:**
```html
<div class="stat-sub" id="s-total-sub">current month</div>
```

And dynamically updated with actual month name:
```javascript
const monthName = now.toLocaleDateString('en-BW', { month: 'long', year: 'numeric' });
document.getElementById('s-total-sub').textContent = monthName;
// Shows: "May 2026"
```

## Stats Cards Display

### Card 1: Total
- **Label**: Total
- **Value**: Count of current month entries
- **Sub-label**: "May 2026" (current month name)

### Card 2: Pending
- **Label**: Pending
- **Value**: Count of current month pending entries
- **Sub-label**: "incomplete form"

### Card 3: Awaiting Approval
- **Label**: Awaiting Approval
- **Value**: Count of current month awaiting approval entries
- **Sub-label**: "actual date filled"

### Card 4: Paid
- **Label**: Paid
- **Value**: Count of current month paid entries
- **Sub-label**: "confirmed by admin"

### Card 5: Avg. Processing
- **Label**: Avg. Processing
- **Value**: Average TPT for current month entries
- **Sub-label**: "days"

## Calculation Logic

### Current Month Filter
```javascript
const now = new Date();
const currentMonthKey = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
// Example: "2026-05"

const currentMonthRows = allRows.filter(r => 
  r.submitted_at?.substring(0, 7) === currentMonthKey
);
```

### Status Counts
```javascript
Total:             currentMonthRows.length
Pending:           currentMonthRows.filter(r => r.status === 'Pending').length
Awaiting Approval: currentMonthRows.filter(r => r.status === 'Awaiting Approval').length
Paid:              currentMonthRows.filter(r => r.status === 'Paid').length
```

### Average Processing Days
```javascript
const wRows = currentMonthRows.filter(r => 
  (r.tpt != null && r.tpt !== '') || r.total_processing_days != null
);

const average = wRows.length
  ? Math.round(wRows.reduce((sum, r) => {
      const days = parseInt(r.tpt) || r.total_processing_days || 0;
      return sum + days;
    }, 0) / wRows.length)
  : '—';
```

## Consistency with Home Dashboard

Both pages now show the same current month focus:

| Feature | Home Dashboard | Status Page |
|---------|---------------|-------------|
| **Default View** | Current month | Current month |
| **Stats Cards** | Current month data | Current month data |
| **Table/Entries** | Current month entries | Current month entries |
| **Period Filter** | N/A | Dropdown to change period |
| **Sub-label** | "May 2026" | "May 2026" |

## User Experience

### Opening Status Page
1. User opens status.html
2. Stats cards show current month data
3. Sub-label shows "May 2026"
4. Table shows current month entries (via period dropdown default)
5. Everything is in sync

### Changing Period
1. User selects "Apr 2026" from period dropdown
2. **Table updates** to show April entries
3. **Stats cards remain** showing current month (May)
4. This provides context: "Current month stats vs viewing April data"

### Viewing All Time
1. User selects "All Time" from period dropdown
2. **Table shows** all entries
3. **Stats cards remain** showing current month
4. This provides context: "Current month stats vs all historical data"

## Why Stats Stay Current Month

### Design Decision
Stats cards always show current month data regardless of period filter selection because:

1. **Context Anchor**: Provides consistent reference point
2. **Monthly Reporting**: Aligns with monthly reporting needs
3. **Quick Overview**: Always see current month performance at a glance
4. **Comparison**: Can compare current month stats while viewing historical data

### Alternative Approach (Not Implemented)
Stats could update with period filter, but this would:
- Lose current month context when viewing history
- Require users to switch back to current month to see current stats
- Be less useful for monthly reporting workflows

## Example Scenarios

### Scenario 1: Current Month Review
- **Stats**: May 2026 - Total: 15, Pending: 8, Paid: 7
- **Period**: Current Month (default)
- **Table**: Shows 15 May entries
- **Result**: Everything matches, clear view

### Scenario 2: Historical Comparison
- **Stats**: May 2026 - Total: 15, Pending: 8, Paid: 7
- **Period**: Apr 2026
- **Table**: Shows 23 April entries
- **Result**: Can see current month stats while reviewing April data

### Scenario 3: Year-End Analysis
- **Stats**: May 2026 - Total: 15, Pending: 8, Paid: 7
- **Period**: All Time
- **Table**: Shows all 150 entries
- **Result**: Current month context while viewing all historical data

## Benefits

### 1. Consistency
- Home and Status pages show same current month focus
- Predictable behavior across application
- Users know what to expect

### 2. Monthly Reporting
- Always see current month performance
- No need to select current month to see stats
- Supports monthly review workflows

### 3. Context Awareness
- Stats provide anchor point
- Can compare current month vs historical periods
- Clear separation between "now" and "then"

### 4. Quick Access
- Current month stats always visible
- No clicking required to see current performance
- Immediate insight on page load

## Technical Details

### Data Source
- Uses `allRows` (all loaded data)
- Filters by current month: `submitted_at?.substring(0, 7) === currentMonthKey`
- Calculates stats from filtered subset

### Performance
- Filtering is fast (client-side)
- No additional database queries
- Stats update instantly on page load

### Month Boundary
- Automatically updates at month change
- Uses system date: `new Date()`
- No manual configuration needed

## Future Enhancements

1. **Stats Follow Period**: Option to make stats update with period filter
2. **Comparison Stats**: Show current month vs selected period side-by-side
3. **Trend Indicators**: Show if current month is up/down vs last month
4. **Period Stats Toggle**: Button to switch between "current month" and "selected period" stats
5. **Stats Breakdown**: Click stat card to see breakdown by department/reason
6. **Export Stats**: Download current month statistics as report

## Testing Checklist

- [ ] Stats show current month data on page load
- [ ] Total count matches current month entries
- [ ] Pending count is accurate for current month
- [ ] Awaiting Approval count is accurate
- [ ] Paid count is accurate
- [ ] Average processing days calculated correctly
- [ ] Sub-label shows current month name (e.g., "May 2026")
- [ ] Stats remain current month when changing period filter
- [ ] Stats update correctly at month boundary (test on last day of month)
- [ ] Stats show "—" for average when no entries have TPT
- [ ] Stats match home dashboard counts
- [ ] Mobile responsive (cards don't overflow)
