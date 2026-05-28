# Fix: Color Coding Thresholds

## Issue
Entries outside compliance (e.g., Dismissal at 107 days) were showing GREEN when they should be RED.

## Root Cause
The delay pill color thresholds in status.html were still using old values:
- Old: 49 days (green), 69 days (amber), >69 days (red)
- Should be: 25 days (green), >25 days (red) for non-death
- Should be: 85 days (green), >85 days (red) for death

## Solution
Updated the threshold logic in status.html to match the correct compliance standards:

```javascript
// BEFORE (Incorrect)
const warnThreshold = isDeath ? 99 : 49;
const badThreshold  = isDeath ? 119 : 69;
const dpClass = d<=warnThreshold?'dp-ok':d<=badThreshold?'dp-warn':'dp-bad';

// AFTER (Correct)
const goodThreshold = isDeath ? 85 : 25;
const dpClass = d<=goodThreshold?'dp-ok':'dp-bad';
```

## Result
Now entries are correctly color-coded:
- **Dismissal at 24 days** = GREEN ✅ (compliant)
- **Dismissal at 26 days** = RED ❌ (non-compliant)
- **Dismissal at 107 days** = RED ❌ (non-compliant)
- **Death at 84 days** = GREEN ✅ (compliant)
- **Death at 86 days** = RED ❌ (non-compliant)

## Files Modified
- ✅ status.html (delay pill color logic)

**Status**: ✅ FIXED
