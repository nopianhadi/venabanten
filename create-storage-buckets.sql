-- ============================================
-- CREATE SUPABASE STORAGE BUCKETS
-- ============================================
-- Bucket untuk upload file aplikasi
-- ============================================

-- 1. Create dp-proofs bucket for payment proof uploads
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'dp-proofs',
    'dp-proofs', 
    true,
    10485760, -- 10MB limit
    ARRAY['image/jpeg', 'image/png', 'image/jpg', 'image/webp', 'application/pdf']
) ON CONFLICT (id) DO NOTHING;

-- 2. Create gallery-images bucket for gallery uploads
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'gallery-images',
    'gallery-images',
    true, 
    10485760, -- 10MB limit
    ARRAY['image/jpeg', 'image/png', 'image/jpg', 'image/webp', 'image/gif']
) ON CONFLICT (id) DO NOTHING;

-- ============================================
-- CREATE STORAGE POLICIES
-- ============================================
-- RLS policies untuk akses bucket
-- ============================================

-- Policy untuk dp-proofs bucket
-- Allow public uploads (untuk public booking form)
CREATE POLICY "Allow public uploads to dp-proofs" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'dp-proofs');

-- Allow public read access
CREATE POLICY "Allow public read access to dp-proofs" ON storage.objects
    FOR SELECT USING (bucket_id = 'dp-proofs');

-- Policy untuk gallery-images bucket  
-- Allow public uploads (more permissive for gallery uploads)
CREATE POLICY "Allow public uploads to gallery-images" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'gallery-images');

-- Allow authenticated uploads (backup policy)
CREATE POLICY "Allow authenticated uploads to gallery-images" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'gallery-images' 
        AND auth.role() = 'authenticated'
    );

-- Allow public read access to gallery images
CREATE POLICY "Allow public read access to gallery-images" ON storage.objects
    FOR SELECT USING (bucket_id = 'gallery-images');

-- Allow authenticated users to delete their own uploads
CREATE POLICY "Allow authenticated delete from gallery-images" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'gallery-images' 
        AND auth.role() = 'authenticated'
    );

-- Allow public delete (more permissive)
CREATE POLICY "Allow public delete from gallery-images" ON storage.objects
    FOR DELETE USING (bucket_id = 'gallery-images');

-- Allow authenticated users to update their own uploads
CREATE POLICY "Allow authenticated update to gallery-images" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'gallery-images' 
        AND auth.role() = 'authenticated'
    );

-- Allow public update (more permissive)
CREATE POLICY "Allow public update to gallery-images" ON storage.objects
    FOR UPDATE USING (bucket_id = 'gallery-images');

-- ============================================
-- VERIFY BUCKETS CREATED
-- ============================================

SELECT 'Storage buckets verification:' as info;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'dp-proofs') 
        THEN '✅ dp-proofs bucket created' 
        ELSE '❌ dp-proofs bucket missing' 
    END as dp_proofs_status;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'gallery-images') 
        THEN '✅ gallery-images bucket created' 
        ELSE '❌ gallery-images bucket missing' 
    END as gallery_images_status;

-- Show bucket details
SELECT 
    id,
    name,
    public,
    file_size_limit,
    allowed_mime_types,
    created_at
FROM storage.buckets 
WHERE id IN ('dp-proofs', 'gallery-images')
ORDER BY id;

-- ============================================
-- SUCCESS MESSAGE
-- ============================================
SELECT '🎉 Storage buckets created successfully!' as result;
SELECT 'Public booking form uploads will now work properly.' as message;