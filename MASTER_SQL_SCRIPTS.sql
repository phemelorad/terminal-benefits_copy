-- ══════════════════════════════════════════════════════════════════════════════
-- MASTER SQL SCRIPTS
-- Ministry of Labour Terminal Benefits System
-- All SQL scripts consolidated in one file
-- Run in Supabase SQL Editor
-- ══════════════════════════════════════════════════════════════════════════════
-- 
-- TABLE OF CONTENTS:
-- 1. Create Super Admin
-- 2. Add Detailed Compliance Tracking
-- 3. Fix Missing TPT Values
-- 4. Fix Role Update Tracking
-- 5. Update get_all_user_profiles Function
-- 6. Check and Fix RLS Policies for Role Updates
-- 7. Fix Admin SELECT Policy
-- 8. Fix Notifications for Super Admin
-- 9. Insert Dummy Tracking Data (Testing)
--
-- ══════════════════════════════════════════════════════════════════════════════




-- ══════════════════════════════════════════════════════════════════════════════
-- 1. CREATE SUPER ADMIN
-- ══════════════════════════════════════════════════════════════════════════════
-- Purpose: Protects super admin account from deletion and role changes
-- Run this first to set up super admin role
-- ══════════════════════════════════════════════════════════════════════════════

-- Add super_admin role to the role check constraint
ALTER TABLE user_profiles
  DROP CONSTRAINT IF EXISTS user_profiles_role_check;

ALTER TABLE user_profiles
  ADD CONSTRAINT user_profiles_role_check
  CHECK (role IN ('super_admin', 'admin', 'officer', 'viewer'));

-- Set your account as super_admin (REPLACE WITH YOUR USER ID)
UPDATE user_profiles
SET role = 'super_admin'
WHERE id = '082ccf13-179d-431c-ac4a-dc0d798de7f6';

-- Protect super_admin from deletion by regular admins
DROP POLICY IF EXISTS "Admins can delete profiles" ON user_profiles;

CREATE POLICY "Admins can delete profiles"
  ON user_profiles FOR DELETE
  USING (
    get_my_role() IN ('admin', 'super_admin')
    AND
    (role != 'super_admin' OR get_my_role() = 'super_admin')
    AND
    id != auth.uid()
  );

-- Protect super_admin role from being changed by regular admins
DROP POLICY IF EXISTS "Admins can update profiles" ON user_profiles;

CREATE POLICY "Admins can update profiles"
  ON user_profiles FOR UPDATE
  USING (
    auth.uid() = id
    OR get_my_role() IN ('admin', 'super_admin')
  )
  WITH CHECK (
    CASE
      WHEN get_my_role() = 'super_admin' THEN true
      WHEN get_my_role() = 'admin' AND role = 'super_admin' THEN false
      WHEN get_my_role() = 'admin' AND (SELECT role FROM user_profiles WHERE id = user_profiles.id) = 'super_admin' THEN false
      WHEN get_my_role() = 'admin' THEN true
      ELSE auth.uid() = id AND role = (SELECT role FROM user_profiles WHERE id = auth.uid())
    END
  );

-- Update get_my_role to return super_admin correctly
CREATE OR REPLACE FUNCTION get_my_role()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE v_role TEXT;
BEGIN
  SELECT role INTO v_role FROM user_profiles WHERE id = auth.uid();
  RETURN COALESCE(v_role, 'viewer');
END;
$$;

-- Verify
SELECT id, full_name, role, is_active
FROM user_profiles
WHERE role = 'super_admin';




-- ══════════════════════════════════════════════════════════════════════════════
-- 2. ADD DETAILED COMPLIANCE TRACKING
-- ══════════════════════════════════════════════════════════════════════════════
-- Purpose: Adds compliance tracking fields and auto-calculation
-- Standards: Retirement (10/10/25 days), Death (20/N/A/85 days)
-- ══════════════════════════════════════════════════════════════════════════════

-- Add new date fields to applications table
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

-- Create function to calculate compliance based on reason
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
  SELECT label INTO v_reason 
  FROM reasons_for_leaving 
  WHERE id = NEW.reason_id;

  IF v_reason = 'Death' THEN
    v_start_date := NEW.date_exited_service;
  ELSE
    v_start_date := NEW.date_officer_gave_notice;
  END IF;

  IF v_reason IN ('Retirement', 'Resignation', 'End of Contract', 'Compulsory Retirement') THEN
    v_file_prep_standard := 10;
    v_leave_payment_standard := 10;
    v_benefits_payment_standard := 25;
  ELSIF v_reason = 'Death' THEN
    v_file_prep_standard := 20;
    v_leave_payment_standard := NULL;
    v_benefits_payment_standard := 85;
  ELSE
    v_file_prep_standard := 10;
    v_leave_payment_standard := 10;
    v_benefits_payment_standard := 25;
  END IF;

  IF NEW.date_file_prepared IS NOT NULL AND v_start_date IS NOT NULL THEN
    NEW.days_to_file_prep := NEW.date_file_prepared - v_start_date;
    NEW.file_prep_compliant := NEW.days_to_file_prep <= v_file_prep_standard;
  ELSE
    NEW.days_to_file_prep := NULL;
    NEW.file_prep_compliant := NULL;
  END IF;

  IF v_reason != 'Death' AND NEW.date_leave_paid IS NOT NULL AND v_start_date IS NOT NULL THEN
    NEW.days_to_leave_payment := NEW.date_leave_paid - v_start_date;
    NEW.leave_payment_compliant := NEW.days_to_leave_payment <= v_leave_payment_standard;
  ELSE
    NEW.days_to_leave_payment := NULL;
    NEW.leave_payment_compliant := NULL;
  END IF;

  IF NEW.date_benefits_paid IS NOT NULL AND v_start_date IS NOT NULL THEN
    NEW.days_to_benefits_payment := NEW.date_benefits_paid - v_start_date;
    NEW.benefits_payment_compliant := NEW.days_to_benefits_payment <= v_benefits_payment_standard;
  ELSE
    NEW.days_to_benefits_payment := NULL;
    NEW.benefits_payment_compliant := NULL;
  END IF;

  IF v_reason = 'Death' THEN
    NEW.overall_compliant := 
      COALESCE(NEW.file_prep_compliant, true) AND 
      COALESCE(NEW.benefits_payment_compliant, true);
  ELSE
    NEW.overall_compliant := 
      COALESCE(NEW.file_prep_compliant, true) AND 
      COALESCE(NEW.leave_payment_compliant, true) AND 
      COALESCE(NEW.benefits_payment_compliant, true);
  END IF;

  RETURN NEW;
END;
$$;

-- Create trigger to auto-calculate compliance
DROP TRIGGER IF EXISTS calculate_compliance_trigger ON applications;

CREATE TRIGGER calculate_compliance_trigger
  BEFORE INSERT OR UPDATE ON applications
  FOR EACH ROW
  EXECUTE FUNCTION calculate_compliance_metrics();

-- Map existing date fields to new structure
UPDATE applications
SET 
  date_file_prepared = date_submitted_to_mfed,
  date_leave_paid = date_leave_days_paid,
  date_benefits_paid = actual_date_paid
WHERE date_file_prepared IS NULL;

-- Force recalculation
UPDATE applications
SET status = status
WHERE id IS NOT NULL;

-- Create compliance dashboard view
CREATE OR REPLACE VIEW compliance_dashboard AS
SELECT 
  r.label as reason,
  COUNT(*) as total_applications,
  COUNT(CASE WHEN a.file_prep_compliant = true THEN 1 END) as file_prep_compliant_count,
  ROUND(100.0 * COUNT(CASE WHEN a.file_prep_compliant = true THEN 1 END) / 
    NULLIF(COUNT(CASE WHEN a.date_file_prepared IS NOT NULL THEN 1 END), 0), 1) as file_prep_compliance_rate,
  AVG(CASE WHEN a.days_to_file_prep IS NOT NULL THEN a.days_to_file_prep END) as avg_days_file_prep,
  COUNT(CASE WHEN a.leave_payment_compliant = true THEN 1 END) as leave_payment_compliant_count,
  ROUND(100.0 * COUNT(CASE WHEN a.leave_payment_compliant = true THEN 1 END) / 
    NULLIF(COUNT(CASE WHEN a.date_leave_paid IS NOT NULL AND r.label != 'Death' THEN 1 END), 0), 1) as leave_payment_compliance_rate,
  AVG(CASE WHEN a.days_to_leave_payment IS NOT NULL THEN a.days_to_leave_payment END) as avg_days_leave_payment,
  COUNT(CASE WHEN a.benefits_payment_compliant = true THEN 1 END) as benefits_compliant_count,
  ROUND(100.0 * COUNT(CASE WHEN a.benefits_payment_compliant = true THEN 1 END) / 
    NULLIF(COUNT(CASE WHEN a.date_benefits_paid IS NOT NULL THEN 1 END), 0), 1) as benefits_compliance_rate,
  AVG(CASE WHEN a.days_to_benefits_payment IS NOT NULL THEN a.days_to_benefits_payment END) as avg_days_benefits_payment,
  COUNT(CASE WHEN a.overall_compliant = true THEN 1 END) as overall_compliant_count,
  ROUND(100.0 * COUNT(CASE WHEN a.overall_compliant = true THEN 1 END) / 
    NULLIF(COUNT(CASE WHEN a.date_benefits_paid IS NOT NULL THEN 1 END), 0), 1) as overall_compliance_rate
FROM applications a
LEFT JOIN reasons_for_leaving r ON a.reason_id = r.id
GROUP BY r.label
ORDER BY r.label;

GRANT SELECT ON compliance_dashboard TO authenticated;




-- ══════════════════════════════════════════════════════════════════════════════
-- 3. FIX MISSING TPT VALUES
-- ══════════════════════════════════════════════════════════════════════════════
-- Purpose: Calculates TPT for entries that have dates but missing TPT
-- ══════════════════════════════════════════════════════════════════════════════

UPDATE applications
SET tpt = EXTRACT(DAY FROM (actual_date_paid::timestamp - date_exited_service::timestamp))
WHERE date_exited_service IS NOT NULL
  AND actual_date_paid IS NOT NULL
  AND (tpt IS NULL OR tpt::text = '');

-- Verify
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




-- ══════════════════════════════════════════════════════════════════════════════
-- 4. FIX ROLE UPDATE TRACKING
-- ══════════════════════════════════════════════════════════════════════════════
-- Purpose: Adds timestamp tracking when roles change to invalidate cache
-- ══════════════════════════════════════════════════════════════════════════════

-- Add role_updated_at column
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS role_updated_at TIMESTAMPTZ DEFAULT NOW();

-- Update existing records
UPDATE user_profiles 
SET role_updated_at = created_at 
WHERE role_updated_at IS NULL;

-- Create function to automatically update timestamp when role changes
CREATE OR REPLACE FUNCTION update_role_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.role IS DISTINCT FROM OLD.role THEN
    NEW.role_updated_at = NOW();
    RAISE NOTICE 'Role changed for user % from % to % at %', 
      NEW.id, OLD.role, NEW.role, NOW();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
DROP TRIGGER IF EXISTS role_update_trigger ON user_profiles;

CREATE TRIGGER role_update_trigger
BEFORE UPDATE ON user_profiles
FOR EACH ROW
EXECUTE FUNCTION update_role_timestamp();

-- Verify
SELECT 
  id,
  full_name,
  role,
  role_updated_at,
  created_at
FROM user_profiles
ORDER BY role_updated_at DESC
LIMIT 10;




-- ══════════════════════════════════════════════════════════════════════════════
-- 5. UPDATE get_all_user_profiles FUNCTION
-- ══════════════════════════════════════════════════════════════════════════════
-- Purpose: Includes role_updated_at field to fix 400 error
-- ══════════════════════════════════════════════════════════════════════════════

DROP FUNCTION IF EXISTS get_all_user_profiles();

CREATE OR REPLACE FUNCTION get_all_user_profiles()
RETURNS TABLE (
  id              UUID,
  email           TEXT,
  full_name       TEXT,
  role            TEXT,
  department_code TEXT,
  location        TEXT,
  avatar_url      TEXT,
  phone           TEXT,
  is_active       BOOLEAN,
  last_login      TIMESTAMPTZ,
  created_at      TIMESTAMPTZ,
  role_updated_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF get_my_role() NOT IN ('admin', 'super_admin') THEN
    RAISE EXCEPTION 'Access denied';
  END IF;
  
  RETURN QUERY
  SELECT
    up.id, 
    au.email::TEXT, 
    up.full_name::TEXT, 
    up.role::TEXT,
    up.department_code::TEXT, 
    up.location::TEXT, 
    up.avatar_url::TEXT,
    up.phone::TEXT, 
    up.is_active, 
    up.last_login, 
    up.created_at,
    up.role_updated_at
  FROM user_profiles up
  JOIN auth.users au ON au.id = up.id
  ORDER BY up.created_at DESC;
END;
$$;




-- ══════════════════════════════════════════════════════════════════════════════
-- 6. CHECK AND FIX RLS POLICIES FOR ROLE UPDATES
-- ══════════════════════════════════════════════════════════════════════════════
-- Purpose: Allows admins/super_admins to update user roles
-- ══════════════════════════════════════════════════════════════════════════════

-- Check current policies
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'user_profiles';

-- Create proper UPDATE policy for admins
DROP POLICY IF EXISTS "Admins can update any user profile" ON user_profiles;

CREATE POLICY "Admins can update any user profile"
ON user_profiles
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM user_profiles
    WHERE id = auth.uid()
    AND role IN ('admin', 'super_admin')
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM user_profiles
    WHERE id = auth.uid()
    AND role IN ('admin', 'super_admin')
  )
);

-- Verify
SELECT policyname, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'user_profiles' 
AND policyname = 'Admins can update any user profile';




-- ══════════════════════════════════════════════════════════════════════════════
-- 7. FIX ADMIN SELECT POLICY
-- ══════════════════════════════════════════════════════════════════════════════
-- Purpose: Allows admins to SELECT user profiles for verification
-- Fixes: 406 error when verifying role updates
-- ══════════════════════════════════════════════════════════════════════════════

-- Check current SELECT policies
SELECT 
  policyname,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'user_profiles' 
AND cmd = 'SELECT';

-- Create SELECT policy (prevents infinite recursion)
DROP POLICY IF EXISTS "Admins can view all user profiles" ON user_profiles;
DROP POLICY IF EXISTS "Users can view profiles" ON user_profiles;
DROP POLICY IF EXISTS "Allow authenticated users to view profiles" ON user_profiles;

CREATE POLICY "Allow authenticated users to view profiles"
ON user_profiles
FOR SELECT
TO authenticated
USING (true);

-- Verify
SELECT policyname, cmd, qual
FROM pg_policies 
WHERE tablename = 'user_profiles' 
AND cmd = 'SELECT';




-- ══════════════════════════════════════════════════════════════════════════════
-- 8. FIX NOTIFICATIONS FOR SUPER ADMIN
-- ══════════════════════════════════════════════════════════════════════════════
-- Purpose: Ensures super_admin can see notifications
-- ══════════════════════════════════════════════════════════════════════════════

-- Drop existing policies
DROP POLICY IF EXISTS "Admins can view notifications" ON notifications;
DROP POLICY IF EXISTS "Admin can view notifications" ON notifications;
DROP POLICY IF EXISTS "Users can view their notifications" ON notifications;

-- Create new SELECT policy
CREATE POLICY "Admins and super_admins can view notifications"
  ON notifications FOR SELECT
  USING (
    get_my_role() IN ('admin', 'super_admin')
  );

-- Drop existing INSERT policy
DROP POLICY IF EXISTS "Admins can insert notifications" ON notifications;
DROP POLICY IF EXISTS "Admin can insert notifications" ON notifications;

-- Create new INSERT policy
CREATE POLICY "Admins and super_admins can insert notifications"
  ON notifications FOR INSERT
  WITH CHECK (
    get_my_role() IN ('admin', 'super_admin')
  );

-- Drop existing UPDATE policy
DROP POLICY IF EXISTS "Admins can update notifications" ON notifications;
DROP POLICY IF EXISTS "Admin can update notifications" ON notifications;

-- Create new UPDATE policy
CREATE POLICY "Admins and super_admins can update notifications"
  ON notifications FOR UPDATE
  USING (
    get_my_role() IN ('admin', 'super_admin')
  );

-- Verify
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename = 'notifications';




-- ══════════════════════════════════════════════════════════════════════════════
-- 9. INSERT DUMMY TRACKING DATA (TESTING ONLY)
-- ══════════════════════════════════════════════════════════════════════════════
-- Purpose: Creates test data for tracking indicators
-- NOTE: Only run this in development/testing environments
-- REPLACE officer_id and reason_id with actual IDs from your database
-- ══════════════════════════════════════════════════════════════════════════════

-- Get IDs first:
-- SELECT id, first_name, surname FROM officers LIMIT 5;
-- SELECT id, label FROM reasons_for_leaving;

-- Uncomment and adjust the INSERT statements below if you need test data
-- See insert_dummy_tracking_data.sql for full test data script

-- ══════════════════════════════════════════════════════════════════════════════
-- END OF MASTER SQL SCRIPTS
-- ══════════════════════════════════════════════════════════════════════════════
-- 
-- EXECUTION ORDER:
-- 1. Run scripts 1-8 in order for production setup
-- 2. Run script 9 only for testing/development
-- 
-- VERIFICATION:
-- - Check user_profiles table for super_admin role
-- - Check applications table for compliance fields
-- - Test role changes in admin panel
-- - Verify notifications appear for super_admin
-- 
-- ══════════════════════════════════════════════════════════════════════════════
