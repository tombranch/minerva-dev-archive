# Debug: Photo Not Found Issues

## Problem
- Activity History API returns 404 "Not Found"
- AI Results API returns "Photo not found"

## Debugging Steps

### 1. Check Browser Console
Open the browser console and look for these log messages when opening a photo:
- `AI Results API - Photo ID: [id]`
- `AI Results API - Photo not found`
- Any photo IDs being logged

### 2. Verify Photo ID Format
The photo ID should be a UUID like: `123e4567-e89b-12d3-a456-426614174000`

### 3. Check Network Tab
1. Open DevTools Network tab
2. Open a photo detail modal
3. Look for these API calls:
   - `/api/photos/[id]/activity`
   - `/api/photos/[id]/ai-results`
4. Check the actual ID in the URL

### 4. Database Check
Run this SQL in Supabase to verify photos exist:
```sql
-- List recent photos
SELECT id, original_filename, created_at, organization_id
FROM photos
ORDER BY created_at DESC
LIMIT 10;

-- Check specific photo (replace with actual ID from console)
SELECT * FROM photos WHERE id = 'YOUR_PHOTO_ID_HERE';
```

### 5. Common Issues
1. **Photo ID mismatch**: Frontend might be sending wrong ID format
2. **Organization mismatch**: Photo might belong to different org
3. **Timing issue**: Photo might not be fully saved when modal opens

### 6. Temporary Workaround
If needed, you can temporarily disable these features again by adding error boundaries or conditional checks in the components.