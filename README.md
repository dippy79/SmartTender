# SmartTender

A Flutter-based tender and quotation management application that helps businesses track, manage, and analyze their tenders efficiently. The app includes AI-powered smart advice features to help improve tender accuracy and winning chances.

## Features

### Core Features
- 📊 **Dashboard** - View tender statistics (Won, Lost, Pending counts and total value)
- 📝 **Tender Management** - Create, edit, and manage tenders with detailed BOQ (Bill of Quantities)
- 📈 **History Tracking** - Track past tenders and analyze performance
- 🏷️ **Business Categories** - Organize tenders by business type
- 📄 **PDF Generation** - Generate professional PDF documents for tenders
- 🤖 **AI Smart Advice** - Get AI-powered recommendations based on your tender history

### Technical Features
- Supabase backend for data persistence
- Gemini AI integration for smart recommendations
- Real-time tender status updates
- Professional Hinglish AI responses

## Prerequisites

Before running this project, make sure you have:

1. **Flutter SDK** (version 3.0 or higher)
2. **Dart SDK** (version 3.0 or higher)
3. **Supabase Account** - For backend database
4. **Google Gemini API Key** - For AI features (optional)

## Installation

### 1. Clone the Repository
```
bash
git clone <repository-url>
cd smart_tender
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Environment Variables

Create a `.env` file in the project root (this file is already gitignored):

```
env
# Supabase Configuration
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# AI Configuration (Optional)
GEMINI_API_KEY=your_gemini_api_key

# Admin PIN (Optional - for owner access)
ADMIN_PIN=your_admin_pin
```

Or set environment variables in your IDE/terminal:

**Windows (CMD):**
```
cmd
set GEMINI_API_KEY=your_api_key_here
set ADMIN_PIN=your_pin_here
```

**Windows (PowerShell):**
```
powershell
$env:GEMINI_API_KEY="your_api_key_here"
$env:ADMIN_PIN="your_pin_here"
```

**macOS/Linux:**
```
bash
export GEMINI_API_KEY="your_api_key_here"
export ADMIN_PIN="your_pin_here"
```

### 4. Set Up Supabase

1. Create a new Supabase project at [supabase.com](https://supabase.com)
2. Run the following SQL in your Supabase SQL Editor:

```
sql
-- Create tenders table
CREATE TABLE tenders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  business_type TEXT NOT NULL,
  items JSONB NOT NULL,
  total_base DOUBLE PRECISION NOT NULL,
  margin DOUBLE PRECISION NOT NULL,
  freight DOUBLE PRECISION DEFAULT 0,
  labour DOUBLE PRECISION DEFAULT 0,
  status TEXT DEFAULT 'Pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create business_categories table
CREATE TABLE business_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE
);

-- Enable Row Level Security (optional)
ALTER TABLE tenders ENABLE ROW LEVEL SECURITY;
ALTER TABLE business_categories ENABLE ROW LEVEL SECURITY;
```

3. Update your Supabase configuration in the app

### 5. Run the App
```
bash
flutter run
```

## Project Structure

```
smart_tender/
├── lib/
│   ├── config/
│   │   └── app_config.dart       # Application configuration
│   ├── models/
│   │   ├── boq_item.dart         # BOQ item model
│   │   └── category_model.dart   # Category model
│   ├── screens/
│   │   ├── home_screen.dart      # Main dashboard
│   │   ├── tender_input_screen.dart    # Create/edit tenders
│   │   ├── tender_details_screen.dart  # View tender details
│   │   ├── history_screen.dart   # Tender history
│   │   └── registration_screen.dart    # User registration
│   ├── services/
│   │   ├── ai_service.dart       # AI-powered features
│   │   ├── database_service.dart # Supabase database operations
│   │   ├── calculation_service.dart    # Tender calculations
│   │   └── pdf_service.dart      # PDF generation
│   ├── widgets/
│   │   └── tender_chart.dart      # Charts and visualizations
│   └── main.dart                 # App entry point
├── pubspec.yaml                  # Dependencies
└── README.md                     # This file
```

## Configuration

### Admin PIN
The admin PIN is used for owner-only access to certain features. Set it via:
- Environment variable: `ADMIN_PIN`
- Or configure in your local setup

### Gemini AI API Key
To enable AI features:
1. Get an API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Set it via environment variable: `GEMINI_API_KEY`
3. AI features will automatically be enabled when the key is configured

## Dependencies

Key dependencies used in this project:

- `supabase_flutter` - Supabase database integration
- `google_generative_ai` - Gemini AI integration
- `pdf` - PDF generation
- `printing` - PDF printing and sharing
- `fl_chart` - Charts and visualizations
- `intl` - Date/number formatting

See `pubspec.yaml` for complete dependency list.

## Screenshots

The app includes:
- Dashboard with tender statistics
- Tender creation form with BOQ items
- AI-powered smart advice
- Tender history and analytics
- PDF document generation

## License

This project is private and for internal use only.

## Support

For issues or questions, please contact the development team.

## Acknowledgments

- [Flutter](https://flutter.dev) - UI framework
- [Supabase](https://supabase.com) - Backend-as-a-Service
- [Google Gemini AI](https://gemini.google.com) - AI capabilities
