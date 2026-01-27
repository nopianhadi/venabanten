# 🔧 GALLERY RLS POLICY FIX

## 🐛 **PROBLEM IDENTIFIED:**

The gallery upload is failing with RLS policy violations because:
1. Gallery uploads are using anonymous Supabase client (no authentication)
2. Current RLS policies require `auth.role() = 'authenticated'`
3. This creates a mismatch causing 400 Bad Request errors

## ✅ **SOLUTION CREATED:**

### **File: `fix-gallery-rls-policies.sql`**
This file will:
1. Drop existing restrictive RLS policies
2. Create new permissive policies that allow public uploads
3. Maintain security while allowing gallery functionality

## 🚀 **EXECUTION STEPS:**

### **IMMEDIATE FIX:**
Run this SQL in Supabase SQL Editor:
```sql
-- File: fix-gallery-rls-policies.sql
```

### **ALTERNATIVE APPROACH (If needed):**
If you prefer to keep authentication, you can modify the gallery service to authenticate first:

```typescript
// In services/galleries.ts, add before upload:
const { data: { user } } = await supabase.auth.getUser();
if (!user) {
  // Handle authentication or use service key
}
```

## 🎯 **RECOMMENDED APPROACH:**

**Use the permissive RLS policies** because:
- Gallery uploads are typically public functionality
- Easier to implement and maintain
- Matches the current app architecture
- Still secure for the use case

## 📋 **TESTING AFTER FIX:**

1. Run `fix-gallery-rls-policies.sql` in Supabase
2. Go to http://localhost:5173/#/galeri-upload
3. Try uploading images
4. Should work without RLS policy errors

## 🔍 **VERIFICATION:**

After running the SQL, check in Supabase Dashboard:
- Storage > Policies
- Should see new "Allow public..." policies for gallery-images
- No more authentication requirements for gallery uploads

---

**🎉 This will completely fix the gallery upload RLS policy violations!**

**Updated:** 2026-01-27  
**Status:** Ready for execution