# 📋 Copy-Paste Implementation Guide

This guide provides exact code snippets you can copy and paste into your existing files.

---

## 🔧 IMPORTANT: Run SQL First!

Before making any changes, run this in Supabase SQL Editor:
```sql
-- File: add_detailed_compliance_tracking.sql
-- (Use the existing SQL file in your project)
```

---

## 📄 1. status.html Changes

### Change 1: Update Table Header
**Find this code (around line 755):**
```html
<th>Notice Date</th>
<th>Actual Paid</th>
${th('total_days','Days')}
${th('status','Status')}
```

**Replace with:**
```html
<th>Notice Date</th>
<th>File Prep</th>
<th>Leave Paid</th>
<th>Benefits Paid</th>
${th('total_days','TPT')}
${th('status','Status')}
```

---

### Change 2: Add Compliance Cell Function
**Find this code (around line 770):**
```javascript
function rowHtml(r, i) {
  const hl = (txt, q) => {
```

**Add this BEFORE the existing code:**
```javascript
  // Helper function for compliance cells
  const complianceCell = (stage) => {
    const reason = r.reasons_for_leaving?.label || '';
    const isDeath = reason === 'Death';
    
    let days, standard, date;
    
    if (stage === 'file_prep') {
      days = r.days_to_file_prep;
      standard = isDeath ? 20 : 10;
      date = r.date_file_prepared;
    } else if (stage === 'leave_payment') {
      if (isDeath) return '<td style="text-align:center;color:#999">N/A</td>';
      days = r.days_to_leave_payment;
      standard = 10;
      date = r.date_leave_paid;
    } else if (stage === 'benefits_payment') {
      days = r.days_to_benefits_payment;
      standard = isDeath ? 85 : 25;
      date = r.date_benefits_paid;
    }
    
    if (!date) {
      return '<td style="text-align:center;color:#999">—</td>';
    }
    
    const compliant = days <= standard;
    const bgColor = compliant ? '#dcfce7' : '#fee2e2';
    const textColor = compliant ? '#166534' : '#991b1b';
    const icon = compliant ? '✓' : '✗';
    
    return `<td><span style="display:inline-block;padding:3px 8px;background:${bgColor};color:${textColor};font-weight:700;font-size:0.75rem;border-radius:2px">
      ${icon} ${days}/${standard}d
    </span></td>`;
  };
```

---

### Change 3: Update Table Row
**Find this code (in the same rowHtml function):**
```javascript
<td style="font-size:.82rem">${fmt(r.date_officer_gave_notice)}</td>
<td style="font-size:.82rem">${fmt(r.actual_date_paid)}</td>
<td><span class="delay-pill ${dpClass}"
```

**Replace with:**
```javascript
<td style="font-size:.82rem">${fmt(r.date_officer_gave_notice)}</td>
${complianceCell('file_prep')}
${complianceCell('leave_payment')}
${complianceCell('benefits_payment')}
<td><span class="delay-pill ${dpClass}"
```

---

### Change 4: Add Compliance Filter
**Find this code (around line 440):**
```html
<select class="filter-select" id="f-reason"  onchange="applyFilters()">
  <option value="">All Reasons</option>
  <option value="Retirement">Retirement</option>
  <!-- ... more options ... -->
  <option value="Death">Death</option>
</select>
```

**Add this AFTER the above code:**
```html
<select class="filter-select" id="f-compliance" onchange="applyFilters()">
  <option value="">All Compliance</option>
  <option value="compliant">✓ Compliant</option>
  <option value="non-compliant">✗ Non-Compliant</option>
  <option value="pending">⏳ Pending</option>
</select>
```

---

### Change 5: Update Filter Logic
**Find this code (around line 650):**
```javascript
function applyFilters() {
  const q = document.getElementById('f-search').value.toLowerCase();
  const st= document.getElementById('f-status').value;
  const dp= document.getElementById('f-dept').value;
  const rn= document.getElementById('f-reason').value;

  filtered = allRows.filter(r => {
```

**Replace with:**
```javascript
function applyFilters() {
  const q = document.getElementById('f-search').value.toLowerCase();
  const st= document.getElementById('f-status').value;
  const dp= document.getElementById('f-dept').value;
  const rn= document.getElementById('f-reason').value;
  const complianceFilter = document.getElementById('f-compliance')?.value;

  filtered = allRows.filter(r => {
```

**Then find this code (a few lines down):**
```javascript
    if (rn && (r.reasons_for_leaving?.code||r.reasons_for_leaving?.label||'') !== rn) return false;
    return true;
  });
```

**Replace with:**
```javascript
    if (rn && (r.reasons_for_leaving?.code||r.reasons_for_leaving?.label||'') !== rn) return false;
    
    // Compliance filtering
    if (complianceFilter) {
      if (complianceFilter === 'compliant') {
        if (r.overall_compliant !== true) return false;
      } else if (complianceFilter === 'non-compliant') {
        if (r.overall_compliant !== false) return false;
      } else if (complianceFilter === 'pending') {
        if (r.overall_compliant !== null) return false;
      }
    }
    
    return true;
  });
```

---

### Change 6: Update Database Query
**Find this code (around line 617):**
```javascript
const { data, error } = await db.from('applications')
  .select(`id,status,submitted_at,submitted_by,edited_by,edited_at,
    date_officer_gave_notice,date_exited_service,date_submitted_to_mfed,
    date_leave_days_paid,date_submitted_to_bpopf,actual_date_paid,
```

**Replace with:**
```javascript
const { data, error } = await db.from('applications')
  .select(`id,status,submitted_at,submitted_by,edited_by,edited_at,
    date_officer_gave_notice,date_exited_service,date_submitted_to_mfed,
    date_leave_days_paid,date_submitted_to_bpopf,actual_date_paid,
    date_file_prepared,date_leave_paid,date_benefits_paid,
    days_to_file_prep,days_to_leave_payment,days_to_benefits_payment,
    file_prep_compliant,leave_payment_compliant,benefits_payment_compliant,overall_compliant,
```

---

## 📄 2. home.html Changes

### Change 1: Add Compliance KPI Section
**Find this code (around line 572):**
```html
</div>

<!-- Period filter + bar chart -->
```

**Add this BETWEEN the two lines:**
```html
</div>

<!-- Detailed Compliance KPIs -->
<div class="section-header" style="margin-top:32px">
  <div class="section-title">Compliance by Stage</div>
</div>

<div class="stats-row">
  <div class="stat-card fade-in" style="border-top-color:#166534">
    <div class="stat-icon">📋</div>
    <div class="stat-label">File Prep Compliance</div>
    <div class="stat-value" id="kpi-file-prep" style="color:#166534">—%</div>
    <div class="stat-sub">Ministry of Labour · Target: 100%</div>
  </div>
  <div class="stat-card fade-in" style="border-top-color:#92600a">
    <div class="stat-icon">💰</div>
    <div class="stat-label">Leave Payment Compliance</div>
    <div class="stat-value" id="kpi-leave-payment" style="color:#92600a">—%</div>
    <div class="stat-sub">Ministry of Finance · Target: 100%</div>
  </div>
  <div class="stat-card fade-in" style="border-top-color:#1e40af">
    <div class="stat-icon">✅</div>
    <div class="stat-label">Benefits Compliance</div>
    <div class="stat-value" id="kpi-benefits" style="color:#1e40af">—%</div>
    <div class="stat-sub">Terminal Benefits · Target: 100%</div>
  </div>
  <div class="stat-card fade-in" style="border-top-color:#c8a84b">
    <div class="stat-icon">🎯</div>
    <div class="stat-label">Overall Compliance</div>
    <div class="stat-value" id="kpi-overall" style="color:#c8a84b">—%</div>
    <div class="stat-sub">All stages combined</div>
  </div>
</div>

<!-- Period filter + bar chart -->
```

---

### Change 2: Add Compliance Metrics Function
**Find this code (around line 962):**
```javascript
// ── Load everything ───────────────────────────────────────────
async function loadDashboard() {
```

**Add this BEFORE the above code:**
```javascript
// ── Compliance Metrics ────────────────────────────────────────
async function loadComplianceMetrics() {
  const { data, error } = await db
    .from('applications')
    .select('file_prep_compliant, leave_payment_compliant, benefits_payment_compliant, overall_compliant, reasons_for_leaving(label)');
  
  if (error || !data) {
    console.error('Failed to load compliance metrics:', error);
    return;
  }
  
  // Calculate percentages for each stage
  const filePrep = data.filter(a => a.file_prep_compliant !== null);
  const filePrepRate = filePrep.length ? 
    (filePrep.filter(a => a.file_prep_compliant).length / filePrep.length * 100).toFixed(1) : 0;
  
  const leavePayment = data.filter(a => a.leave_payment_compliant !== null);
  const leavePaymentRate = leavePayment.length ?
    (leavePayment.filter(a => a.leave_payment_compliant).length / leavePayment.length * 100).toFixed(1) : 0;
  
  const benefits = data.filter(a => a.benefits_payment_compliant !== null);
  const benefitsRate = benefits.length ?
    (benefits.filter(a => a.benefits_payment_compliant).length / benefits.length * 100).toFixed(1) : 0;
  
  const overall = data.filter(a => a.overall_compliant !== null);
  const overallRate = overall.length ?
    (overall.filter(a => a.overall_compliant).length / overall.length * 100).toFixed(1) : 0;
  
  // Update KPIs
  document.getElementById('kpi-file-prep').textContent = filePrepRate + '%';
  document.getElementById('kpi-leave-payment').textContent = leavePaymentRate + '%';
  document.getElementById('kpi-benefits').textContent = benefitsRate + '%';
  document.getElementById('kpi-overall').textContent = overallRate + '%';
  
  // Color code based on performance
  const colorKPI = (id, rate) => {
    const el = document.getElementById(id);
    if (!el) return;
    el.style.color = rate >= 90 ? '#166534' : rate >= 70 ? '#92600a' : '#991b1b';
  };
  
  colorKPI('kpi-file-prep', filePrepRate);
  colorKPI('kpi-leave-payment', leavePaymentRate);
  colorKPI('kpi-benefits', benefitsRate);
  colorKPI('kpi-overall', overallRate);
}

// ── Load everything ───────────────────────────────────────────
async function loadDashboard() {
```

---

### Change 3: Call Compliance Function
**Find this code (around line 1010):**
```javascript
renderComplianceTable();
}
```

**Replace with:**
```javascript
renderComplianceTable();
loadComplianceMetrics(); // Load detailed compliance metrics
}
```

---

## 📄 3. admin.html Changes

### Change 1: Add Compliance Filter
**Find this code (around line 425):**
```html
<select class="fs" id="app-dept-filter" onchange="renderApps()">
  <!-- department options -->
</select>
<button onclick="exportPDF()"
```

**Add this BETWEEN the two elements:**
```html
</select>
<select class="fs" id="app-compliance-filter" onchange="renderApps()">
  <option value="">All Compliance</option>
  <option value="compliant">✓ Compliant</option>
  <option value="non-compliant">✗ Non-Compliant</option>
  <option value="pending">⏳ Pending</option>
</select>
<button onclick="exportPDF()"
```

---

### Change 2: Update Render Apps Function
**Find this code (around line 758):**
```javascript
function renderApps() {
  const statusF = document.getElementById('app-status-filter').value;
  const deptF   = document.getElementById('app-dept-filter').value;
  const searchQ = (document.getElementById('app-search').value || '').toLowerCase();

  const filtered = apps.filter(a => {
```

**Replace with:**
```javascript
function renderApps() {
  const statusF = document.getElementById('app-status-filter').value;
  const deptF   = document.getElementById('app-dept-filter').value;
  const searchQ = (document.getElementById('app-search').value || '').toLowerCase();
  const complianceF = document.getElementById('app-compliance-filter')?.value;

  const filtered = apps.filter(a => {
```

**Then find this code (a few lines down):**
```javascript
      if (!nm.includes(searchQ) && !(o.departments?.name||'').toLowerCase().includes(searchQ)) return false;
    }
    return true;
  });
```

**Replace with:**
```javascript
      if (!nm.includes(searchQ) && !(o.departments?.name||'').toLowerCase().includes(searchQ)) return false;
    }
    
    // Compliance filtering
    if (complianceF) {
      if (complianceF === 'compliant' && a.overall_compliant !== true) return false;
      if (complianceF === 'non-compliant' && a.overall_compliant !== false) return false;
      if (complianceF === 'pending' && a.overall_compliant !== null) return false;
    }
    
    return true;
  });
```

---

### Change 3: Add Compliance Badges
**Find this code (around line 782, in appCardHtml function):**
```javascript
const dStatus = deriveStatus(a);
const stClass = dStatus==='Paid'?'approved':'';

let actionHtml;
```

**Add this BETWEEN the two sections:**
```javascript
const dStatus = deriveStatus(a);
const stClass = dStatus==='Paid'?'approved':'';

// Compliance badges
let complianceBadges = '';
if (a.file_prep_compliant !== null || a.leave_payment_compliant !== null || a.benefits_payment_compliant !== null) {
  complianceBadges = '<div style="display:flex;gap:6px;margin-top:8px;flex-wrap:wrap">';
  
  if (a.file_prep_compliant !== null) {
    const color = a.file_prep_compliant ? '#dcfce7' : '#fee2e2';
    const text = a.file_prep_compliant ? '#166534' : '#991b1b';
    complianceBadges += `<span style="background:${color};color:${text};padding:2px 8px;font-size:0.7rem;font-weight:700;border-radius:2px">
      ${a.file_prep_compliant ? '✓' : '✗'} File Prep
    </span>`;
  }
  
  if (a.leave_payment_compliant !== null) {
    const color = a.leave_payment_compliant ? '#dcfce7' : '#fee2e2';
    const text = a.leave_payment_compliant ? '#166534' : '#991b1b';
    complianceBadges += `<span style="background:${color};color:${text};padding:2px 8px;font-size:0.7rem;font-weight:700;border-radius:2px">
      ${a.leave_payment_compliant ? '✓' : '✗'} Leave Pay
    </span>`;
  }
  
  if (a.benefits_payment_compliant !== null) {
    const color = a.benefits_payment_compliant ? '#dcfce7' : '#fee2e2';
    const text = a.benefits_payment_compliant ? '#166534' : '#991b1b';
    complianceBadges += `<span style="background:${color};color:${text};padding:2px 8px;font-size:0.7rem;font-weight:700;border-radius:2px">
      ${a.benefits_payment_compliant ? '✓' : '✗'} Benefits
    </span>`;
  }
  
  complianceBadges += '</div>';
}

let actionHtml;
```

**Then find this code (in the return statement):**
```html
<div class="app-meta">
  <span class="app-meta-item">🏛 <strong>${dp.name||dp.code||'—'}</strong></span>
  <!-- ... more items ... -->
</div>
<div class="app-dates">
```

**Add the badges BETWEEN the two divs:**
```html
</div>
${complianceBadges}
<div class="app-dates">
```

---

### Change 4: Update Database Query
**Find this code (around line 745):**
```javascript
const { data, error } = await db.from('applications')
  .select(`id,status,submitted_at,submitted_by,edited_by,edited_at,comments,tpt,
    date_officer_gave_notice,actual_date_paid,total_processing_days,
```

**Replace with:**
```javascript
const { data, error } = await db.from('applications')
  .select(`id,status,submitted_at,submitted_by,edited_by,edited_at,comments,tpt,
    date_officer_gave_notice,actual_date_paid,total_processing_days,
    file_prep_compliant,leave_payment_compliant,benefits_payment_compliant,overall_compliant,
```

---

## ✅ Done!

After applying all changes:
1. Save all files
2. Upload to GitHub
3. Test each page
4. Verify compliance tracking works

