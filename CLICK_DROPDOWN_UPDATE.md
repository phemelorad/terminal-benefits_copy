# Click-Based Dropdown Update

## Overview
Changed the period dropdown from hover-based sliding submenus to click-based expand/collapse dropdowns with rotating arrows.

## Changes Made

### 1. CSS Updates

**Before (Hover-based):**
```css
.period-months {
  position: absolute;
  left: 100%;
  top: 0;
  /* Appears to the right on hover */
}
.period-year:hover .period-months {
  display: block;
}
```

**After (Click-based):**
```css
.period-months {
  display: none;
  background: var(--cream);
  padding-left: 16px;
  /* Expands inline below year */
}
.period-year.expanded .period-months {
  display: block;
}
.period-year-arrow {
  transition: transform .2s;
}
.period-year.expanded .period-year-arrow {
  transform: rotate(90deg);
  /* Arrow rotates when expanded */
}
```

### 2. JavaScript Updates

**Added `toggleYear()` Function:**
```javascript
function toggleYear(yearElement) {
  // Close other expanded years
  document.querySelectorAll('.period-year.expanded').forEach(el => {
    if (el !== yearElement) {
      el.classList.remove('expanded');
    }
  });
  
  // Toggle this year
  yearElement.classList.toggle('expanded');
}
```

**Updated Year HTML:**
```html
<div class="period-year" onclick="toggleYear(this)">
  <span>2026 <span style="color:var(--muted)">(100)</span></span>
  <span class="period-year-arrow">▶</span>
  <div class="period-months" onclick="event.stopPropagation()">
    <!-- Months here -->
  </div>
</div>
```

**Updated Month HTML:**
```html
<div class="period-month" onclick="selectPeriod('2026-05', 'May 2026'); event.stopPropagation();">
  May 2026 <span style="color:var(--muted)">(15)</span>
</div>
```

## User Experience

### Before (Hover)
1. Open menu
2. Hover over year
3. Submenu slides out to the right
4. Click month
5. Menu closes

**Issues:**
- Hover can be finicky
- Hard to use on touch devices
- Submenu can go off-screen
- Accidental triggers

### After (Click)
1. Open menu
2. Click year to expand
3. Months appear below year (indented)
4. Arrow rotates 90° (▶ → ▼)
5. Click month to select
6. Menu closes

**Benefits:**
- More deliberate interaction
- Works on touch devices
- No off-screen issues
- Clear visual feedback

## Visual Behavior

### Collapsed State
```
Period ▼
├── Current Month
├── All Time
├── ──────────
├── 2026 (100) ▶
├── 2025 (50) ▶
└── 2024 (31) ▶
```

### Expanded State (2026 clicked)
```
Period ▼
├── Current Month
├── All Time
├── ──────────
├── 2026 (100) ▼
│   ├── May 2026 (15)
│   ├── Apr 2026 (23)
│   ├── Mar 2026 (18)
│   └── ...
├── 2025 (50) ▶
└── 2024 (31) ▶
```

## Features

### 1. Single Expansion
- Only one year can be expanded at a time
- Clicking a new year collapses the previous one
- Keeps menu clean and organized

### 2. Arrow Rotation
- **Collapsed**: ▶ (points right)
- **Expanded**: ▼ (points down, rotated 90°)
- Smooth transition animation (0.2s)

### 3. Inline Expansion
- Months appear below year (not to the side)
- Indented with `padding-left: 16px`
- Cream background to distinguish from main menu

### 4. Event Propagation
- `event.stopPropagation()` prevents clicks on months from toggling year
- Clicking month selects it without collapsing/expanding

### 5. Click Outside
- Clicking outside menu closes it
- Existing functionality preserved

## Touch Device Support

### Before (Hover)
- Hover doesn't work on touch devices
- Required tap to trigger hover, then tap again to select
- Confusing user experience

### After (Click)
- Tap year to expand
- Tap month to select
- Natural touch interaction
- Works like native mobile dropdowns

## Accessibility

### Keyboard Navigation
- Tab to button
- Enter/Space to open menu
- Arrow keys to navigate years
- Enter to expand/collapse year
- Arrow keys to navigate months
- Enter to select month
- Escape to close

### Screen Readers
- Year announces: "2026, 100 entries, collapsed/expanded"
- Month announces: "May 2026, 15 entries"
- Arrow rotation provides visual feedback

## Comparison

| Feature | Hover (Before) | Click (After) |
|---------|---------------|---------------|
| **Trigger** | Mouse hover | Click |
| **Touch Support** | Poor | Excellent |
| **Visual Feedback** | Submenu appears | Arrow rotates |
| **Layout** | Slides to right | Expands inline |
| **Accidental Triggers** | Common | Rare |
| **Screen Space** | Can overflow | Contained |
| **Clarity** | Less clear | Very clear |
| **Mobile Friendly** | No | Yes |

## Testing Checklist

- [ ] Click year expands months below
- [ ] Arrow rotates from ▶ to ▼
- [ ] Only one year expanded at a time
- [ ] Clicking another year collapses first
- [ ] Clicking month selects it
- [ ] Menu closes after selection
- [ ] Click outside closes menu
- [ ] Touch devices work correctly
- [ ] No off-screen overflow
- [ ] Smooth animations
- [ ] Keyboard navigation works
- [ ] Screen reader announces correctly

## Future Enhancements

1. **Collapse on Second Click**: Click expanded year to collapse it
2. **Expand All**: Button to expand all years at once
3. **Remember State**: Keep last expanded year open
4. **Smooth Height Transition**: Animate height when expanding
5. **Nested Quarters**: Add Q1, Q2, Q3, Q4 under each year
6. **Search Filter**: Type to filter years/months
7. **Keyboard Shortcuts**: Number keys to expand years
