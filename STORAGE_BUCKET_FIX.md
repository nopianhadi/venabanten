# 🗂️ STORAGE BUCKET FIX

## 🔍 **ERROR DITEMUKAN:**

**Error:** `StorageApiError: Bucket not found`

**Lokasi:** PublicBookingForm.tsx saat upload bukti transfer DP

**Penyebab:** Supabase Storage bucket belum dibuat

## 📦 **BUCKET YANG DIBUTUHKAN:**

Aplikasi menggunakan 2 bucket storage:

### 1. **dp-proofs** 
- **Fungsi:** Upload bukti transfer DP dari public booking form
- **Akses:** Public (tidak perlu login)
- **File Types:** JPG, PNG, PDF
- **Size Limit:** 10MB

### 2. **gallery-images**
- **Fungsi:** Upload gambar untuk gallery public
- **Akses:** Authenticated users
- **File Types:** JPG, PNG, WEBP, GIF  
- **Size Limit:** 10MB

## ✅ **SOLUSI SUDAH DIBUAT:**

File `create-storage-buckets.sql` sudah dibuat dengan:
- ✅ Membuat kedua bucket dengan konfigurasi yang tepat
- ✅ Mengatur RLS policies untuk akses yang aman
- ✅ Mengatur file type dan size limits
- ✅ Verifikasi bucket berhasil dibuat

## 🚀 **CARA MENJALANKAN:**

### **Opsi 1: Via Supabase Dashboard (Recommended)**
1. **Buka Supabase Dashboard → SQL Editor**
2. **Copy & Paste isi file `create-storage-buckets.sql`**
3. **Klik Run**

### **Opsi 2: Via Supabase Dashboard Storage**
1. **Buka Supabase Dashboard → Storage**
2. **Klik "New bucket"**
3. **Buat bucket dengan nama:**
   - `dp-proofs` (Public: ON)
   - `gallery-images` (Public: ON)

## 🎯 **HASIL:**

Setelah bucket dibuat:
- ✅ Public booking form bisa upload bukti transfer
- ✅ Gallery upload akan berfungsi
- ✅ Tidak ada error "Bucket not found" lagi

## 🔒 **KEAMANAN:**

Bucket sudah dikonfigurasi dengan:
- ✅ File type restrictions (hanya gambar & PDF)
- ✅ File size limits (max 10MB)
- ✅ RLS policies untuk akses yang aman
- ✅ Public read access untuk display
- ✅ Controlled upload access

---

**Updated:** 2026-01-27  
**Status:** Ready to deploy