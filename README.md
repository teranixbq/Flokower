# Flokower 🌸

Mobile inventory and sales management system for UMKM florists.

## ✨ Features (MVP)

- Material & Product CRUD management
- **Smart stock management**: Auto-merge duplicate materials (add to existing stock)
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
flutter run -d chrome  # Web
flutter run            # Android
```

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
