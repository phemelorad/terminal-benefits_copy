# URL Filter Integration - Status Page

## Overview
Enhanced status.html to properly process and display entries when clicking stat cards from the home dashboard. URL filters now work seamlessly with the period dropdown system.

## How It Works

### From Home Dashboard
1. User clicks a stat card (e.g., "Backlog: 8")
2. Navigates to: `status.html?filter=backlog&month=2026-05`
3. Status page loads and applies the URL filter
4. Shows exactly the entries from that stat card

### URL Filter Behavior

#### When URL Filter is Active:
- **Period dropdown is disabled** (grayed out, not clickable)
- **URL filter takes priority** over period dropdown
- **"Clear Filter" button appears** in red
- **Toast notification** shows which filter is active
- **Other filters** (search, status, dept, reason) still work

#### When URL Filter is Cleared:
- **Period dropdown re-enabled**
- **Returns to "Current Month" view**
- **Clear Filter button removed**
- **Normal filtering resumes**

## Filter Types Supported

| Filter Type | URL Parameter | Shows |
|-------------|---------------|-------|
| Current Month | `?filter=current-month&month=2026-05` | All entries from specified month |
| Brought Forward | `?filter=brought-forward&month=2026-05` | Previous months, pending, within standard |
| Backlog | `?filter=backlog&month=2026-05` | Previous months, pending, outside standard |
| Compliant | `?filter=compliant&month=2026-05` | Current month compliant entries |
| Non-Compliant | `?filter=non-compliant&month=2026-05` | Current month non-compliant entries |
| Pending | `?filter=pending&month=2026-05` | Current month pending entries |

## Visual Indicators

### 1. Disabled Period Dropdown
```css
opacity: 0.6;
cursor: not-allowed;
disabled: true;
```
- Clearly shows period dropdown is not active
- Prevents user confusion

### 2. Clear Filter Button
- **Color**: Red (#dc2626)
- **Text**: "✕ Clear Filter"
- **Position**: Right side of filters bar
- **Hover**: Darker red (#b91c1c)
- **Action**: Removes URL filter, re-enables period dropdown

### 3. Toast Notification
```
📊 Filtered: Backlog - Click "Clear Filter" to reset
```
- Shows which filter is active
- Reminds user how to clear it

## User Flow Examples

### Example 1: Viewing Backlog
1. **Home Dashboard**: User sees "Backlog: 8" card
2. **Click**: User clicks the card
3. **Navigate**: Browser goes to `status.html?filter=backlog&month=2026-05`
4. **Load**: Status page loads
5. **Filter Applied**: Shows 8 backlog entries
6. **Visual Feedback**:
   - Period dropdown disabled (grayed out)
   - Red "✕ Clear Filter" button appears
   - Toast: "📊 Filtered: Backlog - Click 'Clear Filter' to reset"
   - Result count: "8 results"

### Example 2: Clearing Filter
1. **Current State**: Viewing backlog entries (8 items)
2. **Click**: User clicks "✕ Clear Filter" button
3. **Action**: 
   - URL changes to `status.html` (parameters removed)
   - Period dropdown re-enabled
   - Period dropdown set to "Current Month"
   - Clear Filter button removed
4. **Result**: Shows current month entries (e.g., 15 items)
5. **Toast**: "✓ Filter cleared - showing current month"

### Example 3: Using Other Filters with URL Filter
1. **Current State**: Viewing "Brought Forward: 12" entries
2. **Action**: User types "John" in search box
3. **Result**: Shows brought forward entries matching "John" (e.g., 2 items)
4. **Note**: URL filter still active, period dropdown still disabled
5. **Clear**: Clicking "✕ Clear Filter" removes URL filter AND search text

## Implementation Details

### Function: `applyUrlFilters()`
```javascript
function applyUrlFilters() {
  // 1. Read URL parameters
  // 2. Disable period dropdown
  // 3. Classify entries (compliant/non-compliant/pending)
  // 4. Filter based on filter type
  // 5. Show toast notification
  // 6. Add clear filter button
  // 7. Render table
}
```

### Function: `addClearFilterButton()`
```javascript
function addClearFilterButton() {
  // 1. Check if button already exists
  // 2. Create red button with "✕ Clear Filter"
  // 3. Add to filters bar
  // 4. Attach click handler
}
```

### Function: `clearUrlFilter()`
```javascript
function clearUrlFilter() {
  // 1. Remove URL parameters (clean URL)
  // 2. Re-enable period dropdown
  // 3. Remove clear button
  // 4. Reset to current month
  // 5. Clear other filters
  // 6. Apply normal filters
  // 7. Show success toast
}
```

## Classification Logic

The URL filter uses the same classification logic as the home dashboard:

```javascript
const classifyEntry = (r) => {
  const tptVal = parseInt(r.tpt) || r.total_processing_days || null;
  
  if (tptVal === null || !r.actual_date_paid) return 'pending';
  
  const isDeath = r.reasons_for_leaving?.label === 'Death';
  const standard = isDeath ? 85 : 35;
  
  return tptVal <= standard ? 'compliant' : 'noncompliant';
};
```

This ensures consistency between home dashboard counts and status page results.

## Filter Priority

When multiple filter mechanisms are present:

1. **URL Filter** (highest priority)
   - If present, overrides everything
   - Disables period dropdown
   
2. **Period Dropdown**
   - Active when no URL filter
   - Filters by month/year
   
3. **Other Filters** (search, status, dept, reason)
   - Work with both URL filter and period dropdown
   - Applied after period/URL filter

## Edge Cases Handled

### 1. No Entries Match Filter
- Shows "0 results"
- Clear Filter button still available
- Toast notification still shows

### 2. Invalid URL Parameters
- Gracefully ignores invalid filter types
- Falls back to normal filtering
- No error shown to user

### 3. Missing Month Parameter
- Uses current month as fallback
- Filter still applies correctly

### 4. Browser Back Button
- URL filter remains active
- Clear Filter button still works
- Can navigate back to home dashboard

### 5. Direct URL Entry
- User can manually type URL with filters
- Works the same as clicking stat card
- Example: `status.html?filter=backlog&month=2026-04`

## Benefits

### 1. Seamless Integration
- Stat cards work perfectly
- No confusion between filter types
- Clear visual feedback

### 2. User Control
- Easy to clear URL filter
- Can still use other filters
- Can return to normal view anytime

### 3. Consistency
- Same classification logic as home dashboard
- Counts match between pages
- Predictable behavior

### 4. Flexibility
- URL filters work with search
- URL filters work with status/dept/reason filters
- Can combine multiple filter types

## Testing Checklist

- [ ] Click each stat card from home dashboard
- [ ] Verify correct entries shown in status page
- [ ] Check period dropdown is disabled
- [ ] Verify Clear Filter button appears
- [ ] Check toast notification shows correct filter
- [ ] Test clearing filter returns to current month
- [ ] Verify search works with URL filter
- [ ] Test status/dept/reason filters with URL filter
- [ ] Check browser back button behavior
- [ ] Test direct URL entry with filter parameters
- [ ] Verify counts match between home and status pages
- [ ] Test with 0 results
- [ ] Check mobile responsive (button doesn't overflow)
- [ ] Test clearing filter clears all filters
- [ ] Verify period dropdown re-enables after clear

## Future Enhancements

1. **Filter Badge**: Show active filter as a badge instead of just toast
2. **Multiple Filters**: Support multiple URL filters simultaneously
3. **Filter History**: Remember last 5 filters for quick access
4. **Share Filter**: Copy URL button to share filtered view
5. **Save Filter**: Save common filters as bookmarks
6. **Filter Presets**: Quick access to common filter combinations
7. **Filter Animation**: Smooth transition when applying/clearing filters
