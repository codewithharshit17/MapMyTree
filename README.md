# 🌳 MapMyTree - Flutter App

A beautiful Flutter recreation of the MapMyTree Mobile App UI, originally designed in Figma.

## ✨ Screens

| Screen | Description |
|--------|-------------|
| **Splash Screen** | Animated logo reveal with elastic spring effect |
| **Onboarding** | 3-page swipeable introduction with dot indicators |
| **Home** | Dashboard with stats, map preview, category filters, and tree list |
| **Map Screen** | Interactive map view with custom-painted terrain and tree pins |
| **Explore** | Searchable tree list with real-time filtering |
| **Tree Detail** | Full tree info with health bar, stats grid, and tabs |
| **Profile** | User stats, achievements, and settings menu |

## 🎨 Design

- **Color Palette**: Deep forest greens (`#1B5E20`, `#2E7D32`, `#558B2F`) with teal and orange accents
- **Typography**: Nunito font family (weight 400–800) for organic, rounded feel
- **Cards**: Soft shadows, rounded corners (18px radius)
- **Animations**: Spring-based splash, slide-in text, animated category chips

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart SDK 3.0+
- A [Supabase](https://supabase.com) Account (Free Tier is fine)
- A Google Cloud Platform project with OAuth 2.0 Web Client ID configured

### Backend Setup (Supabase)
1. Provide a Postgres database by creating a new Supabase project.
2. Under **SQL Editor**, run the provided schema to create the `users`, `ngos`, `trees`, and `sponsorship_requests` tables, along with Row Level Security (RLS) policies and automatic user creation triggers.
3. Under **Authentication > Providers**, enable Email/Password (ensure "Confirm email" is disabled for immediate testing) and Google Sign-In (using your Web Client ID).

### Environment Variables
For security, this project uses `flutter_dotenv`. Create a `.env` file in the root of the `mapmytree` directory:
```env
SUPABASE_URL=your_project_url_here
SUPABASE_ANON_KEY=your_anon_key_here
WEB_CLIENT_ID=your_google_web_client_id_here
```

### Font Setup
Download the **Nunito** font from [Google Fonts](https://fonts.google.com/specimen/Nunito) and place the font files in a `fonts/` directory:
```
fonts/
├── Nunito-Regular.ttf
├── Nunito-Medium.ttf
├── Nunito-SemiBold.ttf
├── Nunito-Bold.ttf
└── Nunito-ExtraBold.ttf
```

### Run
```bash
flutter pub get
flutter run
```

## 📁 Project Structure

```
lib/
├── main.dart                    # Entry point & Supabase init
├── app_theme.dart               # Color palette & theme
├── providers/                   # State management
│   ├── auth_provider.dart       # Supabase Auth state watcher
│   └── ngo_dashboard_provider.dart # Dashboard State management
├── models/                      # Supabase Postgres Models
│   ├── tree_model.dart          
│   ├── user_model.dart
│   └── ngo_model.dart           
├── screens/
│   ├── splash_screen.dart       # Animated splash & Auth redirect
│   ├── auth_screen.dart         # Login UI (Supabase Email & Native Google Sign-In)
│   ├── home_screen.dart         # Main dashboard
│   ├── map_screen.dart          # Map view
│   ├── explore_screen.dart      # Search & browse
│   ├── tree_detail_screen.dart  # Tree info detail
│   └── ngo_dashboard/           # Comprehensive NGO Management portal
└── services/
    ├── auth_service.dart        # Supabase API logic
    ├── tree_service.dart        # CRUD for public.trees
    └── ngo_service.dart         # Real-time Requests
```

## 🌍 Features

- 🗺️ **Interactive Map View** — Custom-painted map with tree pin markers
- 🌱 **Tree Catalogue** — Browse and search all mapped trees
- 🏢 **NGO Dashboard** — A complete portal for NGOs to track progress, approve sponsorships, and measure carbon offsets.
- 🔐 **Robust Authentication** — Supabase Auth integrated with native Google Sign-in v7 APIs.
- 📊 **Health & Analytics Tracking** — Visual health scores and real-time backend analytical charts.
- 📍 **Tree Detail** — Full info: species, CO₂ offset, age, planting history

## 📦 Dependencies

This app utilizes a modern Flutter stack:
- `supabase_flutter` — Complete Backend-as-a-Service integration
- `google_sign_in` — Native Google OAuth authentication
- `provider` — Predictable state management
- `flutter_dotenv` — API Key security
- `fl_chart` — Analytics data visualization
- `google_fonts` — Dynamic typography


---

> Inspired by the [Figma design](https://www.figma.com/design/4pgztiVJOIOFNZsHcQRYgG/MapMyTree-Mobile-App-UI) by codewithharshit17
