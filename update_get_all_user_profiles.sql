-- ══════════════════════════════════════════════════════════════
-- UPDATE get_all_user_profiles to include role_updated_at
-- ══════════════════════════════════════════════════════════════

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
  role_updated_at TIMESTAMPTZ  -- ADDED THIS
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
    up.role_updated_at  -- ADDED THIS
  FROM user_profiles up
  JOIN auth.users au ON au.id = up.id
  ORDER BY up.created_at DESC;
END;
$$;

-- Function updated successfully!
-- The 400 error should now be fixed.
