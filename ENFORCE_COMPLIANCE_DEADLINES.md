# Enforce Compliance Deadlines & Color Coding

## Issues #1 & #2 from improvements.txt

**#1 Problem**: Need to enforce compliance deadlines:
- 25 working days for retirement/withdrawal/dismissal
- 85 working days for death

**#2 Problem**: Color coding should reflect compliance status:
- Green for compliant (within deadline)
- Red for non-compliant (outside deadline)
- Example: Dismissal at 84 days should be green (under 85 days for death cases)

---

## Current vs New Standards

### OLD (Incorrect)
- All cases: 35 days standard
- Death cases: Not properly handled

### NEW (Correct)
- **Retirement/Withdrawal/Dismissal**: 25 working days
- **Death**: 85 working days

---

## Implementation Strategy

### 1. Update Classification Logic
All pages that classify entries need to use the correct standards:
- `home.html` - Dashboard compliance metrics
- `status.html` - Entry list and details
- `dashboard.html` - Form submission validation
- `admin.html` - System records

### 2. Color Coding System
```javascript
// Compliant (within deadline)
- Background: #dcfce7 (light green)
- Text: #166534 (dark green)
- Border: #16653 4 (dark green)

// Non-Compliant (outside deadline)
- Background: #fee2e2 (light red)
- Text: #991b1b (dark red)
- Border: #991b1b (dark red)

// Pending (no payment date yet)
- Background: #fef3c7 (light amber)
- Text: #92600a (dark amber)
- Border: #92600a (dark amber)
```

### 3. Standard Classification Function
```javascript
function classifyCompliance(entry) {
  const tpt = entry.tpt || entry.total_processing_days;
  const hasPaidDate = entry.actual_date_paid;
  
  // If no payment date, it's pending
  if (!hasPaidDate || tpt === null) {
    return { status: 'pending', color: 'amber', days: tpt };
  }
  
  // Determine deadline based on reason
  const reason = entry.reasons_for_leaving?.label || '';
  const isDeath = reason.toLowerCase().includes('death');
  const deadline = isDeath ? 85 : 25;
  
  // Check compliance
  const isCompliant = tpt <= deadline;
  
  return {
    status: isCompliant ? 'compliant' : 'noncompliant',
    color: isCompliant ? 'green' : 'red',
    days: tpt,
    deadline: deadline,
    reason: reason
  };
}
```

---

## Files to Update

### 1. home.html
- Update `classifyApp()` function
- Update compliance gauge calculations
- Update department compliance calculations
- Update monthly/yearly compliance tables

### 2. status.html
- Update `classifyEntry()` function
- Update entry row color coding
- Update delay pill colors
- Update detail modal display

### 3. dashboard.html
- Update validation on form submission
- Show appropriate deadline based on reason selected

### 4. admin.html
- Update system records classification
- Update activity log display

---

## Implementation

### Step 1: Update home.html Classification

```javascript
// BEFORE (Incorrect - uses 35 days for all)
function classifyApp(a) {
  const tpt = a.tpt ?? a.total_processing_days ?? null;
  if (!a.actual_date_paid || tpt === null) return 'pending';
  
  const reasonLabel = a.reasons_for_leaving?.label || '';
  const isDeath = reasonLabel === 'Death';
  const standard = isDeath ? 85 : 35; // WRONG - should be 25
  
  return tpt <= standard ? 'compliant' : 'noncompliant';
}

// AFTER (Correct - uses 25 days for non-death)
function classifyApp(a) {
  const tpt = a.tpt ?? a.total_processing_days ?? null;
  if (!a.actual_date_paid || tpt === null) return 'pending';
  
  const reasonLabel = a.reasons_for_leaving?.label || '';
  const isDeath = reasonLabel.toLowerCase().includes('death');
  const standard = isDeath ? 85 : 25; // CORRECT
  
  return tpt <= standard ? 'compliant' : 'noncompliant';
}
```

### Step 2: Update status.html Classification

```javascript
// Update classifyEntry function
const classifyEntry = (r) => {
  const tptVal = (r.tpt != null && r.tpt !== '' && !isNaN(parseInt(r.tpt))) 
    ? parseInt(r.tpt) 
    : (r.total_processing_days ?? null);
  
  if (tptVal === null || !r.actual_date_paid) return 'pending';
  
  const reasonLabel = r.reasons_for_leaving?.label || '';
  const isDeath = reasonLabel.toLowerCase().includes('death');
  const standard = isDeath ? 85 : 25; // UPDATED
  
  return tptVal <= standard ? 'compliant' : 'noncompliant';
};
```

### Step 3: Update Color Coding

```javascript
// Delay pill classes
.dp-ok    { background: #dcfce7; color: #166534; } // Green - Compliant
.dp-warn  { background: #fef3c7; color: #92600a; } // Amber - Pending
.dp-bad   { background: #fee2e2; color: #991b1b; } // Red - Non-compliant
```

---

## Testing Scenarios

### Test Case 1: Death Case at 84 Days
- Reason: Death
- TPT: 84 days
- Expected: GREEN (compliant - under 85 days)

### Test Case 2: Retirement at 24 Days
- Reason: Retirement
- TPT: 24 days
- Expected: GREEN (compliant - under 25 days)

### Test Case 3: Dismissal at 26 Days
- Reason: Dismissal
- TPT: 26 days
- Expected: RED (non-compliant - over 25 days)

### Test Case 4: Death at 86 Days
- Reason: Death
- TPT: 86 days
- Expected: RED (non-compliant - over 85 days)

### Test Case 5: No Payment Date
- Reason: Any
- TPT: Any
- Actual Date Paid: NULL
- Expected: AMBER (pending)

---

## Status

- [ ] home.html updated
- [ ] status.html updated
- [ ] dashboard.html updated
- [ ] admin.html updated
- [ ] Color coding verified
- [ ] All test cases passed

---

**Next**: Implement the changes in all files
