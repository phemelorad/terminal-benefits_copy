# Brought Forward & Backlog Counters

## Overview
Added two new counters to the home dashboard that track pending entries from previous months, categorized by their compliance status:

1. **Brought Forward**: Pending entries from previous months that are WITHIN service standard
2. **Backlog**: Pending entries from previous months that are OUTSIDE service standard (breached)

## Business Logic

### BROUGHT FORWARD (Within Standard)
Entries that meet ALL of these criteria:
- ✅ Submitted in a **previous month** (before current month)
- ✅ Still **pending/in-progress** (not paid/completed)
- ✅ **Within service standard** (TPT ≤ 35 days for retirement/withdrawal, ≤ 85 days for death)

**These are "healthy" carry-overs** - work in progress that is still on track to meet compliance targets.

### BACKLOG (Outside Standard)
Entries that meet ALL of these criteria:
- ✅ Submitted in a **previous month** (any month before current)
- ✅ Still **pending/in-progress** (not paid/completed)
- ✅ **Outside service standard** (TPT > 35 days for retirement/withdrawal, > 85 days for death)

**These are "problem cases"** - work that has breached compliance and needs urgent attention.

## Examples

### Current Month: May 2026

#### BROUGHT FORWARD Examples ✅

**Example 1: Recent Previous Month**
- Submitted: April 25, 2026
- Reason: Retirement
- Days elapsed: 10 days (as of May 5)
- Standard: 35 days
- Status: Pending
- **Result**: BROUGHT FORWARD ✅ (10 ≤ 35, still has 25 days left)

**Example 2: Death Case**
- Submitted: April 15, 2026
- Reason: Death
- Days elapsed: 20 days
- Standard: 85 days
- Status: In Progress
- **Result**: BROUGHT FORWARD ✅ (20 ≤ 85, still has 65 days left)

**Example 3: Close to Deadline**
- Submitted: April 5, 2026
- Reason: Retirement
- Days elapsed: 30 days
- Standard: 35 days
- Status: Pending
- **Result**: BROUGHT FORWARD ✅ (30 ≤ 35, still has 5 days left)

#### BACKLOG Examples ⚠️

**Example 4: Recently Breached**
- Submitted: April 10, 2026
- Reason: Retirement
- Days elapsed: 40 days (as of May 20)
- Standard: 35 days
- Status: Pending
- **Result**: BACKLOG ⚠️ (40 > 35, breached by 5 days)

**Example 5: Older Breach**
- Submitted: March 15, 2026
- Reason: Retirement
- Days elapsed: 50 days
- Standard: 35 days
- Status: Pending
- **Result**: BACKLOG ⚠️ (50 > 35, breached by 15 days)

**Example 6: Death Case Breach**
- Submitted: February 20, 2026
- Reason: Death
- Days elapsed: 90 days
- Standard: 85 days
- Status: In Progress
- **Result**: BACKLOG ⚠️ (90 > 85, breached by 5 days)

#### NOT COUNTED Examples ❌

**Example 7: Completed**
- Submitted: April 20, 2026
- Reason: Retirement
- Days elapsed: 15 days
- Status: Paid on April 30
- **Result**: NOT counted ❌ (already completed/paid)

**Example 8: Current Month**
- Submitted: May 3, 2026
- Reason: Retirement
- Days elapsed: 2 days
- Status: Pending
- **Result**: NOT counted ❌ (current month submission, shows in "Pending")

**Example 9: Completed from Previous Month**
- Submitted: April 1, 2026
- Reason: Retirement
- Days elapsed: 25 days
- Status: Paid on April 25
- **Result**: NOT counted ❌ (completed, even though from previous month)

## Visual Design

### Card Layout (6 Cards Total)
1. **Total Applications** (Gold) - Current month total
2. **Brought Forward** (Blue #2563eb) - Within standard 📥
3. **Backlog** (Red #dc2626) - Outside standard 📦
4. **Compliant** (Green) - Current month compliant
5. **Non-Compliant** (Red) - Current month non-compliant
6. **Pending/In Progress** (Blue-gray) - Current month pending

### Brought Forward Card
- **Icon**: 📥 (inbox with arrow)
- **Color**: Blue (#2563eb)
- **Label**: "Brought Forward"
- **Sub-label**: "Within standard"
- **Meaning**: Healthy carry-over work

### Backlog Card
- **Icon**: 📦 (package/box)
- **Color**: Red (#dc2626)
- **Label**: "Backlog"
- **Sub-label**: "Outside standard"
- **Meaning**: Problem cases needing urgent attention

## Responsive Layout

- **Desktop (>1200px)**: 6 cards in a row
- **Tablet (900-1200px)**: 3 cards per row (2 rows)
- **Mobile tablet (600-900px)**: 2 cards per row (3 rows)
- **Mobile phone (<600px)**: 1 card per column (6 rows)

## Implementation Details

### Function: `getBroughtForwardApps()`
```javascript
function getBroughtForwardApps() {
  const now = new Date();
  const currentMonthKey = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
  
  return allApps.filter(a => {
    const submittedMonth = a.submitted_at?.substring(0, 7);
    // Must be from a previous month
    if (!submittedMonth || submittedMonth >= currentMonthKey) return false;
    
    // Must be pending (not paid)
    const isPending = !a.actual_date_paid || 
                      ['pending', 'in progress', 'submitted', 'under review']
                      .includes(a.status?.toLowerCase());
    if (!isPending) return false;
    
    // Must be WITHIN service standard
    const classification = classifyApp(a);
    return classification === 'compliant' || classification === 'pending';
  });
}
```

### Function: `getBacklogApps()`
```javascript
function getBacklogApps() {
  const now = new Date();
  const currentMonthKey = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
  
  return allApps.filter(a => {
    const submittedMonth = a.submitted_at?.substring(0, 7);
    // Must be from a previous month
    if (!submittedMonth || submittedMonth >= currentMonthKey) return false;
    
    // Must be pending (not paid)
    const isPending = !a.actual_date_paid || 
                      ['pending', 'in progress', 'submitted', 'under review']
                      .includes(a.status?.toLowerCase());
    if (!isPending) return false;
    
    // Must be OUTSIDE service standard
    const classification = classifyApp(a);
    return classification === 'noncompliant';
  });
}
```

## Use Cases

### 1. Monthly Reporting
- **Brought Forward**: Shows healthy workload carried over
- **Backlog**: Highlights problem cases requiring immediate action
- Helps distinguish between normal workflow and urgent issues

### 2. Performance Management
- **High Brought Forward**: Normal for month-end submissions
- **High Backlog**: Indicates systemic delays or bottlenecks
- Enables targeted intervention on problem cases

### 3. Resource Allocation
- **Brought Forward**: Can be processed in normal workflow
- **Backlog**: May need additional resources or priority handling
- Helps managers allocate staff effectively

### 4. Compliance Tracking
- **Brought Forward**: Still compliant, no immediate risk
- **Backlog**: Already non-compliant, affects compliance rate
- Enables proactive management before more cases breach

## Key Differences

| Aspect | Brought Forward | Backlog |
|--------|----------------|---------|
| **Status** | Within standard | Outside standard |
| **Urgency** | Normal priority | High priority |
| **Compliance** | Still compliant | Already breached |
| **Action** | Continue processing | Urgent attention needed |
| **Color** | Blue (neutral) | Red (warning) |
| **Icon** | 📥 (incoming) | 📦 (accumulated) |

## Reporting Insights

### Healthy Scenario
- Brought Forward: 5-10 entries
- Backlog: 0-2 entries
- **Interpretation**: Normal workflow, month-end carry-over, minimal issues

### Warning Scenario
- Brought Forward: 15+ entries
- Backlog: 5-10 entries
- **Interpretation**: High workload, some delays, needs monitoring

### Critical Scenario
- Brought Forward: 20+ entries
- Backlog: 15+ entries
- **Interpretation**: Systemic delays, urgent intervention needed

## Testing Scenarios

1. **Test with no previous month entries**: Both should show 0
2. **Test with pending entries within standard**: Should appear in Brought Forward
3. **Test with pending entries outside standard**: Should appear in Backlog
4. **Test with completed entries from previous month**: Should NOT appear in either
5. **Test at month boundary**: Verify correct calculation on first day of new month
6. **Test with mixed reasons**: Verify 35-day vs 85-day standards applied correctly
7. **Test with entries from multiple past months**: All should be counted if still pending

## Future Enhancements

1. **Aging Analysis**: Show average age of backlog entries
2. **Trend Tracking**: Chart backlog growth/reduction over time
3. **Click-through Details**: Show list of specific backlog entries
4. **Alert Thresholds**: Notify when backlog exceeds acceptable level
5. **Breakdown by Department**: Show which departments have most backlog
6. **Breakdown by Reason**: Show if death or retirement cases are more problematic
