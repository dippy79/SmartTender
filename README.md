SmartTender 🏗️✨AI-Powered Tender Management System for Indian contractors.
Track tenders, calculate BOQs with live commodity rates,
and win more bids.🚀 Key Features0-Issue Codebase - Clean, 
production-ready Dart with Material 3 UI.AI Assistant - Gemini-powered tender analysis and bidding advice.Real-time Commodity Ticker - Live Steel, Cement, Bitumen prices.Professional BOQ Calculator - Auto-calculates with GST, exports PDF/Excel.Tender Aggregator - Multi-source centralized dashboard.Excel Import/Export - Bulk tender management for large projects.🛠️ Tech StackFrontendBackendAI/MLToolsFlutter 3.19+SupabaseGoogle GeminiSharePlus, PDFMaterial 3PostgreSQLExcel, FilePicker🎯 Getting StartedSetupBashgit clone https://github.com/dippy79/SmartTender.git
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