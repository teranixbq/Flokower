# 🔥 FLOKOWER - FIREBASE SETUP GUIDE (Step by Step)

## 📋 Quick Start - 5 Langkah!

### Step 1: Buat Project di Firebase Console ⏱️ 2 menit

1. Buka https://console.firebase.google.com/
2. Click **"Add project"** atau **"Create project"**
3. Isi:
   - **Project name**: `Flokower`
   - Don't enable Google Analytics (optional)
4. Click **"Create project"**
5. Wait ~10 detik → DONE! ✅

---

### Step 2: Tambahkan App Android ⏱️ 3 menit

**Di Firebase Console:**
1. Click icon **"🤖" (Android)** → "Add app"
2. Isi form:
   ```
   Package name: com.example.flokower  ← WAJIB SAMA PERSIS!
   App nickname: Flokower App (optional)
   ```
3. Download `google-services.json`
4. Simpan file ini di komputer kamu

✅ Firebase Console DONE!

---

### Step 3: Place google-services.json File ⏱️ 1 menit

**Lokasi file harus persis seperti ini:**

```
~/Documents/Flokower/android/app/google-services.json
```

**Cara copy file:**
```bash
# Di terminal, jalankan:
mkdir -p android/app
mv ~/Downloads/google-services.json android/app/
```

atau drag-drop dari Downloads ke folder `android/app/`

✅ File siap!

---

### Step 4: Install Firebase Dependencies ⏱️ 2 menit

**Jalankan perintah ini di terminal:**

```bash
cd ~/Documents/Flokower
flutter pub get
```

Ini akan install semua paket Firebase yang diperlukan.

✅ Dependencies installed!

---

### Step 5: Configure Firebase Options ⏱️ 2 menit

Ada 2 cara:

#### **Cara A: Gunakan Flutter CLI (RECOMMENDED!) - Auto Generate!**

```bash
# Install FlutterFire CLI globally
dart pub global activate flutterfire_cli

# Run configuration wizard
flutterfire configure --project=flokower-app
```

Command ini akan:
- Auto detect project Anda
- Generate firebase_options.dart otomatis
- Fill semua values yang benar!
- ✨ **HANYA BUTUH 1 PERINTAH!** ⚡

#### **Cara B: Manual Edit (Jika Cara A Gagal)**

1. Rename file `lib/firebase_options.template.dart` menjadi `lib/firebase_options.dart`

2. Update values dengan data dari Firebase Console:

   **Lihat di Firebase Console:**
   - Click your app (Flokower)
   - Scroll ke bawah → "Your apps"
   - Copy values untuk ANDROID

   **Replace di file firebase_options.dart:**
   ```dart
   static const FirebaseOptions android = FirebaseOptions(
     apiKey: 'AIzaSy...',              // Copy dari console
     appId: '1:xxx:android:xxx',      // Copy dari console
     messagingSenderId: 'xxx',        // Copy dari console  
     projectId: 'flokower-app',       // Sesuaikan project name
     storageBucket: 'flokower.appspot.com',
   );
   ```

✅ Firebase configured!

---

### ✅ Verification Test

**Test apakah Firebase connected:**

1. Connect phone via USB (USB debugging enabled)
2. Run app:
   ```bash
   flutter run
   ```

3. If successful:
   - App runs without errors
   - Login screen shows up
   - Check console for:
     ```
     [VERBOSE-2:]firebase_core... Firebase initialized
     ```

4. If error occurs:
   - "No Firebase App found" → Check google-services.json location
   - "Permission denied" → Check Firestore security rules later
   - "Google services config not found" → Wrong file location

---

## 🔧 Enable Services in Firebase Console

### 1. Authentication Setup (EMAIL LOGIN)

```
Firebase Console → Authentication → Sign-in method
Enable providers:
☑️ Email/Password
☑️ Email Link (for OTP verification)
```

### 2. Firestore Database Setup

```
Firebase Console → Firestore Database → Create database
Start in test mode (untuk development)
Location: asia-southeast1 (Singapore - recommended)
```

### 3. Security Rules (Production Ready)

After creating database, replace test mode with these rules:

**Go to:** Firestore Database → Rules

**Paste this:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function
    function isAuthenticated() {
      return request.auth != null && request.auth.token.email != null;
    }
    
    // Materials collection
    match /materials/{materialId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated() && 
        request.resource.data.quantity >= 0 &&
        request.resource.data.unit in ['lembar', 'tangkai'];
    }
    
    // Products collection
    match /products/{productId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated() && 
        request.resource.data.price >= 0 &&
        request.resource.data.isActive in [true, false];
    }
    
    // Transactions collection
    match /transactions/{transactionId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && 
        request.resource.data.status == 'in_progress';
      
      allow update: if isAuthenticated() &&
        resource.data.status == 'in_progress' &&
        request.resource.data.status in ['completed', 'cancelled'];
    }
    
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

Click **"Publish"** to save rules!

---

## 🎯 Next Steps After Firebase Setup

Once Firebase is ready:

1. **Run the app:**
   ```bash
   flutter run
   ```

2. **Login/Register test:**
   - Try signup/login flow
   - Verify authentication works

3. **Create materials:**
   - Navigate to Stock tab
   - Add first material
   - Verify it syncs to Firestore

4. **Check Firebase Console:**
   - Authentication → Users tab → Should see new users
   - Firestore → Data tab → Should see materials/products
   - Storage → Files should be empty (no images yet)

---

## 🐛 Troubleshooting

### Issue: "No Firebase App found"
**Solution:**
- Check google-services.json exists at correct path
- Restart IDE/Flutter
- Clean build: `flutter clean && flutter pub get`

### Issue: "Permission denied" on Firestore
**Solution:**
- Ensure you're logged in
- Check Firestore security rules are published
- User must authenticate before accessing data

### Issue: Auth doesn't work
**Solution:**
- Verify Email/Password provider enabled in Console
- Check email format validation
- Ensure package name matches exactly

### Issue: App crashes on launch
**Solution:**
- Check all Firebase dependencies updated: `firebase_core`, `cloud_firestore`, etc.
- Verify google-services.json in correct location
- Check `minSdkVersion` is at least 21 in android/build.gradle

---

## 📊 Monitoring Usage

**Track Firebase usage (always FREE for UMKM!):**

```
Firebase Console → Usage and alerts
→ View dashboard to monitor:
  - Reads/writes per day
  - Active users
  - Storage used
```

Typical UMKM usage:
- Daily reads: < 500 (< 50K limit ✅)
- Daily writes: < 100 (< 20K limit ✅)
- **Cost: $0 forever!**

---

## 🎉 That's It! You're Ready!

Firebase setup complete! Now enjoy building Flokower with powerful backend! 🚀

Questions? See [`docs/FIREBASE_SETUP.md`](docs/FIREBASE_SETUP.md) for more details.
