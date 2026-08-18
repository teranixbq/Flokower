# 🔥 FLOKOWER - MANUAL FIREBASE SETUP (No CLI Required!)

## ✅ Quick Setup - Copy Paste Commands!

### Step 1: Buka Firebase Console
```
https://console.firebase.google.com/project/flokower/overview
```

### Step 2: Copy Your Firebase Config Values

**Buka project settings:**
1. Klik icon **⚙️ (Settings gear)** di left sidebar
2. Scroll ke section "Your apps"
3. Klik **Android app** (Flokower)
4. Copy values dari "Firebase SDK configuration"

### Step 3: Update firebase_options.dart

**Open file:** `lib/firebase_options.dart`

**Replace values** seperti ini:

```dart
// ANDROID Configuration
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSy...',              // Paste dari Firebase Console
  appId: '1:xxx:android:xxx',      // Paste dari Firebase Console  
  messagingSenderId: 'xxx',        // Paste dari Firebase Console
  projectId: 'flokower',
  storageBucket: 'flokower.appspot.com',
);
```

✅ DONE! No CLI needed!

---

## 🎯 Complete Command (Auto-Setup dengan google-services.json)

Jika kamu sudah punya `google-services.json`, jalankan:

```bash
# Place file
cp ~/Downloads/google-services.json android/app/

# Done! App siap pakai!
flutter pub get
flutter run
```

That's it! Simple & fast! ⚡
