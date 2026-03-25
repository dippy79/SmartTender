# SmartTender 🏗️✨

![Flutter](https://flutter.dev/images/logo/flutter-logo-sharing.png)

**AI-Powered Tender Management System** for Indian contractors. Track tenders, calculate BOQs with live commodity rates, analyze opportunities with Gemini AI, and win more bids.

[![Flutter](https://img.shields.io/badge/Flutter-3.19+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4+-green.svg)](https://dart.dev)
[![Status](https://img.shields.io/badge/Status-0_Issues-brightgreen.svg)](https://dart.dev)

## 🚀 Key Features
- **Zero-Issue Analysis** - Clean Dart code, production-ready
- **AI Assistant** - Gemini-powered tender strategy & bidding advice
- **Live Commodity Ticker** - Real-time Steel, Cement, Bitumen rates
- **Advanced BOQ Calculator** - GST-compliant, PDF/Excel export
- **Smart Tender Aggregator** - Multi-source dashboard with sharing
- **Excel Bulk Import** - Validate & process hundreds of tenders
- **Admin Dashboard** - User management, rate updates

## 🛠️ Tech Stack
| Frontend | Backend | AI/ML | Tools |
|----------|---------|-------|-------|
| Flutter 3.19+ (Material 3) | Supabase PostgreSQL | Google Gemini Pro | share_plus 12.0.1 |
| Google Fonts (Playfair Display) | Real-time DB |  | file_picker, excel |

## 📱 Demo Screenshots
*(Add after testing - Web/Mobile captures)*

## 🎯 Quick Start

### 1. Clone & Setup
```bash
git clone https://github.com/yourusername/smart_tender.git
cd smart_tender
flutter pub get
```

### 2. Configure Environment
```bash
cp .env.example .env
# Edit .env with your Supabase + Gemini keys
```

**.env.example:**
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key_here
GEMINI_API_KEY=your_gemini_api_key_here
```

### 3. Run
```bash
flutter run -d chrome  # Web
# or
flutter run            # Mobile (Android/iOS)
```

## 🔐 Security & Best Practices
✅ **No hardcoded secrets** - All from `.env` via `flutter_dotenv`
✅ **.gitignore configured** for `.env`, build artifacts
✅ **0 linter warnings** - `flutter analyze` clean
✅ **Supabase Row Level Security** ready (configure in dashboard)

## 📁 Project Structure
```
lib/
├── config/           # Env & API config (.env loaded)
├── core/             # AppTheme, utils
├── models/           # Tender, BOQ, CommodityRate
├── services/         # Supabase repos, AI service
├── presentation/     # Screens & responsive widgets
└── main.dart
```

## 🧪 Testing & Quality
```bash
flutter analyze     # 0 issues guaranteed
flutter test        # Widget tests
flutter format .    # Auto-format
```

## 🚀 Deployment Targets
| Platform | Command |
|----------|---------|
| Web | `flutter build web --release` |
| Android | `flutter build apk --release` |
| iOS | `flutter build ios --release` |

## 🔄 Contributing
1. Fork repository
2. `git checkout -b feature/your-feature`
3. Commit: `git commit -m "feat: add your feature"`
4. Push & PR: `git push origin feature/your-feature`

**Code style**: Follow Dart analyzer, keep 0 issues.

## 📄 License
MIT License © 2024 Amit Sharma

## 🙏 Acknowledgments
- [Flutter](https://flutter.dev) Team
- [Supabase](https://supabase.com) 
- [Google Gemini](https://ai.google.dev)

---

⭐ **Star if this powers your tender business!** 🏆
