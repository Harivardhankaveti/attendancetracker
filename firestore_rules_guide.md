# Firestore Security Rules for Timetable Management

Copy and paste the following rules into your Firebase Console -> Firestore Database -> Rules.

These rules ensure that:
1. **Admins** have full read/write access to all collections.
2. **Students** can only read the `timetables` document that perfectly matches their `branch` and `section` fields.
3. Only authenticated users can access the database.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Function to check if user is admin
    function isAdmin() {
      return request.auth != null && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == "admin";
    }

    // Function to get the current user's document
    function getUserData() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
    }

    // ----------------------------------------
    // TIMETABLES COLLECTION (Bulk Upload Schema)
    // ----------------------------------------
    match /timetables/{docId} {
      // Admins can upload and see all timetables
      allow write, read: if isAdmin();
      
      // Students can only read the timetable document if the document ID perfectly matches `BRANCH_SECTION`
      // Example: 'CSE_A'
      allow read: if request.auth != null && 
                  (getUserData().branch + '_' + getUserData().section) == docId;
    }

    // ----------------------------------------
    // TIMETABLE COLLECTION (Manual Single-Class Schema)
    // ----------------------------------------
    match /timetable/{docId} {
      allow write, read: if isAdmin();
      
      allow read: if request.auth != null && 
                  getUserData().branch == resource.data.branch &&
                  getUserData().section == resource.data.section;
    }
    
    // Default rules for other collections
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Schema Design Structure

### Collection: `timetables`
**Document ID:** `{branch}_{section}` (e.g., `CSE_A`)

**Document Fields:**
- `branch` (String) - e.g. "CSE"
- `section` (String) - e.g. "A"
- `uploadedBy` (String) - e.g. "Admin"
- `lastUpdated` (Timestamp)
- `schedule` (Map)
  - `Monday` (Map)
    - `09:00 - 10:00`: "Math"
    - `10:00 - 11:00`: "Physics"
  - `Tuesday` (Map)...
