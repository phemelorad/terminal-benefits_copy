-- ============================================================
--  Insert 20 Dummy Entries for Tracking Indicators Testing
--  Ministry of Labour Terminal Benefits System
--  Run in Supabase SQL Editor
-- ============================================================

-- Note: Replace officer_id and reason_id with actual IDs from your database
-- Get officer IDs: SELECT id, first_name, surname FROM officers LIMIT 5;
-- Get reason IDs: SELECT id, label FROM reasons_for_leaving;

-- Reason IDs based on your database:
-- 1 = Retirement
-- 2 = Resignation  
-- 3 = Dismissal
-- 4 = Death
-- 5 = End of Contract
-- 6 = Compulsory Retirement

-- Standards:
-- Retirement/Resignation/Dismissal/End of Contract/Compulsory Retirement: 10, 10, 25 days
-- Death: 20, N/A, 85 days

-- ============================================================
-- MAY 2026 ENTRIES (Current Month - 10 entries)
-- ============================================================

-- Entry 1: Retirement - All stages compliant
INSERT INTO applications (
  officer_id, reason_id, status, submitted_location,
  date_officer_gave_notice, date_exited_service, 
  date_submitted_to_mfed, date_leave_days_paid, 
  date_submitted_to_bpopf, actual_date_paid,
  submitted_at, submitted_by
) VALUES (
  1, 1, 'paid', 'Gaborone',
  '2026-04-01', '2026-04-30',
  '2026-05-05', '2026-05-12',
  '2026-05-15', '2026-05-30',
  '2026-05-01', 1
);

-- Entry 2: Retirement - File prep non-compliant (15 days)
INSERT INTO applications (
  officer_id, reason_id, status, submitted_location,
  date_officer_gave_notice, date_exited_service, 
  date_submitted_to_mfed, date_leave_days_paid, 
  date_submitted_to_bpopf, actual_date_paid,
  submitted_at, submitted_by
) VALUES (
  1, 1, 'paid', 'Francistown',
  '2026-04-05', '2026-05-05',
  '2026-05-20', '2026-05-28',
  '2026-06-02', '2026-06-15',
  '2026-05-02', 1
);

-- Entry 3: Resignation - All compliant
INSERT INTO applications (
  officer_id, reason_id, status, submitted_location,
  date_officer_gave_notice, date_exited_service, 
  date_submitted_to_mfed, date_leave_days_paid, 
  date_submitted_to_bpopf, actual_date_paid,
  submitted_at, submitted_by
) VALUES (
  1, 2, 'paid', 'Maun',
  '2026-04-10', '2026-05-10',
  '2026-05-18', '2026-05-25',
  '2026-05-28', '2026-06-10',
  '2026-05-03', 1
);

-- Entry 4: Death - File prep compliant (18 days), benefits compliant
INSERT INTO applications (
  officer_id, reason_id, status, submitted_location,
  date_officer_gave_notice, date_exited_service, 
  date_submitted_to_mfed, date_leave_days_paid, 
  date_submitted_to_bpopf, actual_date_paid,
  submitted_at, submitted_by
) VALUES (
  1, 4, 'paid', 'Gaborone',
  NULL, '2026-05-01',
  '2026-05-19', NULL,
  '2026-05-22', '2026-07-15',
  '2026-05-04', 1
);

-- Entry 5: Retirement - Leave payment non-compliant (15 days)
INSERT INTO applications (
  officer_id, reason_id, status, submitted_location,
  date_officer_gave_notice, date_exited_service, 
  date_submitted_to_mfed, date_leave_days_paid, 
  date_submitted_to_bpopf, actual_date_paid,
  submitted_at, submitted_by
) VALUES (
  1, 1, 'paid', 'Lobatse',
  '2026-04-15', '2026-05-15',
  '2026-05-22', '2026-06-05',
  '2026-06-08', '2026-06-25',
  '2026-05-05', 1
);

-- Entry 6: Retirement - Benefits payment non-compliant (30 days)
INSERT INTO applications (
  officer_id, reason_id, status, submitted_location,
  date_officer_gave_notice, date_exited_service, 
  date_submitted_to_mfed, date_leave_days_paid, 
  date_submitted_to_bpopf, actual_date_paid,
  submitted_at, submitted_by
) VALUES (
  1, 1, 'paid', 'Gaborone',
  '2026-04-20', '2026-05-20',
  '2026-05-28', '2026-06-05',
  '2026-06-08', '2026-07-10',
  '2026-05-06', 1
);

-- Entry 7: Death - File prep non-compliant (25 days)
INSERT INTO applications (
  officer_id, reason_id, status, submitted_location,
  date_officer_gave_notice, date_exited_service, 
  date_submitted_to_mfed, date_leave_days_paid, 
  date_submitted_to_bpopf, actual_date_paid,
  submitted_at, submitted_by
) VALUES (
  1, 4, 'paid', 'Francistown',
  NULL, '2026-05-05',
  '2026-05-30', NULL,
  '2026-06-02', '2026-08-20',
  '2026-05-07', 1
);

-- Entry 8: End of Contract - Pending (no dates yet)
INSERT INTO applications (
  officer_id, reason_id, status, submitted_location,
  date_officer_gave_notice, date_exited_service, 
  date_submitted_to_mfed, date_leave_days_paid, 
  date_submitted_to_bpopf, actual_date_paid,
  submitted_at, submitted_by
) VALUES (
  1, 5, 'pending', 'Maun',
  '2026-05-01', '2026-05-31',
  NULL, NULL,
  NULL, NULL,
  '2026-05-08', 1
);

-- Entry 9: Dismissal - All compliant
INSERT INTO applications (
  officer_id, reason_id, status, submitted_location,
  date_officer_gave_notice, date_exited_service, 
  date_submitted_to_mfed, date_leave_days_paid, 
  date_submitted_to_bpopf, actual_date_paid,
  submitted_at, submitted_by
) VALUES (
  1, 3, 'paid', 'Gaborone',
  '2026-05-05', '2026-05-25',
  '2026-06-02', '2026-06-10',
  '2026-06-12', '2026-07-05',
  '2026-05-09', 1
);

-- Entry 10: Compulsory Retirement - Awaiting approval
INSERT INTO applications (
  officer_id, reason_id, status, submitted_location,
  date_officer_gave_notice, date_exited_service, 
  date_submitted_to_mfed, date_leave_days_paid, 
  date_submitted_to_bpopf, actual_date_paid,
  submitted_at, submitted_by
) VALUES (
  1, 6, 'awaiting_approval', 'Lobatse',
  '2026-05-10', '2026-05-30',
  '2026-06-05', NULL,
  NULL, NULL,
  '2026-05-10', 1
);

-- ============================================================
-- APRIL 2026 ENTRIES (Previous Month - 6 entries)
-- ============================================================

-- Entry 11: Retirement - All compliant
INSERT INTO applications (
  officer_id, reason_id, status, submitted_location,
  date_officer_gave_notice, date_exited_service, 
  date_submitted_to_mfed, date_leave_days_paid, 
  date_submitted_to_bpopf, actual_date_paid,
  submitted_at, submitted_by
) VALUES (
  1, 1, 'paid', 'Gaborone',
  '2026-03-01', '2026-03-31',
  '2026-04-08', '2026-04-15',
  '2026-04-18', '2026-05-05',
  '2026-04-01', 1
);

-- Entry 12: Death - All compliant
INSERT INTO applications (
  officer_id, reason_id, status, submitted_location,
  date_officer_gave_notice, date_exited_service, 
  date_submitted_to_mfed, date_leave_days_paid, 
  date_submitted_to_bpopf, actual_date_paid,
  submitted_at, submitted_by
) VALUES (
  1, 4, 'paid', 'Francistown',
  NULL, '2026-04-01',
  '2026-04-18', NULL,
  '2026-04-20', '2026-06-15',
  '2026-04-05', 1
);

-- Entry 13: Retirement - File prep non-compliant
INSERT INTO applications (
  officer_id, reason_id, status, submitted_location,
  date_officer_gave_notice, date_exited_service, 
  date_submitted_to_mfed, date_leave_days_paid, 
  date_submitted_to_bpopf, actual_date_paid,
  submitted_at, submitted_by
) VALUES (
  1, 1, 'paid', 'Maun',
  '2026-03-10', '2026-04-10',
  '2026-04-25', '2026-05-02',
  '2026-05-05', '2026-05-20',
  '2026-04-10', 1
);

-- Entry 14: Resignation - All compliant
INSERT INTO applications (
  officer_id, reason_id, status, submitted_location,
  date_officer_gave_notice, date_exited_service, 
  date_submitted_to_mfed, date_leave_days_paid, 
  date_submitted_to_bpopf, actual_date_paid,
  submitted_at, submitted_by
) VALUES (
  1, 2, 'paid', 'Gaborone',
  '2026-03-15', '2026-04-15',
  '2026-04-22', '2026-04-28',
  '2026-05-01', '2026-05-15',
  '2026-04-15', 1
);

-- Entry 15: Retirement - Benefits payment non-compliant
INSERT INTO applications (
  officer_id, reason_id, status, submitted_location,
  date_officer_gave_notice, date_exited_service, 
  date_submitted_to_mfed, date_leave_days_paid, 
  date_submitted_to_bpopf, actual_date_paid,
  submitted_at, submitted_by
) VALUES (
  1, 1, 'paid', 'Lobatse',
  '2026-03-20', '2026-04-20',
  '2026-04-28', '2026-05-05',
  '2026-05-08', '2026-06-10',
  '2026-04-20', 1
);

-- Entry 16: Death - Benefits payment non-compliant (90 days)
INSERT INTO applications (
  officer_id, reason_id, status, submitted_location,
  date_officer_gave_notice, date_exited_service, 
  date_submitted_to_mfed, date_leave_days_paid, 
  date_submitted_to_bpopf, actual_date_paid,
  submitted_at, submitted_by
) VALUES (
  1, 4, 'paid', 'Francistown',
  NULL, '2026-04-05',
  '2026-04-22', NULL,
  '2026-04-25', '2026-07-10',
  '2026-04-25', 1
);

-- ============================================================
-- MARCH 2026 ENTRIES (2 months ago - 4 entries)
-- ============================================================

-- Entry 17: Retirement - All compliant
INSERT INTO applications (
  officer_id, reason_id, status, submitted_location,
  date_officer_gave_notice, date_exited_service, 
  date_submitted_to_mfed, date_leave_days_paid, 
  date_submitted_to_bpopf, actual_date_paid,
  submitted_at, submitted_by
) VALUES (
  1, 1, 'paid', 'Gaborone',
  '2026-02-01', '2026-02-28',
  '2026-03-08', '2026-03-15',
  '2026-03-18', '2026-04-05',
  '2026-03-01', 1
);

-- Entry 18: End of Contract - All compliant
INSERT INTO applications (
  officer_id, reason_id, status, submitted_location,
  date_officer_gave_notice, date_exited_service, 
  date_submitted_to_mfed, date_leave_days_paid, 
  date_submitted_to_bpopf, actual_date_paid,
  submitted_at, submitted_by
) VALUES (
  1, 5, 'paid', 'Maun',
  '2026-02-10', '2026-03-10',
  '2026-03-18', '2026-03-25',
  '2026-03-28', '2026-04-15',
  '2026-03-10', 1
);

-- Entry 19: Death - File prep non-compliant (22 days)
INSERT INTO applications (
  officer_id, reason_id, status, submitted_location,
  date_officer_gave_notice, date_exited_service, 
  date_submitted_to_mfed, date_leave_days_paid, 
  date_submitted_to_bpopf, actual_date_paid,
  submitted_at, submitted_by
) VALUES (
  1, 4, 'paid', 'Francistown',
  NULL, '2026-03-01',
  '2026-03-23', NULL,
  '2026-03-25', '2026-05-20',
  '2026-03-15', 1
);

-- Entry 20: Retirement - Leave payment non-compliant
INSERT INTO applications (
  officer_id, reason_id, status, submitted_location,
  date_officer_gave_notice, date_exited_service, 
  date_submitted_to_mfed, date_leave_days_paid, 
  date_submitted_to_bpopf, actual_date_paid,
  submitted_at, submitted_by
) VALUES (
  1, 1, 'paid', 'Lobatse',
  '2026-02-15', '2026-03-15',
  '2026-03-22', '2026-04-08',
  '2026-04-10', '2026-04-28',
  '2026-03-20', 1
);

-- ============================================================
-- VERIFICATION QUERIES
-- ============================================================

-- Check inserted data
SELECT 
  id,
  submitted_at,
  date_exited_service,
  date_submitted_to_mfed,
  date_leave_days_paid,
  date_submitted_to_bpopf,
  actual_date_paid,
  status
FROM applications
WHERE submitted_at >= '2026-03-01'
ORDER BY submitted_at DESC;

-- Check compliance calculations (should be auto-calculated by trigger)
SELECT 
  id,
  submitted_at,
  days_to_file_prep,
  file_prep_compliant,
  days_to_leave_payment,
  leave_payment_compliant,
  days_to_benefits_payment,
  benefits_payment_compliant,
  overall_compliant
FROM applications
WHERE submitted_at >= '2026-03-01'
ORDER BY submitted_at DESC;

-- Summary by month
SELECT 
  TO_CHAR(submitted_at, 'YYYY-MM') as month,
  COUNT(*) as total,
  COUNT(CASE WHEN file_prep_compliant = true THEN 1 END) as file_prep_ok,
  COUNT(CASE WHEN leave_payment_compliant = true THEN 1 END) as leave_payment_ok,
  COUNT(CASE WHEN benefits_payment_compliant = true THEN 1 END) as benefits_ok
FROM applications
WHERE submitted_at >= '2026-03-01'
GROUP BY TO_CHAR(submitted_at, 'YYYY-MM')
ORDER BY month DESC;

-- ============================================================
-- NOTES:
-- 1. Adjust officer_id and reason_id based on your database
-- 2. The trigger should auto-calculate compliance fields
-- 3. If compliance fields are NULL, run: UPDATE applications SET status = status;
-- ============================================================
