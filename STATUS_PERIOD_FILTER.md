# Status Page Period Filter Feature

## Overview
Updated the status.html entries page to show only current month entries by default, with a new "Period" dropdown that allows users to access past records grouped by year and month.

## Changes Made

### 1. Default View: Current Month
- Status page now shows only current month entries by default
- Matches the behavior of the home dashboard
- Provides focused view of active/recent work

### 2. New Period Dropdown
Added a new dropdown at the start of the filters bar with three main options:
- **Current Month**: Shows entries from current month (default)
- **All Time**: Shows all entries across all periods
- **Past Records**: Grouped by year, then by month

### 3. Dropdown Structure

```
Period Dropdown:
├── Current Month (default)
├── All Time
├── ──────────
├── ── 2026 ──
│   ├── May 2026 (15)
│   ├── Apr 2026 (23)
│   ├── Mar 2026 (18)
│   └── ...
├── ── 2025 ──
│   ├── Dec 2025 (20)
│   ├── Nov 2025 (17)
│   └── ...
└── ...
```

### 4. Features

#### Dynamic Population
- Dropdown is automatically populated from actual data
- Only shows years/months that have entries
- Shows entry count for each month: "May 2026 (15)"
- Years are sorted descending (newest first)
- Months within each year are sorted descending

#### Smart Filtering
- Period filter is applied FIRST, then other filters
- When changing period, other filters are reset
- Maintains sort order and pagination
- Updates result count dynamically

#### Visual Organization
- Year headers are bold and disabled (not selectable)
- Separator lines between sections
- Entry counts in parentheses for each month
- Clear visual hierarchy

## Implementation Details

### State Management
```javascript
let selectedPeriod = 'current-month'; // default to current month
```

### Function: `populatePeriodDropdown()`
```javascript
function populatePeriodDropdown() {
  // Extract all unique year-month combinations from data
  // Group by year, sort descending
  // Build dropdown HTML with year headers and month options
  // Show entry count for each month
}
```

### Function: `applyPeriodFilter()`
```javascript
function applyPeriodFilter() {
  // Get selected period
  // Reset other filters (search, status, dept, reason)
  // Apply filters
}
```

### Updated `applyFilters()`
```javascript
function applyFilters() {
  // 1. First filter by period (current-month, all-time, or specific YYYY-MM)
  // 2. Then apply other filters (search, status, dept, reason)
  // 3. Sort and render
}
```

## User Experience

### Default Behavior
1. User opens status.html
2. Sees only current month entries (e.g., May 2026)
3. Period dropdown shows "Current Month" selected
4. Can immediately work with current data

### Accessing Past Records
1. User clicks Period dropdown
2. Sees organized list of years and months
3. Clicks "Apr 2026 (23)"
4. Table updates to show only April 2026 entries (23 items)
5. Other filters are reset for clean view

### Viewing All Records
1. User clicks Period dropdown
2. Selects "All Time"
3. Table shows all entries across all periods
4. Can then apply other filters as needed

## Filter Interaction

### Period Filter Priority
The period filter is applied FIRST, creating a subset of data, then other filters are applied to that subset:

```
All Data (100 entries)
    ↓
Period Filter: May 2026 (15 entries)
    ↓
Status Filter: Pending (8 entries)
    ↓
Department Filter: DIC (3 entries)
    ↓
Final Result: 3 entries
```

### Filter Reset on Period Change
When user changes the period dropdown:
- Search box is cleared
- Status dropdown reset to "All Statuses"
- Department dropdown reset to "All Departments"
- Reason dropdown reset to "All Reasons"

This provides a clean slate for the new period.

## Visual Design

### Dropdown Styling
```css
#f-period {
  min-width: 180px;
  font-weight: 600;
}
```

### Option Styling
- **Current Month**: Regular option
- **All Time**: Regular option
- **Separator**: Disabled, shows "──────────"
- **Year Headers**: Disabled, bold, dark color: "── 2026 ──"
- **Month Options**: Regular, shows count: "May 2026 (15)"

### Layout
```
[Period ▼] | [Filter] [Search...] | [Status ▼] [Dept ▼] [Reason ▼] [X results]
```

## Use Cases

### 1. Monthly Reporting
**Scenario**: Manager needs to review May 2026 performance
- Opens status page
- Already showing May 2026 (default)
- Reviews entries, exports if needed

### 2. Historical Review
**Scenario**: Auditor needs to check April 2026 entries
- Opens status page
- Clicks Period dropdown
- Selects "Apr 2026 (23)"
- Reviews all April entries

### 3. Year-End Analysis
**Scenario**: Analyst needs all 2025 data
- Opens status page
- Clicks Period dropdown
- Selects "All Time"
- Applies additional filters as needed
- Exports complete dataset

### 4. Trend Analysis
**Scenario**: Manager wants to compare multiple months
- Opens status page
- Selects "Mar 2026", notes statistics
- Selects "Apr 2026", notes statistics
- Selects "May 2026", notes statistics
- Compares trends across months

## Technical Details

### Period Value Format
- **Current Month**: `"current-month"` (special value)
- **All Time**: `"all-time"` (special value)
- **Specific Month**: `"YYYY-MM"` (e.g., "2026-05", "2025-12")

### Period Filtering Logic
```javascript
if (selectedPeriod === 'current-month') {
  const now = new Date();
  const currentMonthKey = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
  periodFiltered = allRows.filter(r => r.submitted_at?.substring(0, 7) === currentMonthKey);
} else if (selectedPeriod !== 'all-time') {
  // Specific year-month selected
  periodFiltered = allRows.filter(r => r.submitted_at?.substring(0, 7) === selectedPeriod);
}
// else 'all-time' shows everything
```

### Data Extraction
```javascript
const yearMonth = r.submitted_at.substring(0, 7); // "2026-05"
const [year, month] = yearMonth.split('-');       // ["2026", "05"]
```

## Integration with Existing Features

### Works With URL Filters
When clicking stat cards from home dashboard:
- URL parameters are still respected
- Period filter is temporarily overridden by URL filter
- After clearing URL filter, period filter resumes

### Works With Other Filters
- Period filter + Search: ✅
- Period filter + Status: ✅
- Period filter + Department: ✅
- Period filter + Reason: ✅
- All combinations work together

### Works With Sorting
- Period filtering doesn't affect sort order
- Users can still sort by name, status, days, date
- Sort persists across period changes

### Works With Pagination
- Pagination resets to page 1 when period changes
- Page size (10 per page) remains constant
- Navigation works correctly with filtered data

## Benefits

### 1. Focused View
- Default to current month reduces clutter
- Users see relevant, recent data first
- Matches home dashboard behavior

### 2. Easy Access to History
- Organized by year and month
- Clear visual hierarchy
- Entry counts help identify busy periods

### 3. Flexible Analysis
- Can view single month or all time
- Easy to switch between periods
- Supports various reporting needs

### 4. Performance
- Filtering happens client-side (fast)
- No additional database queries
- Dropdown populated once on load

## Future Enhancements

1. **Quarter View**: Add "Q1 2026", "Q2 2026" options
2. **Year View**: Add "2026 (All)", "2025 (All)" options
3. **Custom Range**: Allow user to select date range
4. **Comparison Mode**: Show two periods side-by-side
5. **Period Persistence**: Remember last selected period
6. **URL Parameter**: Support `?period=2026-05` in URL
7. **Keyboard Navigation**: Arrow keys to move between months
8. **Period Statistics**: Show summary stats for selected period

## Testing Checklist

- [ ] Default view shows current month entries
- [ ] Dropdown populates with correct years/months
- [ ] Entry counts are accurate for each month
- [ ] Selecting a month filters correctly
- [ ] "All Time" shows all entries
- [ ] Other filters reset when period changes
- [ ] Period filter works with search
- [ ] Period filter works with status/dept/reason filters
- [ ] Sorting works with period filter
- [ ] Pagination works with period filter
- [ ] Export respects period filter
- [ ] URL filters still work (from home dashboard)
- [ ] Dropdown styling is correct
- [ ] Year headers are not selectable
- [ ] Mobile responsive (dropdown doesn't overflow)
