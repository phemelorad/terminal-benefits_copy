-- ══════════════════════════════════════════════════════════════
-- FIX: Role Update Tracking
-- Issue #9: Super admin role changes not reflecting on user's end
-- ══════════════════════════════════════════════════════════════

-- Step 1: Add role_updated_at column to track when role changes
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS role_updated_at TIMESTAMPTZ DEFAULT NOW();

-- Step 2: Update existing records to have a timestamp
UPDATE user_profiles 
SET role_updated_at = created_at 
WHERE role_updated_at IS NULL;

-- Step 3: Create function to automatically update timestamp when role changes
CREATE OR REPLACE FUNCTION update_role_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  -- Only update timestamp if role actually changed
  IF NEW.role IS DISTINCT FROM OLD.role THEN
    NEW.role_updated_at = NOW();
    
    -- Log the change for debugging
    RAISE NOTICE 'Role changed for user % from % to % at %', 
      NEW.id, OLD.role, NEW.role, NOW();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 4: Create trigger to call the function
DROP TRIGGER IF EXISTS role_update_trigger ON user_profiles;

CREATE TRIGGER role_update_trigger
BEFORE UPDATE ON user_profiles
FOR EACH ROW
EXECUTE FUNCTION update_role_timestamp();

-- Step 5: Verify the setup
SELECT 
  id,
  full_name,
  role,
  role_updated_at,
  created_at
FROM user_profiles
ORDER BY role_updated_at DESC
LIMIT 10;

-- ══════════════════════════════════════════════════════════════
-- TESTING
-- ══════════════════════════════════════════════════════════════

-- Test 1: Update a role and verify timestamp changes
-- UPDATE user_profiles SET role = 'officer' WHERE id = 'your-user-id-here';
-- SELECT full_name, role, role_updated_at FROM user_profiles WHERE id = 'your-user-id-here';

-- Test 2: Update something else and verify timestamp doesn't change
-- UPDATE user_profiles SET phone = '1234567890' WHERE id = 'your-user-id-here';
-- SELECT full_name, role, role_updated_at FROM user_profiles WHERE id = 'your-user-id-here';

-- ══════════════════════════════════════════════════════════════
-- ROLLBACK (if needed)
-- ══════════════════════════════════════════════════════════════

-- DROP TRIGGER IF EXISTS role_update_trigger ON user_profiles;
-- DROP FUNCTION IF EXISTS update_role_timestamp();
-- ALTER TABLE user_profiles DROP COLUMN IF EXISTS role_updated_at;
