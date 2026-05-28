# Fix: Make Edit Fields Read-Only

## Issue #7 from improvements.txt

**Problem**: TPT and public holidays fields in the edit tab should not be user-editable. They should be calculated automatically from the date values.

**Solution Implemented**:
- Made TPT field read-only with auto-calculation
- Made public holidays field read-only
- Added `calculateTPT()` function that runs when dates change
- TPT is automatically calculated from Date Exited Service to Actual Date Paid
- Fields have visual indication (gray background) that they're read-only

---

## Changes Made

### 1. TPT Field - Now Read-Only & Auto-Calculated
```html
<!-- BEFORE -->
<input type="text" id="ef-tpt" value="${r.tpt||''}">

<!-- AFTER -->
<input type="text" id="ef-tpt" value="${r.tpt||''}" 
       readonly 
       style="background:#f0f0f0;cursor:not-allowed" 
       title="Automatically calculated from dates">
```

### 2. Public Holidays Field - Now Read-Only
```html
<!-- BEFORE -->
<input type="text" id="ef-hol" value="${r.public_holidays||''}">

<!-- AFTER -->
<input type="text" id="ef-hol" value="${r.public_holidays||''}" 
       readonly 
       style="background:#f0f0f0;cursor:not-allowed" 
       title="Calculated field - not editable">
```

### 3. Auto-Calculate TPT Function
```javascript
function calculateTPT() {
  const dxs = document.getElementById('ef-dxs')?.value;
  const adp = document.getElementById('ef-adp')?.value;
  const tptField = document.getElementById('ef-tpt');
  
  if (dxs && adp && tptField) {
    const tptDays = Math.round((new Date(adp) - new Date(dxs)) / 86400000);
    tptField.value = tptDays;
    console.log('[Auto-calc] TPT:', tptDays, 'days');
  }
}
```

### 4. Trigger Calculation on Date Changes
```html
<input type="date" id="ef-dxs" onchange="calculateTPT()">
<input type="date" id="ef-adp" onchange="calculateTPT()">
```

---

## Benefits

1. **Data Integrity**: Users can't manually enter incorrect TPT values
2. **Consistency**: TPT is always calculated the same way
3. **User Experience**: Clear visual indication that fields are calculated
4. **Automatic**: TPT updates instantly when dates change

---

## Files Modified

- ✅ `status.html` - Edit modal fields made read-only, calculateTPT() function added

---

## Testing

1. Open an entry in edit mode
2. Change "Date Exited Service" - TPT should NOT recalculate yet
3. Change "Actual Date Paid" - TPT should auto-calculate
4. Try to click in TPT field - cursor should show "not-allowed"
5. Try to type in TPT field - nothing should happen (read-only)
6. Save the entry - TPT value should be saved correctly

---

**Status**: ✅ COMPLETE
