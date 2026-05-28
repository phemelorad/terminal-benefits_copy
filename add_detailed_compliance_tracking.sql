-- ============================================================
--  Add Detailed Compliance Tracking
--  Ministry of Labour Terminal Benefits System
--  Run in Supabase SQL Editor
-- ============================================================

-- 1. Add new date fields to applications table
-- ============================================================

ALTER TABLE applications
  ADD COLUMN IF NOT EXISTS date_file_prepared DATE,
  ADD COLUMN IF NOT EXISTS date_leave_paid DATE,
  ADD COLUMN IF NOT EXISTS date_benefits_paid DATE;

-- Add compliance tracking fields
ALTER TABLE applications
  ADD COLUMN IF NOT EXISTS days_to_file_prep INTEGER,
  ADD COLUMN IF NOT EXISTS days_to_leave_payment INTEGER,
  ADD COLUMN IF NOT EXISTS days_to_benefits_payment INTEGER,
  ADD COLUMN IF NOT EXISTS file_prep_compliant BOOLEAN,
  ADD COLUMN IF NOT EXISTS leave_payment_compliant BOOLEAN,
  ADD COLUMN IF NOT EXISTS benefits_payment_compliant BOOLEAN,
  ADD COLUMN IF NOT EXISTS overall_compliant BOOLEAN;

-- 2. Create function to calculate compliance based on reason
-- ============================================================

CREATE OR REPLACE FUNCTION calculate_compliance_metrics()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_reason TEXT;
  v_start_date DATE;
  v_file_prep_standard INTEGER;
  v_leave_payment_standard INTEGER;
  v_benefits_payment_standard INTEGER;
BEGIN
  -- Get reason for leaving
  SELECT label INTO v_reason 
  FROM reasons_for_leaving 
  WHERE id = NEW.reason_id;

  -- Determine start date (notice date or exit date for death)
  IF v_reason = 'Death' THEN
    v_start_date := NEW.date_exited_service;
  ELSE
    v_start_date := NEW.date_officer_gave_notice;
  END IF;

  -- Set compliance standards based on reason
  IF v_reason IN ('Retirement', 'Resignation', 'End of Contract', 'Compulsory Retirement') THEN
    v_file_prep_standard := 10;
    v_leave_payment_standard := 10;
    v_benefits_payment_standard := 25;
  ELSIF v_reason = 'Death' THEN
    v_file_prep_standard := 20;
    v_leave_payment_standard := NULL; -- No leave payment for death
    v_benefits_payment_standard := 85;
  ELSE
    -- Default for other reasons (Dismissal, etc.)
    v_file_prep_standard := 10;
    v_leave_payment_standard := 10;
    v_benefits_payment_standard := 25;
  END IF;

  -- Calculate days to file preparation
  IF NEW.date_file_prepared IS NOT NULL AND v_start_date IS NOT NULL THEN
    NEW.days_to_file_prep := NEW.date_file_prepared - v_start_date;
    NEW.file_prep_compliant := NEW.days_to_file_prep <= v_file_prep_standard;
  ELSE
    NEW.days_to_file_prep := NULL;
    NEW.file_prep_compliant := NULL;
  END IF;

  -- Calculate days to leave payment (not applicable for death)
  IF v_reason != 'Death' AND NEW.date_leave_paid IS NOT NULL AND v_start_date IS NOT NULL THEN
    NEW.days_to_leave_payment := NEW.date_leave_paid - v_start_date;
    NEW.leave_payment_compliant := NEW.days_to_leave_payment <= v_leave_payment_standard;
  ELSE
    NEW.days_to_leave_payment := NULL;
    NEW.leave_payment_compliant := NULL;
  END IF;

  -- Calculate days to benefits payment
  IF NEW.date_benefits_paid IS NOT NULL AND v_start_date IS NOT NULL THEN
    NEW.days_to_benefits_payment := NEW.date_benefits_paid - v_start_date;
    NEW.benefits_payment_compliant := NEW.days_to_benefits_payment <= v_benefits_payment_standard;
  ELSE
    NEW.days_to_benefits_payment := NULL;
    NEW.benefits_payment_compliant := NULL;
  END IF;

  -- Calculate overall compliance
  -- All completed stages must be compliant
  IF v_reason = 'Death' THEN
    -- For death: file prep + benefits payment
    NEW.overall_compliant := 
      COALESCE(NEW.file_prep_compliant, true) AND 
      COALESCE(NEW.benefits_payment_compliant, true);
  ELSE
    -- For others: file prep + leave payment + benefits payment
    NEW.overall_compliant := 
      COALESCE(NEW.file_prep_compliant, true) AND 
      COALESCE(NEW.leave_payment_compliant, true) AND 
      COALESCE(NEW.benefits_payment_compliant, true);
  END IF;

  RETURN NEW;
END;
$$;

-- 3. Create trigger to auto-calculate compliance
-- ============================================================

DROP TRIGGER IF EXISTS calculate_compliance_trigger ON applications;

CREATE TRIGGER calculate_compliance_trigger
  BEFORE INSERT OR UPDATE ON applications
  FOR EACH ROW
  EXECUTE FUNCTION calculate_compliance_metrics();

-- 4. Update existing records with compliance calculations
-- ============================================================

-- Map existing date fields to new structure
UPDATE applications
SET 
  date_file_prepared = date_submitted_to_mfed,
  date_leave_paid = date_leave_days_paid,
  date_benefits_paid = actual_date_paid
WHERE date_file_prepared IS NULL;

-- Trigger will auto-calculate compliance on next update
-- Force recalculation by updating the status field
UPDATE applications
SET status = status
WHERE id IS NOT NULL;

-- 5. Create view for compliance dashboard
-- ============================================================

CREATE OR REPLACE VIEW compliance_dashboard AS
SELECT 
  r.label as reason,
  COUNT(*) as total_applications,
  
  -- File Preparation Compliance
  COUNT(CASE WHEN a.file_prep_compliant = true THEN 1 END) as file_prep_compliant_count,
  ROUND(100.0 * COUNT(CASE WHEN a.file_prep_compliant = true THEN 1 END) / 
    NULLIF(COUNT(CASE WHEN a.date_file_prepared IS NOT NULL THEN 1 END), 0), 1) as file_prep_compliance_rate,
  AVG(CASE WHEN a.days_to_file_prep IS NOT NULL THEN a.days_to_file_prep END) as avg_days_file_prep,
  
  -- Leave Payment Compliance (excluding death)
  COUNT(CASE WHEN a.leave_payment_compliant = true THEN 1 END) as leave_payment_compliant_count,
  ROUND(100.0 * COUNT(CASE WHEN a.leave_payment_compliant = true THEN 1 END) / 
    NULLIF(COUNT(CASE WHEN a.date_leave_paid IS NOT NULL AND r.label != 'Death' THEN 1 END), 0), 1) as leave_payment_compliance_rate,
  AVG(CASE WHEN a.days_to_leave_payment IS NOT NULL THEN a.days_to_leave_payment END) as avg_days_leave_payment,
  
  -- Benefits Payment Compliance
  COUNT(CASE WHEN a.benefits_payment_compliant = true THEN 1 END) as benefits_compliant_count,
  ROUND(100.0 * COUNT(CASE WHEN a.benefits_payment_compliant = true THEN 1 END) / 
    NULLIF(COUNT(CASE WHEN a.date_benefits_paid IS NOT NULL THEN 1 END), 0), 1) as benefits_compliance_rate,
  AVG(CASE WHEN a.days_to_benefits_payment IS NOT NULL THEN a.days_to_benefits_payment END) as avg_days_benefits_payment,
  
  -- Overall Compliance
  COUNT(CASE WHEN a.overall_compliant = true THEN 1 END) as overall_compliant_count,
  ROUND(100.0 * COUNT(CASE WHEN a.overall_compliant = true THEN 1 END) / 
    NULLIF(COUNT(CASE WHEN a.date_benefits_paid IS NOT NULL THEN 1 END), 0), 1) as overall_compliance_rate

FROM applications a
LEFT JOIN reasons_for_leaving r ON a.reason_id = r.id
GROUP BY r.label
ORDER BY r.label;

-- 6. Grant permissions
-- ============================================================

GRANT SELECT ON compliance_dashboard TO authenticated;

-- 7. Verification
-- ============================================================

-- Check the new fields
SELECT 
  id,
  date_officer_gave_notice,
  date_file_prepared,
  days_to_file_prep,
  file_prep_compliant,
  date_leave_paid,
  days_to_leave_payment,
  leave_payment_compliant,
  date_benefits_paid,
  days_to_benefits_payment,
  benefits_payment_compliant,
  overall_compliant
FROM applications
LIMIT 5;

-- Check compliance dashboard
SELECT * FROM compliance_dashboard;

-- ============================================================
-- DONE! Now update your HTML forms to include these new fields
-- ============================================================
