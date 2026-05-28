-- ============================================================
--  Super Admin — protects phemelorad account from deletion
--  Run in Supabase SQL Editor
-- ============================================================

-- 1. Add super_admin role to the role check constraint
ALTER TABLE user_profiles
  DROP CONSTRAINT IF EXISTS user_profiles_role_check;

ALTER TABLE user_profiles
  ADD CONSTRAINT user_profiles_role_check
  CHECK (role IN ('super_admin', 'admin', 'officer', 'viewer'));

-- 2. Set your account as super_admin
UPDATE user_profiles
SET role = 'super_admin'
WHERE id = '082ccf13-179d-431c-ac4a-dc0d798de7f6';

-- 3. Protect super_admin from deletion by regular admins
--    Only super_admin can delete super_admin accounts
DROP POLICY IF EXISTS "Admins can delete profiles" ON user_profiles;

CREATE POLICY "Admins can delete profiles"
  ON user_profiles FOR DELETE
  USING (
    -- Must be admin or super_admin yourself
    get_my_role() IN ('admin', 'super_admin')
    AND
    -- Cannot delete super_admin unless you are also super_admin
    (role != 'super_admin' OR get_my_role() = 'super_admin')
    AND
    -- Cannot delete yourself
    id != auth.uid()
  );

-- 4. Protect super_admin role from being changed by regular admins
DROP POLICY IF EXISTS "Admins can update profiles" ON user_profiles;

CREATE POLICY "Admins can update profiles"
  ON user_profiles FOR UPDATE
  USING (
    -- Own profile OR admin/super_admin
    auth.uid() = id
    OR get_my_role() IN ('admin', 'super_admin')
  )
  WITH CHECK (
    -- Regular admins cannot change role TO or FROM super_admin
    CASE
      -- Super admins can do anything
      WHEN get_my_role() = 'super_admin' THEN true
      -- Regular admins cannot change TO super_admin
      WHEN get_my_role() = 'admin' AND role = 'super_admin' THEN false
      -- Regular admins cannot change FROM super_admin (check old value)
      WHEN get_my_role() = 'admin' AND (SELECT role FROM user_profiles WHERE id = user_profiles.id) = 'super_admin' THEN false
      -- Regular admins can change other roles
      WHEN get_my_role() = 'admin' THEN true
      -- Users can only update their own profile without changing role
      ELSE auth.uid() = id AND role = (SELECT role FROM user_profiles WHERE id = auth.uid())
    END
  );

-- 5. Update get_all_user_profiles to include super_admin
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
  created_at      TIMESTAMPTZ
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
    up.id, au.email::TEXT, up.full_name::TEXT, up.role::TEXT,
    up.department_code::TEXT, up.location::TEXT, up.avatar_url::TEXT,
    up.phone::TEXT, up.is_active, up.last_login, up.created_at
  FROM user_profiles up
  JOIN auth.users au ON au.id = up.id
  ORDER BY up.created_at DESC;
END;
$$;

-- 6. Update get_my_role to return super_admin correctly
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
WHERE id = '082ccf13-179d-431c-ac4a-dc0d798de7f6';
