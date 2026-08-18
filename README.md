# Flokower 🌸

Mobile inventory and sales management system for UMKM florists.

## ✨ Features (MVP)

- Material & Product CRUD management
- Soft stock reservation system (in_progress → completed)
- Custom ingredient override per transaction
- Real-time multi-user synchronization
- Bento grid dashboard design
- Excel export functionality

## 🛠️ Tech Stack

- **Flutter**: Cross-platform mobile framework
- **Firebase**: Backend as a Service
- **Riverpod**: State management
- **Bento Grid**: Modern UI layout

## 🚀 Quick Start

```bash
# 1. Clone repository
git clone https://github.com/teranixbq/Flokower.git
cd Flokower

# 2. Install dependencies
flutter pub get

# 3. Configure Firebase
# See docs/FIREBASE_SETUP.md for detailed instructions

# 4. Run app
flutter run
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
