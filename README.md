# Flokower 🌸

Mobile inventory and sales management system for UMKM florists.

## ✨ Features (MVP)

- Material & Product CRUD management
- **Smart stock management**: Auto-merge duplicate materials (add to existing stock)
- **Real-time validation**: Prevent duplicate material names with instant feedback
- **Product image upload**: Required photos stored in Cloudflare R2
- **Stock adjust dialog**: Quick +/- controls for manual stock adjustments
- **Multi-product order flow**: Gallery selection, quantity control per product, aggregated ingredients
- **Edit ingredient quantity**: Modify material requirements directly in product form
- **Loading indicators**: All async operations show visual feedback
- Soft stock reservation system (in_progress → completed)
- Custom ingredient override per transaction
- Real-time multi-user synchronization
- **Uniform product grid layout** (non-bento design)
- Excel export functionality
- **Web support** with CORS-enabled browser uploads

## 🎨 Design System

- **Primary Color**: Teal (#0fac93) - Matches Flokower logo
- **Button Style**: Pill-shaped (border radius 50px)
- **Card Style**: Rounded corners (border radius 20px)
- **Accent Colors**: Teal for primary actions, with supporting colors for status indicators

## 🛠️ Tech Stack

- **Flutter**: Cross-platform mobile framework (Android + Web)
- **Firebase**: Backend as a Service (Firestore + Auth)
- **Cloudflare R2**: Image storage (S3-compatible)
- **Riverpod**: State management
- **AWS SigV4**: Secure R2 API signing (pure Dart, no native dependencies)

## 🚀 Quick Start

```bash
# 1. Clone repository
git clone https://github.com/teranixbq/Flokower.git
cd Flokower

# 2. Install dependencies
flutter pub get

# 3. Configure environment
cp .env.example .env
# Edit .env and fill in:
# - Firebase Web App config (from Firebase Console)
# - Cloudflare R2 credentials (Account ID, Access Key, Secret Key, Bucket, Public URL)

# 4. Run app
flutter run -d chrome  # Web (recommended for development)
flutter run            # Android
```

### 🐛 Web Development Tip

If you encounter shader compilation errors on Chrome, use HTML renderer:
```bash
flutter run -d chrome --web-renderer html
```

## 📱 Build for Production

### Build APK (Android)

```bash
# Debug build (for testing)
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk

# Release build (for distribution)
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# App Bundle (for Google Play Store)
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

**⚠️ Important:** Release builds require signing configuration. See [Deployment Guide](#deployment) for keystore setup.

### Build Web

```bash
flutter build web --release
# Output: build/web/ (deploy to any static hosting)
```

## 🔒 Deployment

### Android APK Signing

1. **Generate keystore** (keep this safe!):
```bash
keytool -genkey -v -keystore ~/flokower-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias flokower
```

2. **Create `android/key.properties`**:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=flokower
storeFile=/path/to/flokower-release-key.jks
```

3. **Build signed APK**:
```bash
flutter build apk --release
```

### Firebase Production Setup

Firebase doesn't require manual "production mode" switching. However, ensure:

1. **Firestore Security Rules** are properly configured:
```bash
# Deploy production rules
firebase deploy --only firestore:rules
```

**Recommended production rules** (restrict to authenticated users):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

2. **Firebase Authentication** is enabled and configured
3. **Cloudflare R2** credentials are properly set in `.env`

## 📁 Project Structure

```
lib/
├── core/                    # Shared utilities
├── features/                # Feature modules
│   ├── auth/               # Authentication
│   ├── inventory/          # Materials & Products
│   ├── transactions/       # Sales & orders
│   ├── dashboard/          # Main dashboard
│   └── reports/            # Analytics
└── shared/                  # Shared across features
```

## 📚 Documentation

Full documentation in [`docs/`](docs/) folder:

- [Technical PRD](docs/prd-technical/001.technical-prd.md)
- [Business Logic](docs/business/002.business-logic.md)
- [Design System](DESIGN.md)
- [Agent Rules](AGENT.md)

## 🐛 Development Notes

See [`AGENT.md`](AGENT.md) for development workflow guidelines.

## 📝 License

MIT License - See LICENSE file

---

Built with ❤️ for UMKM florists
