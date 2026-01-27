-- ============================================
-- FIX GALLERY RLS POLICIES
-- ============================================
-- Fix RLS policies untuk gallery-images bucket
-- ============================================

-- Drop existing restrictive policies if they exist
DROP POLICY IF EXISTS "Allow authenticated uploads to gallery-images" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated delete from gallery-images" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated update to gallery-images" ON storage.objects;

-- Create more permissive policies for gallery uploads (SAFE VERSION)
-- Allow public uploads to gallery-images (no authentication required)
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
    END IF;
END $$;

-- Allow public read access to gallery images (SAFE VERSION)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'storage' 
        AND tablename = 'objects' 
        AND policyname = 'Allow public read access to gallery-images'
    ) THEN
        CREATE POLICY "Allow public read access to gallery-images" ON storage.objects
            FOR SELECT USING (bucket_id = 'gallery-images');
    END IF;
END $$;

-- Allow public delete from gallery-images (SAFE VERSION)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'storage' 
        AND tablename = 'objects' 
        AND policyname = 'Allow public delete from gallery-images'
    ) THEN
        CREATE POLICY "Allow public delete from gallery-images" ON storage.objects
            FOR DELETE USING (bucket_id = 'gallery-images');
    END IF;
END $$;

-- Allow public update to gallery-images (SAFE VERSION)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'storage' 
        AND tablename = 'objects' 
        AND policyname = 'Allow public update to gallery-images'
    ) THEN
        CREATE POLICY "Allow public update to gallery-images" ON storage.objects
            FOR UPDATE USING (bucket_id = 'gallery-images');
    END IF;
END $$;

-- ============================================
-- VERIFY POLICIES
-- ============================================

SELECT 'Gallery RLS policies verification:' as info;

-- Show all policies for gallery-images bucket
SELECT 
    policyname,
    cmd,
    permissive,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'objects' 
AND schemaname = 'storage'
AND policyname LIKE '%gallery-images%'
ORDER BY policyname;

-- ============================================
-- SUCCESS MESSAGE
-- ============================================
SELECT '🎉 Gallery RLS policies fixed successfully!' as result;
SELECT 'Gallery uploads should now work without authentication errors.' as message;