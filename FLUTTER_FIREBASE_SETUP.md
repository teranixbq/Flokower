# 🚀 QUICK START - FLOKOWER FIREBASE SETUP (INDONESIAN)

## ✨ PANDUAN SINGKAT - Setup Firebase dalam 5 Menit!

### 📱 Yang Perlu Disiapkan:
1. Akun Google/Gmail
2. Laptop + Internet
3. Waktu: 10 menit

---

## 🔥 LANGKAH-LANGKAH SETUP (Copy-Paste Step by Step!)

### 1️⃣ Buat Project Firebase (2 menit)

**Buka link ini di browser:**
```
https://console.firebase.google.com/
```

**Click:** "Add project" atau icon "+" 

**Isi nama:**
- **Project name**: `Flokower`
- Click **"Create project"**

✅ Wait ~5 detik... DONE! ✅

---

### 2️⃣ Tambahkan App Android (2 menit)

Di console Firebase yang baru dibuat:

**Click icon:** 🤖 (Android robot)

**Isi form dengan EXACT seperti ini:**
```
Package name: com.example.flokower
```
*(PERCAYA saya, harus persis begini!)*

**Nickname:** `Flokower App` (optional)

**Download google-services.json**
- Klik tombol download
- Simpan di folder Downloads laptop kamu

✅ DOWNLOAD DONE! ✅

---

### 3️⃣ Copy File ke Folder App (1 menit)

**Lokasi file harus seperti ini:**

📁 **Folder path:**
```
/home/nodenix/Documents/Flokower/android/app/google-services.json
```

**Cara paling mudah:**
1. Buka terminal
2. Jalankan command ini:
```bash
cd ~/Documents/Flokower/android/app
mv ~/Downloads/google-services.json .
```

Atau drag-file aja dari Downloads ke folder `android/app/`

✅ FILE READY! ✅

---

### 4️⃣ Install Firebase Packages (1 menit)

**Run command ini:**
```bash
cd ~/Documents/Flokower
flutter pub get
```

Command ini akan install semua paket Firebase yang diperlukan.

✅ INSTALLATION DONE! ✅

---

### 5️⃣ Generate Firebase Options (Auto!)

Jalankan command super simple ini:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=flokower-app
```

**Tunggu...** Command ini akan:
- Auto detect project Flokower kamu
- Generate file firebase_options.dart
- Fill semua nilai yang benar!
- ✨ **100% AUTOMATIC!** 🎉

Setelah selesai → CONFIRM dengan klik ENTER!

✅ CONFIGURATION AUTO-DONE! ✅

---

## 🎊 SELESAI! Firebase Sudah Ready! 🎊

Sekarang app Flokower siap pakai dengan backend Firebase!

### Test Sekarang:

**Hubungkan HP via USB:**
1. Enable USB debugging di HP Android
2. Jalankan command ini di terminal:

```bash
flutter run
```

**Tunggu...** 
- App akan build & install ke HP kamu
- Setelah loading... 
- Login screen muncul! ✅

**Coba register akun:**
- Masukkan email valid
- Password minimal 6 karakter
- Submit!

**Check Firebase Console:**
```
Firebase Console → Authentication → Users
→ Should see your new user account! ✅
```

---

## 💡 Tips Tambahan

### Check Firebase Usage (Selalu GRATIS!)

```
Firebase Console → Usage and alerts
```

Untuk UMKM florist:
- **Daily reads**: < 1,000 (limit: 50,000/day ✅)
- **Daily writes**: < 200 (limit: 20,000/day ✅)
- **Cost**: $0 forever! 💰

---

### Enable Database & Auth (Optional for MVP)

Kalau mau test full functionality:

**Firestore Database:**
```
Console → Firestore Database → Create database
Start in TEST mode → Choose Singapore (asia-southeast1)
```

**Authentication:**
```
Console → Authentication → Sign-in method
Enable: Email/Password ✓
Enable: Email Link (for OTP) ✓
```

---

## ❓ Masih Bingung?

Baca detailed guide: [`FIREBASE_SETUP_GUIDE.md`](FIREBASE_SETUP_GUIDE.md)

Atau follow video tutorial di YouTube! 😊

---

## ✅ Checklist Final

Sebelum mulai development:
- [ ] Firebase project created ✅
- [ ] Package name exact match ✅
- [ ] google-services.json downloaded ✅
- [ ] File placed correctly ✅
- [ ] flutterfire configured ✅
- [ ] Apps builds without errors ✅
- [ ] Login works ✅

**If ALL checked → READY TO BUILD! 🚀**

---

*Happy coding!*  
*Built with ❤️ for UMKM Florists*
