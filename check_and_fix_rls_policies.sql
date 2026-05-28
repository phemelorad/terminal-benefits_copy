-- ══════════════════════════════════════════════════════════════
-- CHECK AND FIX RLS POLICIES FOR ROLE UPDATES
-- ══════════════════════════════════════════════════════════════

-- 1. Check current policies on user_profiles
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

-- 2. Check if there's a policy preventing role updates
-- If you see a policy that restricts UPDATE on the 'role' column, we need to fix it

-- 3. Drop restrictive policies (if any exist)
-- DROP POLICY IF EXISTS "Users can only update their own profile" ON user_profiles;
-- DROP POLICY IF EXISTS "Prevent role changes" ON user_profiles;

-- 4. Create proper policy for admins to update roles
DROP POLICY IF EXISTS "Admins can update any user profile" ON user_profiles;

CREATE POLICY "Admins can update any user profile"
ON user_profiles
FOR UPDATE
TO authenticated
USING (
  -- Allow if user is admin or super_admin
  EXISTS (
    SELECT 1 FROM user_profiles
    WHERE id = auth.uid()
    AND role IN ('admin', 'super_admin')
  )
)
WITH CHECK (
  -- Allow if user is admin or super_admin
  EXISTS (
    SELECT 1 FROM user_profiles
    WHERE id = auth.uid()
    AND role IN ('admin', 'super_admin')
  )
);

-- 5. Verify the policy was created
SELECT policyname, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'user_profiles' 
AND policyname = 'Admins can update any user profile';

-- 6. Test update (replace with actual user ID)
-- UPDATE user_profiles SET role = 'officer' WHERE id = 'some-user-id';
-- SELECT id, role, role_updated_at FROM user_profiles WHERE id = 'some-user-id';
