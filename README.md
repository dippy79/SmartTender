# 🏗️ SmartTender Hub - SaaS Multi-Tenant Platform

**SmartTender Hub** is a premium, scalable Software-as-a-Service (SaaS) platform designed for construction, engineering, and service-based organizations. It simplifies the tender bidding process through accurate estimations, AI-powered insights, and a centralized live tender feed.

## 🚀 Key Features

- **Multi-Tenant SaaS Architecture**: Fully isolated organization-based data management with Row Level Security (RLS) enforced by Supabase.
- **Smart Tender Tool**: An itemized bidding calculator with auto-calculation of Base Price, GST, and Profit Margins.
- **AI Tender Advisor**: Integrated with Google Gemini for quote analysis, market trend insights, and risk assessment.
- **Live Tender Feed**: A real-time stream of Government and Private tenders, filterable by category.
- **Advanced Admin Panel**: Organization-level user management, role-based access control (Super Admin vs. Admin), and status tracking.
- **Secure Developer Bypass**: A hidden override system using a secret access code for rapid testing and administration.
- **Modern Premium UI**: A consistent and accessible dark theme optimized for Web and Mobile, built with a scalable Sliver-based layout.

## 🛠️ Tech Stack

- **Frontend**: Flutter (Cross-platform for Web, Android, iOS)
- **Backend**: Supabase (PostgreSQL, Real-time Streams, Auth)
- **AI Engine**: Google Generative AI (Gemini Pro)
- **Core Utilities**: `flutter_dotenv`, `share_plus`, `provider`

## 📱 Getting Started

### 1. Prerequisites
- Flutter SDK (3.x or higher)
- A live Supabase project.
- A Google AI (Gemini) API Key.

### 2. Configuration
Create a `.env` file in the project root with the following keys:
```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
GEMINI_API_KEY=your_gemini_api_key
ADMIN_BYPASS_CODE=1202
```

### 3. Installation
```bash
# Clone the repository
git clone https://github.com/dippy79/SmartTender.git

# Navigate to the project directory
cd SmartTender

# Install dependencies
flutter pub get

# Run the application on your desired platform
flutter run -d chrome
```

## 📈 Project Roadmap

- [x] **Phase 1**: Initial Prototype & UI/UX Design
- [x] **Phase 2**: Core Supabase Integration & User Authentication
- [x] **Phase 3**: Scalable Multi-Tenant SaaS Backend with RLS
- [x] **Phase 4**: AI Advisor Integration (Gemini Pro)
- [ ] **Phase 5**: PDF Generation Engine for Bid Reports
- [ ] **Phase 6**: Payment Gateway Integration for Subscriptions

## ⚖️ License
This project is proprietary and intended for authorized use by the SmartTender organization.
