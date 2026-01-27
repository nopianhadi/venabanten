-- ============================================
-- SIMPLE GALLERY UPLOAD FIX
-- ============================================
-- Remove restrictive policy and ensure public upload works
-- ============================================

-- Drop the restrictive authenticated-only upload policy
DROP POLICY IF EXISTS "Allow authenticated uploads to gallery-images" ON storage.objects;

-- Ensure public upload policy exists (safe creation)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'storage' 
        AND tablename = 'objects' 
        AND policyname = 'Allow public uploads to gallery-images'
    ) THEN
        CREATE POLICY "Allow public uploads to gallery-images" ON storage.objects
            FOR INSERT WITH CHECK (bucket_id = 'gallery-images');
        RAISE NOTICE '✅ Created public upload policy for gallery-images';
    ELSE
        RAISE NOTICE '⚠️  Public upload policy already exists for gallery-images';
    END IF;
END $$;

-- ============================================
-- VERIFY CURRENT POLICIES
-- ============================================

SELECT 'Current gallery-images policies:' as info;

SELECT 
    policyname,
    cmd as operation,
    CASE 
        WHEN qual IS NOT NULL THEN 'Has conditions'
        ELSE 'No conditions'
    END as conditions,
    CASE 
        WHEN with_check IS NOT NULL THEN 'Has check'
        ELSE 'No check'
    END as check_clause
FROM pg_policies 
WHERE tablename = 'objects' 
AND schemaname = 'storage'
AND policyname LIKE '%gallery-images%'
ORDER BY policyname;

-- ============================================
-- SUCCESS MESSAGE
-- ============================================
SELECT '🎉 Gallery upload policy fixed!' as result;
SELECT 'Gallery uploads should now work without authentication errors.' as message;
SELECT 'Test at: http://localhost:5173/#/galeri-upload' as test_url;