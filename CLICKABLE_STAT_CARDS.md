# Clickable Stat Cards Feature

## Overview
Made all stat cards on the home dashboard clickable, allowing users to navigate directly to the entries page (status.html) with the appropriate filters pre-applied.

## Implementation

### 1. Home Dashboard (home.html)

#### Updated Stat Cards
All 6 stat cards are now clickable with the `clickable-card` class and `onclick` handlers:

1. **Total Applications** → Shows current month entries
2. **Brought Forward** → Shows entries from previous months within standard
3. **Backlog** → Shows entries from previous months outside standard
4. **Compliant** → Shows current month compliant entries
5. **Non-Compliant** → Shows current month non-compliant entries
6. **Pending/In Progress** → Shows current month pending entries

#### CSS Enhancements
```css
.clickable-card {
  cursor: pointer;
  user-select: none;
}
.clickable-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 32px rgba(15,31,61,0.15);
}
.clickable-card:active {
  transform: translateY(-2px);
}
```

#### Navigation Function
```javascript
function navigateToEntries(filterType) {
  const now = new Date();
  const currentMonthKey = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
  
  // Build URL with filter parameters
  let url = 'status.html?filter=' + filterType;
  url += '&month=' + currentMonthKey;
  
  // Navigate to entries page
  location.href = url;
}
```

### 2. Entries Page (status.html)

#### New Function: `applyUrlFilters()`
Reads URL parameters and applies the appropriate filters:

**URL Parameters:**
- `filter`: Type of filter to apply
- `month`: Current month key (YYYY-MM format)

**Filter Types:**
- `current-month`: All entries from current month
- `brought-forward`: Previous month entries, pending, within standard
- `backlog`: Previous month entries, pending, outside standard
- `compliant`: Current month compliant entries
- `non-compliant`: Current month non-compliant entries
- `pending`: Current month pending entries

#### Classification Logic
The function includes its own classification logic to match home.html:
```javascript
const classifyEntry = (r) => {
  const tptVal = (r.tpt != null && r.tpt !== '' && !isNaN(parseInt(r.tpt))) 
    ? parseInt(r.tpt) 
    : (r.total_processing_days ?? null);
  
  if (tptVal === null || !r.actual_date_paid) return 'pending';
  
  const reasonLabel = r.reasons_for_leaving?.label || '';
  const isDeath = reasonLabel === 'Death';
  const standard = isDeath ? 85 : 35;
  
  return tptVal <= standard ? 'compliant' : 'noncompliant';
};
```

#### Updated `loadEntries()`
Now checks for URL parameters and calls `applyUrlFilters()` instead of `applyFilters()` when filter parameters are present.

## User Experience

### Click Flow

1. **User clicks "Brought Forward" card (showing "5")**
   - Navigates to: `status.html?filter=brought-forward&month=2026-05`
   - Entries page loads and shows only the 5 brought forward entries
   - Toast notification: "📊 Filtered: Brought Forward"

2. **User clicks "Backlog" card (showing "3")**
   - Navigates to: `status.html?filter=backlog&month=2026-05`
   - Shows only the 3 backlog entries
   - Toast notification: "📊 Filtered: Backlog"

3. **User clicks "Compliant" card (showing "12")**
   - Navigates to: `status.html?filter=compliant&month=2026-05`
   - Shows only the 12 compliant entries from current month
   - Toast notification: "📊 Filtered: Compliant"

### Visual Feedback

**Hover State:**
- Card lifts up more (`translateY(-4px)`)
- Enhanced shadow appears
- Cursor changes to pointer
- Indicates interactivity

**Click State:**
- Card slightly depresses (`translateY(-2px)`)
- Provides tactile feedback

**On Entries Page:**
- Filtered results display immediately
- Toast notification confirms the filter applied
- Result count shows filtered number vs total

## Filter Mapping

| Stat Card | Filter Type | Criteria |
|-----------|-------------|----------|
| Total Applications | `current-month` | All entries from current month |
| Brought Forward | `brought-forward` | Previous months + pending + within standard |
| Backlog | `backlog` | Previous months + pending + outside standard |
| Compliant | `compliant` | Current month + TPT ≤ standard |
| Non-Compliant | `non-compliant` | Current month + TPT > standard |
| Pending | `pending` | Current month + no payment date |

## Technical Details

### URL Structure
```
status.html?filter=<filterType>&month=<YYYY-MM>
```

**Examples:**
- `status.html?filter=brought-forward&month=2026-05`
- `status.html?filter=backlog&month=2026-05`
- `status.html?filter=compliant&month=2026-05`

### Filter Logic

#### Brought Forward
```javascript
if (!submittedMonth || submittedMonth >= monthKey) return false;
const isPending = !r.actual_date_paid || 
                 ['pending', 'in progress', 'submitted', 'awaiting approval']
                 .includes(r.status?.toLowerCase());
if (!isPending) return false;
return classification === 'compliant' || classification === 'pending';
```

#### Backlog
```javascript
if (!submittedMonth || submittedMonth >= monthKey) return false;
const isPending = !r.actual_date_paid || 
                 ['pending', 'in progress', 'submitted', 'awaiting approval']
                 .includes(r.status?.toLowerCase());
if (!isPending) return false;
return classification === 'noncompliant';
```

#### Current Month Filters
```javascript
return submittedMonth === monthKey && classification === '<type>';
```

## Benefits

### 1. Improved Navigation
- One-click access to filtered data
- No manual filter selection needed
- Faster workflow for users

### 2. Data Exploration
- Easy drill-down from summary to details
- Contextual filtering based on card clicked
- Maintains filter context from dashboard

### 3. User Experience
- Intuitive interaction pattern
- Visual feedback on hover/click
- Toast notifications confirm filter applied

### 4. Consistency
- Same classification logic in both pages
- Accurate filtering matches dashboard counts
- Reliable data representation

## Use Cases

### Monthly Review Meeting
1. Manager opens dashboard
2. Sees "Backlog: 8" in red
3. Clicks backlog card
4. Reviews all 8 problem cases
5. Takes action on urgent items

### Compliance Audit
1. Auditor opens dashboard
2. Sees "Non-Compliant: 15"
3. Clicks non-compliant card
4. Reviews each case for compliance issues
5. Exports filtered list for report

### Workload Management
1. Officer opens dashboard
2. Sees "Brought Forward: 12"
3. Clicks brought forward card
4. Reviews carried-over work
5. Prioritizes cases close to deadline

## Future Enhancements

1. **Persistent Filters**: Keep filters when navigating back to dashboard
2. **Filter Badges**: Show active filter badge on entries page
3. **Clear Filter Button**: Easy way to remove URL filters
4. **Multiple Filters**: Combine filters (e.g., backlog + specific department)
5. **Export Filtered**: Download button respects URL filters
6. **Filter History**: Browser back/forward works with filters
7. **Deep Linking**: Share filtered URLs with colleagues

## Testing Checklist

- [ ] Click each stat card and verify correct entries shown
- [ ] Verify toast notification appears with correct filter name
- [ ] Check result count matches dashboard card number
- [ ] Test with empty results (e.g., 0 backlog items)
- [ ] Verify hover effects work on all cards
- [ ] Test on mobile/tablet (touch interactions)
- [ ] Verify filters work with cached data
- [ ] Test browser back button returns to dashboard
- [ ] Check URL parameters are correctly formatted
- [ ] Verify classification logic matches between pages
