# TPT Missing Values Fix

## Problem
Some entries have dates (Date Exited Service and Actual Date Paid) but TPT (Total Processing Time) shows as "—" (empty/null).

## Root Cause
TPT was being calculated in the UI but not always saved to the database:

1. **Dashboard form**: TPT calculated on date change, but if form submitted before calculation completes, TPT field might be empty
2. **Status edit**: TPT taken directly from input field without recalculation
3. **Timing issue**: If dates entered quickly and form submitted immediately, TPT might not be calculated yet

## Solution Applied

### 1. Dashboard Form - Guaranteed TPT Calculation ✅
Added fallback calculation before form submission:

```javascript
// Calculate TPT if dates are present but TPT is empty
const dxs = dateVal('dxs');
const adp = dateVal('adp');
let tptValue = textVal('tpt');

if (dxs && adp && (!tptValue || tptValue === '')) {
  // Calculate TPT: Date Exited Service → Actual Date Paid
  const tptDays = Math.round((new Date(adp) - new Date(dxs)) / 86400000);
  tptValue = tptDays.toString();
  console.log('[Submit] TPT calculated:', tptDays, 'days');
}
```

**Result**: TPT always calculated and saved, even if UI calculation didn't run

### 2. Status Edit - Guaranteed TPT Calculation ✅
Added same fallback calculation to edit/save function:

```javascript
// Get date values
const dxs = document.getElementById('ef-dxs').value || null;
const adp = document.getElementById('ef-adp').value || null;
let tptValue = document.getElementById('ef-tpt').value.trim() || null;

// Calculate TPT if dates are present but TPT is empty
if (dxs && adp && (!tptValue || tptValue === '')) {
  const tptDays = Math.round((new Date(adp) - new Date(dxs)) / 86400000);
  tptValue = tptDays.toString();
  console.log('[SaveEdit] TPT calculated:', tptDays, 'days');
}
```

**Result**: TPT recalculated on edit if missing

### 3. SQL Script to Fix Existing Data ✅
Created `fix_missing_tpt.sql` to update existing entries:

```sql
UPDATE applications
SET tpt = EXTRACT(DAY FROM (actual_date_paid::timestamp - date_exited_service::timestamp))
WHERE date_exited_service IS NOT NULL
  AND actual_date_paid IS NOT NULL
  AND (tpt IS NULL OR tpt::text = '');
```

**Result**: All existing entries with dates but missing TPT will be fixed

---

## Files Updated

### ✅ dashboard.html
- Added TPT calculation fallback in form submission
- Ensures TPT always saved when dates present

### ✅ status.html
- Added TPT calculation fallback in edit/save function
- Recalculates TPT if missing during edit

### ✅ fix_missing_tpt.sql
- SQL script to fix existing data
- Updates all entries with dates but missing TPT

---

## How TPT is Calculated

### Formula:
```
TPT = Actual Date Paid - Date Exited Service (in days)
```

### Example:
- Date Exited Service: 05 May 2026
- Actual Date Paid: 20 August 2026
- TPT = 107 days

### Calculation Method:
```javascript
const tptDays = Math.round((new Date(adp) - new Date(dxs)) / 86400000);
```

Where:
- `86400000` = milliseconds in a day (24 * 60 * 60 * 1000)
- `Math.round()` = rounds to nearest whole day

---

## Testing

### Test New Entries:
1. Go to dashboard.html
2. Fill in all fields including dates
3. Submit form quickly (don't wait for UI calculation)
4. Check entry in status.html
5. TPT should be calculated and displayed

### Test Editing:
1. Go to status.html
2. Edit an entry with dates but missing TPT
3. Save without changing anything
4. TPT should be calculated and saved

### Test Existing Data:
1. Run `fix_missing_tpt.sql` in Supabase SQL Editor
2. Check entries that had missing TPT
3. TPT should now be populated

---

## Verification

### Check Console Logs:
When submitting/editing entries with dates:
```
[Submit] TPT calculated: 107 days
```
or
```
[SaveEdit] TPT calculated: 107 days
```

### Check Database:
```sql
-- Find entries with dates but missing TPT
SELECT id, date_exited_service, actual_date_paid, tpt
FROM applications
WHERE date_exited_service IS NOT NULL
  AND actual_date_paid IS NOT NULL
  AND (tpt IS NULL OR tpt::text = '')
ORDER BY id DESC;
```

Should return 0 rows after fix is applied.

---

## Why This Happened

### Original Issue:
1. **UI Calculation**: TPT calculated on date field change events
2. **Race Condition**: If form submitted before change event fires, TPT empty
3. **Fast Users**: Users entering dates quickly and submitting immediately
4. **No Fallback**: No calculation at submission time

### Example Scenario:
```
1. User enters Date Exited Service
2. User enters Actual Date Paid
3. User clicks Submit immediately
4. Change event hasn't fired yet
5. TPT field is empty
6. Form submits with TPT = null
```

---

## Prevention

### Now Implemented:
1. ✅ **UI Calculation**: Still calculates on date change (instant feedback)
2. ✅ **Submission Fallback**: Calculates at submission if missing
3. ✅ **Edit Fallback**: Recalculates on edit if missing
4. ✅ **Console Logging**: Shows when fallback calculation runs

### Future Enhancement:
Consider making TPT a **computed column** in the database:

```sql
ALTER TABLE applications
ADD COLUMN tpt_computed INTEGER GENERATED ALWAYS AS (
  CASE 
    WHEN date_exited_service IS NOT NULL AND actual_date_paid IS NOT NULL
    THEN EXTRACT(DAY FROM (actual_date_paid - date_exited_service))
    ELSE NULL
  END
) STORED;
```

**Benefits**:
- Always accurate
- Automatically updates when dates change
- No calculation needed in code

---

## Impact

### Before Fix:
- Some entries missing TPT despite having dates
- Compliance calculations incorrect
- Dashboard stats incomplete
- Manual recalculation needed

### After Fix:
- ✅ All new entries have TPT
- ✅ Edited entries recalculate TPT
- ✅ Existing data fixed with SQL script
- ✅ Compliance calculations accurate
- ✅ Dashboard stats complete

---

## Summary

**Problem**: Entries had dates but missing TPT values

**Root Cause**: Race condition between UI calculation and form submission

**Solution**: 
1. ✅ Added fallback calculation at submission time (dashboard.html)
2. ✅ Added fallback calculation at edit time (status.html)
3. ✅ Created SQL script to fix existing data (fix_missing_tpt.sql)

**Result**: TPT always calculated and saved when dates are present! ✅

---

## Instructions

### For New Entries:
- No action needed - automatic calculation on submit

### For Existing Entries:
1. Open Supabase SQL Editor
2. Run `fix_missing_tpt.sql`
3. Verify results with the SELECT query
4. All missing TPT values will be populated

### For Future Edits:
- No action needed - automatic recalculation on save
