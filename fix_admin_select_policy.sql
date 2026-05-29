-- ══════════════════════════════════════════════════════════════
-- FIX: Add SELECT policy for admins to verify role updates
-- ══════════════════════════════════════════════════════════════

-- The UPDATE policy allows admins to update roles, but they also need
-- SELECT permission to verify the update succeeded

-- 1. Check current SELECT policies
SELECT 
  policyname,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'user_profiles' 
AND cmd = 'SELECT';

-- 2. Create SELECT policy for admins
DROP POLICY IF EXISTS "Admins can view all user profiles" ON user_profiles;

CREATE POLICY "Admins can view all user profiles"
ON user_profiles
FOR SELECT
TO authenticated
USING (
  -- Allow if user is admin or super_admin
  EXISTS (
    SELECT 1 FROM user_profiles
    WHERE id = auth.uid()
    AND role IN ('admin', 'super_admin')
  )
  OR
  -- Or if viewing own profile
  id = auth.uid()
);

-- 3. Verify the policy was created
SELECT policyname, cmd, qual
FROM pg_policies 
WHERE tablename = 'user_profiles' 
AND policyname = 'Admins can view all user profiles';

-- 4. Test SELECT query (replace with actual user ID)
-- SELECT role FROM user_profiles WHERE id = '63ddf185-f0e9-4510-91b4-26af17afb863';
