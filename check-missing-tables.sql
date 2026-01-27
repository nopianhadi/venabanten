-- ============================================
-- CEK TABEL YANG MASIH MISSING
-- ============================================
-- Berdasarkan error 404 sebelumnya
-- ============================================

-- 1. Cek apakah tabel profiles ada
SELECT 'profiles table exists' as status, COUNT(*) as count FROM profiles;

-- 2. Cek apakah tabel project_team ada (mungkin nama tabelnya berbeda)
-- Kemungkinan nama tabel yang benar:
SELECT 'team_members table exists' as status, COUNT(*) as count FROM team_members;

-- 3. Cek apakah tabel project_add_ons ada (mungkin nama tabelnya berbeda)  
-- Kemungkinan nama tabel yang benar:
SELECT 'add_ons table exists' as status, COUNT(*) as count FROM add_ons;

-- 4. Cek semua tabel yang ada
SELECT 'All tables in database:' as info;
SELECT tablename 
FROM pg_tables 
WHERE schemaname = 'public' 
ORDER BY tablename;

-- 5. Cek apakah ada tabel dengan nama mirip project_team
SELECT tablename 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename LIKE '%team%'
ORDER BY tablename;

-- 6. Cek apakah ada tabel dengan nama mirip project_add_ons
SELECT tablename 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename LIKE '%add%'
ORDER BY tablename;

-- ============================================
-- HASIL YANG DIHARAPKAN:
-- - profiles: ✅ (sudah ada)
-- - team_members: ✅ (bukan project_team)
-- - add_ons: ✅ (bukan project_add_ons)
-- ============================================