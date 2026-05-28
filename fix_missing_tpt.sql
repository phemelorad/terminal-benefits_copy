-- Fix Missing TPT Values
-- This script calculates and updates TPT for entries that have dates but missing TPT

-- Update TPT for entries that have both date_exited_service and actual_date_paid but TPT is NULL
UPDATE applications
SET tpt = EXTRACT(DAY FROM (actual_date_paid::timestamp - date_exited_service::timestamp))
WHERE date_exited_service IS NOT NULL
  AND actual_date_paid IS NOT NULL
  AND (tpt IS NULL OR tpt::text = '');

-- Verify the update
SELECT 
  id,
  date_exited_service,
  actual_date_paid,
  tpt,
  EXTRACT(DAY FROM (actual_date_paid::timestamp - date_exited_service::timestamp)) as calculated_tpt
FROM applications
WHERE date_exited_service IS NOT NULL
  AND actual_date_paid IS NOT NULL
ORDER BY id DESC
LIMIT 20;
