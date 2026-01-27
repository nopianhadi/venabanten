# 📦 PACKAGES COLUMN FIX

## 🔍 **ERROR BARU DITEMUKAN:**

**Error:** `Could not find the 'duration_prices' column of 'packages' in the schema cache`

**Penyebab:** 
- Di database schema, kolom bernama `duration_options`
- Di service code, menggunakan `duration_prices`
- Beberapa kolom packages lainnya juga missing

## ✅ **SOLUSI SUDAH DITERAPKAN:**

### 1. **Service Code Fix** ✅
File `services/packages.ts` sudah diperbaiki:
- Support kedua nama kolom: `duration_options` dan `duration_prices`
- Menggunakan `duration_options` untuk insert/update

### 2. **Database Schema Fix** ✅
File `create-missing-tables.sql` sudah diupdate untuk menambahkan kolom missing:
- `duration_options` - JSONB array untuk pricing options
- `physical_items` - JSONB array untuk item fisik
- `digital_items` - JSONB array untuk item digital
- `default_printing_cost` - Default biaya cetak
- `default_transport_cost` - Default biaya transport
- `photographers` - Jumlah fotografer
- `videographers` - Jumlah videografer
- `cover_image` - Cover image package
- `region` - Regional package

## 🚀 **CARA MENJALANKAN:**

1. **Buka Supabase Dashboard → SQL Editor**
2. **Copy & Paste isi file `create-missing-tables.sql`**
3. **Klik Run**

File ini akan:
- ✅ Membuat tabel `project_add_ons`
- ✅ Membuat tabel `calendar_events`
- ✅ Menambahkan kolom missing di tabel `packages`

## 🎯 **HASIL:**

Setelah dijalankan:
- ✅ Error `duration_prices` akan hilang
- ✅ Fitur packages akan berfungsi normal
- ✅ Semua kolom packages tersedia

---

**Updated:** 2026-01-27  
**Status:** Ready to deploy