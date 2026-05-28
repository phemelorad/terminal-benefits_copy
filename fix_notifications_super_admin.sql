-- ============================================================
--  Fix Notifications for Super Admin
--  Run in Supabase SQL Editor
-- ============================================================

-- OPTION 1: If notifications table has RLS policies
-- ============================================================

-- Drop existing SELECT policy
DROP POLICY IF EXISTS "Admins can view notifications" ON notifications;
DROP POLICY IF EXISTS "Admin can view notifications" ON notifications;
DROP POLICY IF EXISTS "Users can view their notifications" ON notifications;

-- Create new policy that includes super_admin
CREATE POLICY "Admins and super_admins can view notifications"
  ON notifications FOR SELECT
  USING (
    -- Allow admins and super_admins to see all notifications
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

-- OPTION 2: If you have triggers that create notifications
-- ============================================================
-- Check if there's a trigger function and update it

-- List all triggers on applications table (common source of notifications)
-- Run this to see what triggers exist:
-- SELECT trigger_name, event_manipulation, event_object_table 
-- FROM information_schema.triggers 
-- WHERE event_object_schema = 'public';

-- Example: Update a trigger function to notify super_admins too
-- (Uncomment and adjust based on your actual trigger name)

/*
CREATE OR REPLACE FUNCTION notify_admins_on_application_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Only notify when actual_date_paid is filled (awaiting approval)
  IF NEW.actual_date_paid IS NOT NULL AND (OLD.actual_date_paid IS NULL OR OLD.actual_date_paid IS DISTINCT FROM NEW.actual_date_paid) THEN
    INSERT INTO notifications (type, payload, created_at, is_read)
    VALUES (
      'awaiting_approval',
      jsonb_build_object('appId', NEW.id),
      NOW(),
      false
    );
  END IF;
  
  RETURN NEW;
END;
$$;
*/

-- OPTION 3: Quick Test - Manually create a test notification
-- ============================================================
-- This will help verify if the issue is with policies or triggers

INSERT INTO notifications (type, payload, created_at, is_read)
VALUES (
  'test_notification',
  '{"message": "Test notification for super_admin"}'::jsonb,
  NOW(),
  false
);

-- VERIFICATION
-- ============================================================
-- Check current policies on notifications table
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename = 'notifications';

-- Check if super_admin can see notifications
SELECT 
  up.id, 
  up.full_name, 
  up.role,
  (SELECT COUNT(*) FROM notifications WHERE is_read = false) as unread_count
FROM user_profiles up
WHERE up.role IN ('admin', 'super_admin')
ORDER BY up.role;

