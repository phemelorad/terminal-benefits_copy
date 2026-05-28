# Hierarchical Period Dropdown

## Overview
Replaced the standard dropdown with a custom hierarchical menu that shows years first with total counts, then expands to show individual months when hovering over a year.

## Design

### Main Menu Structure
```
Period ▼
├── Current Month
├── All Time
├── ──────────
├── 2026 (100) ▶
├── 2025 (50) ▶
└── 2024 (31) ▶
```

### Hover Expansion
When hovering over a year (e.g., "2026 (100)"), a submenu appears to the right:

```
2026 (100) ▶ ─→ ┌─ May 2026 (15)
                 ├─ Apr 2026 (23)
                 ├─ Mar 2026 (18)
                 ├─ Feb 2026 (20)
                 └─ Jan 2026 (24)
```

## User Experience

### Default View
1. Button shows "Current Month"
2. Click button to open menu
3. See years with total counts

### Accessing Specific Month
1. Click "Period" button
2. Hover over desired year (e.g., "2026 (100)")
3. Submenu appears showing months
4. Click desired month (e.g., "Apr 2026 (23)")
5. Menu closes, button updates to "Apr 2026"
6. Table shows filtered entries

### Quick Access
- **Current Month**: Click button → Click "Current Month"
- **All Time**: Click button → Click "All Time"
- **Specific Month**: Click button → Hover year → Click month

## Visual Design

### Button
```css
.period-dropdown-btn {
  background: cream;
  border: 1px solid border-color;
  padding: 7px 12px;
  font-weight: 600;
  cursor: pointer;
}
```
- Shows current selection
- Down arrow (▼) on right
- Hover: darker border, white background

### Main Menu
```css
.period-menu {
  position: absolute;
  background: white;
  border: 1px solid border-color;
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  max-height: 400px;
  overflow-y: auto;
}
```
- Appears below button
- Scrollable if many years
- Clean, organized layout

### Year Items
```css
.period-year {
  padding: 8px 12px;
  font-weight: 600;
  color: navy;
  cursor: pointer;
  display: flex;
  justify-content: space-between;
}
```
- Bold text for emphasis
- Shows total count in gray
- Right arrow (▶) indicates submenu
- Hover: cream background

### Month Submenu
```css
.period-months {
  position: absolute;
  left: 100%;
  top: 0;
  background: cream;
  border: 1px solid border-color;
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}
```
- Appears to the right of year
- Only visible on hover
- Slightly darker background (cream)
- Scrollable if many months

### Month Items
```css
.period-month {
  padding: 8px 12px;
  font-size: 0.82rem;
  cursor: pointer;
}
```
- Regular weight text
- Shows count in gray
- Hover: white background

## Implementation Details

### HTML Structure
```html
<div class="period-dropdown-wrapper">
  <button class="period-dropdown-btn" onclick="togglePeriodMenu()">
    <span id="period-btn-text">Current Month</span>
    <span>▼</span>
  </button>
  <div class="period-menu" id="period-menu">
    <div class="period-option" onclick="selectPeriod('current-month', 'Current Month')">
      Current Month
    </div>
    <div class="period-option" onclick="selectPeriod('all-time', 'All Time')">
      All Time
    </div>
    <div class="period-divider"></div>
    <div id="period-years-container">
      <!-- Years populated here -->
    </div>
  </div>
</div>
```

### JavaScript Functions

#### `populatePeriodDropdown()`
```javascript
function populatePeriodDropdown() {
  // 1. Extract years and months from data
  // 2. Calculate total entries per year
  // 3. Build year items with hover submenus
  // 4. Each year shows: "2026 (100) ▶"
  // 5. Each month shows: "May 2026 (15)"
}
```

#### `togglePeriodMenu()`
```javascript
function togglePeriodMenu() {
  // Toggle menu visibility
  // Show/hide on button click
}
```

#### `selectPeriod(value, label)`
```javascript
function selectPeriod(value, label) {
  // 1. Store selected period
  // 2. Update button text
  // 3. Close menu
  // 4. Reset other filters
  // 5. Apply filters
}
```

#### Click Outside Handler
```javascript
document.addEventListener('click', function(e) {
  // Close menu when clicking outside
});
```

## Hover Behavior

### CSS Hover Trigger
```css
.period-year:hover .period-months {
  display: block;
}
```

### How It Works
1. User hovers over year item
2. CSS `:hover` pseudo-class activates
3. Submenu `.period-months` changes from `display:none` to `display:block`
4. Submenu appears to the right
5. User can move mouse into submenu
6. Moving mouse away hides submenu

### Hover Tolerance
- Submenu positioned at `left: 100%` (right edge of year item)
- No gap between year and submenu
- Easy to move mouse from year to month
- Submenu stays visible while hovering either year or months

## Data Organization

### Year Totals
```javascript
const yearTotal = allRows.filter(r => r.submitted_at?.startsWith(year)).length;
// Example: 2026 → 100 entries
```

### Month Counts
```javascript
const count = allRows.filter(r => r.submitted_at?.substring(0, 7) === value).length;
// Example: 2026-05 → 15 entries
```

### Sorting
- **Years**: Descending (2026, 2025, 2024...)
- **Months**: Descending within each year (Dec, Nov, Oct...)

## Advantages Over Standard Dropdown

### 1. Better Organization
- **Before**: Long flat list with 50+ options
- **After**: Hierarchical structure, ~5 years visible

### 2. Clearer Context
- **Before**: "May 2026 (15)" - count only
- **After**: "2026 (100)" then "May 2026 (15)" - both year and month context

### 3. Faster Navigation
- **Before**: Scroll through all months to find specific one
- **After**: Hover year, see only that year's months

### 4. Visual Hierarchy
- **Before**: All options same level
- **After**: Clear parent-child relationship

### 5. Better Scalability
- **Before**: Gets unwieldy with many years
- **After**: Stays manageable even with 10+ years

## Use Cases

### Monthly Review
**Goal**: View April 2026 entries
1. Click "Period" button
2. Hover over "2026 (100)"
3. Click "Apr 2026 (23)"
4. Done - 2 clicks, 1 hover

### Year Overview
**Goal**: See how many entries in 2025
1. Click "Period" button
2. Look at "2025 (50)"
3. No need to click - count visible
4. Can hover to see monthly breakdown

### Quick Current Month
**Goal**: Return to current month
1. Click "Period" button
2. Click "Current Month"
3. Done - 2 clicks

### Historical Analysis
**Goal**: Compare multiple months
1. Click "Period" → Hover "2026" → Click "May 2026"
2. Note statistics
3. Click "Period" → Hover "2026" → Click "Apr 2026"
4. Note statistics
5. Compare trends

## Responsive Behavior

### Desktop (>900px)
- Submenu appears to the right
- Full hover functionality
- Smooth transitions

### Tablet (600-900px)
- Same as desktop
- May need to adjust submenu width
- Touch: tap year to show months

### Mobile (<600px)
- Consider converting to accordion
- Tap year to expand months inline
- No hover (touch devices)

## Accessibility

### Keyboard Navigation
- Tab to button
- Enter/Space to open menu
- Arrow keys to navigate
- Enter to select
- Escape to close

### Screen Readers
- Button announces current selection
- Menu items announce year and count
- Submenu items announce month and count

### Focus Management
- Focus returns to button after selection
- Focus trapped in menu when open
- Clear focus indicators

## Integration with Existing Features

### Works With URL Filters
- When URL filter active, button disabled
- Button grayed out, not clickable
- Clear Filter button re-enables

### Works With Other Filters
- Period filter applied first
- Then search, status, dept, reason
- All combinations work

### Works With Sorting
- Period doesn't affect sort order
- Sort persists across period changes

## Future Enhancements

1. **Year Selection**: Click year to show all entries from that year
2. **Quarter View**: Add Q1, Q2, Q3, Q4 options under each year
3. **Search in Menu**: Type to filter years/months
4. **Keyboard Shortcuts**: Alt+P to open, numbers to select
5. **Recent Periods**: Show last 5 selected periods at top
6. **Favorites**: Star frequently used periods
7. **Custom Ranges**: "Last 3 months", "Last 6 months"
8. **Comparison Mode**: Select multiple periods to compare

## Testing Checklist

- [ ] Button opens/closes menu on click
- [ ] Hovering year shows month submenu
- [ ] Clicking month selects it and closes menu
- [ ] Button text updates to selected period
- [ ] Year counts are accurate
- [ ] Month counts are accurate
- [ ] Submenu positioned correctly (right of year)
- [ ] Submenu doesn't overflow screen
- [ ] Click outside closes menu
- [ ] Disabled state works (URL filter active)
- [ ] Current Month option works
- [ ] All Time option works
- [ ] Scrolling works if many years
- [ ] Hover works smoothly (no flickering)
- [ ] Mobile/touch behavior acceptable
- [ ] Keyboard navigation works
- [ ] Screen reader announces correctly
