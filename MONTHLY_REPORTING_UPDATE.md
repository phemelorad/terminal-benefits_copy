# Monthly Reporting Update - home.html

## Summary
Updated `home.html` to display only current month data for all main visuals and metrics, enabling true monthly reporting as requested.

## Changes Made

### 1. Added Current Month Filter Function
- Created `getCurrentMonthApps()` function that filters `allApps` to only include entries from the current month
- Uses format: `YYYY-MM` to match against `submitted_at` field

### 2. Updated Banner Display
- Modified "Terminal Benefits Overview" heading to show current month/year in gold color
- Format: "Terminal Benefits Overview — May 2026"
- Updates automatically via `updateClock()` function

### 3. Updated Statistics Cards (Top Row)
- **Total Applications**: Shows count for current month only
- **Compliant**: Shows compliant count for current month
- **Non-Compliant**: Shows non-compliant count for current month  
- **Pending/In Progress**: Shows pending count for current month
- Sub-label now shows "May 2026" instead of "All time"

### 4. Updated Ministry Compliance Target Meter
- Calculates compliance rate based on current month entries only
- Shows percentage of compliant applications this month

### 5. Updated Compliance Metrics (KPI Cards)
- **% Compliance: File Prep at MDA**: Calculated from current month entries only
- **% Compliance: Leave Payment by MFED**: Calculated from current month entries only
- Both metrics query delay fields only for current month application IDs
- Color coding: Green (≥90%), Amber (70-89%), Red (<70%)

### 6. Updated Bar Chart (Day View)
- Changed from "last 14 days" to "current month by day"
- Shows all days of the current month (1-28/29/30/31)
- Month and Year views remain unchanged (show historical trends)

### 7. Updated Compliance Gauge (Doughnut Chart)
- Shows compliant/non-compliant/pending breakdown for current month only
- Percentage and counts reflect current month data

### 8. Updated Department Compliance Bars
- Shows compliance rates per department for current month entries only

### 9. Updated Recent Entries Table
- Shows most recent 5 entries from current month

### 10. Updated Reason for Leaving Chart
- Shows distribution of reasons for current month entries only

### 11. Updated Location Charts
- Both compliance rate and average TPT charts show current month data only

## What Remains Unchanged (Intentionally)

The following sections continue to show **all-time/historical data** as they are designed for trend analysis:

1. **Bar Chart - Month View**: Shows last 12 months trend
2. **Bar Chart - Year View**: Shows all years trend
3. **Compliance Tables**: Monthly and yearly compliance tables show historical data with year filter

## Technical Implementation

### Key Function Changes:
- `getCurrentMonthApps()`: New helper function
- `loadComplianceMetrics()`: Filters by current month IDs
- `renderStats()`: Uses `getCurrentMonthApps()`
- `renderBarChart()`: Day view uses current month
- `renderGauge()`: Uses `getCurrentMonthApps()`
- `renderDeptCompliance()`: Uses `getCurrentMonthApps()`
- `renderRecentTable()`: Uses `getCurrentMonthApps()`
- `renderReasonChart()`: Uses `getCurrentMonthApps()`
- `renderLocationCharts()`: Uses `getCurrentMonthApps()`
- `updateClock()`: Updates month/year in banner

## User Experience

When users open the home dashboard:
- They immediately see the current month/year in the banner (e.g., "May 2026")
- All statistics reflect only this month's entries
- All charts and visuals show current month performance
- This enables true monthly reporting and performance tracking
- Historical trends are still available via the bar chart's month/year views and compliance tables

## Testing Recommendations

1. Verify current month/year displays correctly in banner
2. Check that all stat cards show current month counts
3. Confirm compliance metrics calculate correctly for current month
4. Test bar chart day view shows all days of current month
5. Verify gauge shows current month breakdown
6. Check department compliance uses current month data
7. Confirm recent table shows current month entries
8. Test at month boundaries (last day of month, first day of new month)
