# 📅 CALENDAR EVENTS TABLE FIX

## 🔍 **ERROR BARU DITEMUKAN:**

**Error:** `Could not find the table 'public.calendar_events'`

**Lokasi:** CalendarView.tsx mencoba mengakses tabel `calendar_events` yang belum ada

## ✅ **SOLUSI SUDAH DITAMBAHKAN:**

Tabel `calendar_events` sudah ditambahkan ke file `create-missing-tables.sql` dengan struktur:

```sql
CREATE TABLE IF NOT EXISTS calendar_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    date DATE NOT NULL,
    start_time TIME,
    end_time TIME,
    notes TEXT,
    team JSONB DEFAULT '[]'::jsonb,
    image TEXT,
    location TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

## 🚀 **CARA MENJALANKAN:**

1. **Buka Supabase Dashboard → SQL Editor**
2. **Copy & Paste isi file `create-missing-tables.sql`**
3. **Klik Run**

File ini akan membuat 2 tabel sekaligus:
- ✅ `project_add_ons` - Junction table untuk project dan add-ons
- ✅ `calendar_events` - Tabel untuk calendar events

## 🎯 **HASIL:**

Setelah dijalankan, error calendar_events akan hilang dan fitur calendar akan berfungsi normal.

---

**Updated:** 2026-01-27  
**Status:** Ready to deploy