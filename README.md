SmartTender 🏗️✨AI-Powered Tender Management System for Indian contractors.
Track tenders, calculate BOQs with live commodity rates,
✅ 0 Issues Fixed - SharePlus syntax, deprecations resolved. Production-ready Dart with Material 3 UI.
cd smart_tender
flutter pub get
# Configure your .env file
flutter run
Environment ConfigurationCopy .env.example to .env and add your keys:Code snippetSUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
GEMINI_API_KEY=your_gemini_api_key
⚠️ SECURITY: Never commit .env or API keys. .gitignore is configured to protect your secrets.🔐 Security Check✅ No hardcoded secrets found. All config from .env via flutter_dotenv.✅ .env and secrets.dart are strictly ignored in .gitignore.📂 Project Structurelib/
├── config/         # API keys & environment configuration
├── core/           # Theme, constants, and utilities
├── models/         # Data models
├── services/       # Repositories & Supabase services
├── presentation/   # UI Screens & reusable widgets
└── main.dart       # Entry point
🧪 Testing & QualityBashflutter analyze     # Should show 0 issues
flutter test        # Run unit/widget tests
🚀 DeploymentWeb: flutter build web --releaseAndroid: flutter build apk --releaseiOS: flutter build ios --release⚖️ LicenseThis project is proprietary and intended for authorized use by the Author Amit Sharma.🙏 AcknowledgmentsFlutter & Dart TeamsSupabase TeamGoogle Gemini AI⭐ Star this repo if it helps your tender business!