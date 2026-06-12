# 🌳 MapMyTree - Flutter App

> **A collaborative mobile platform for tree mapping, environmental impact tracking, and NGO-driven sustainability initiatives.**

<img width="1747" height="843" alt="MapMyTree Dashboard" src="https://github.com/user-attachments/assets/2eaf58e1-20bf-44e5-b80a-2afb30edda41" />

---

## 📖 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Screenshots & Screens](#screenshots--screens)
- [Design System](#design-system)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [API & Data Models](#api--data-models)
- [Development Guidelines](#development-guidelines)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [FAQ](#faq)
- [License](#license)

---

## 📱 Overview

**MapMyTree** is a Flutter-based mobile application designed to bridge the gap between environmental conservation and community engagement. It enables users to:

- **Discover & Map Trees**: Explore trees in your area through an interactive map interface with real-time location data
- **Track Environmental Impact**: Monitor CO₂ offset metrics, tree health indicators, and carbon sequestration potential
- **Support NGOs**: Connect with non-governmental organizations managing reforestation and tree care initiatives
- **Foster Community**: Participate in sponsorships, track collective environmental metrics, and celebrate green milestones

The app targets three primary user personas:
1. **Individual Users** — Tree enthusiasts and eco-conscious citizens
2. **NGO Coordinators** — Organizations managing tree planting and care programs
3. **Environmental Advocates** — Community leaders promoting green initiatives

---

## 🌍 Features

### Core Features

- 🗺️ **Interactive Geospatial Map**
  - Custom-painted terrain visualization with tree pin markers
  - Real-time location tracking and map positioning
  - Zoom controls and smooth pan animations
  - Category-based filtering (Native, Fruit, Medicinal, etc.)

- 🌱 **Comprehensive Tree Catalogue**
  - Browse thousands of mapped trees with rich metadata
  - Advanced search and filtering capabilities
  - Real-time data synchronization with backend
  - Tree health status indicators and environmental metrics

- 🏢 **NGO Management Dashboard**
  - Complete portal for NGO coordinators to track initiatives
  - Sponsorship request approval workflows
  - Progress monitoring and performance analytics
  - Carbon offset calculations and environmental reporting
  - Real-time notification system for request management

- 🔐 **Secure Authentication**
  - Email/Password authentication via Supabase
  - Native Google Sign-in integration (OAuth 2.0)
  - Role-based access control (User, NGO, Admin)
  - Session management with automatic token refresh

- 📊 **Analytics & Health Tracking**
  - Visual health score indicators for each tree
  - CO₂ offset tracking and carbon sequestration metrics
  - User contribution statistics and badges
  - Real-time analytical charts powered by FL Chart
  - Historical data visualization and trend analysis

- 📍 **Detailed Tree Profiles**
  - Complete species information and botanical details
  - Planting date, age, and growth metrics
  - Carbon offset potential and environmental impact
  - Sponsorship history and community contributions
  - Photo galleries and historical records

- 👤 **User Profiles & Achievements**
  - Personal statistics and contribution tracking
  - Achievement badges and environmental milestones
  - Settings management and preference customization
  - Privacy controls and data management

---

## ✨ Screens & User Flows

| Screen | Purpose | Key Features |
|--------|---------|--------------|
| **Splash Screen** | Initial app load | Animated logo with elastic spring effect, auth redirect logic |
| **Authentication Screen** | User login/registration | Email/password login, Google Sign-in, signup with validation |
| **Onboarding Flow** | New user introduction | 3-page swipeable carousel, dot indicators, feature highlights |
| **Home Dashboard** | Main hub after login | Statistics widget, recent trees, category filters, quick actions |
| **Map View** | Spatial tree discovery | Custom-painted map, tree pins, zoom/pan controls, category filters |
| **Explore Screen** | Tree search & browse | Real-time search, advanced filters, list view with sorting options |
| **Tree Detail View** | Full tree information | Tabs for overview/health/history, stats grid, sponsorship options |
| **NGO Dashboard** | Management portal | Overview metrics, sponsorship requests list, analytics charts, action buttons |
| **Profile Screen** | User account & settings | Stats, achievements, account settings, preferences, logout |

### User Flow Diagram

```
Splash Screen
    ↓
[Authenticated?] → No → Authentication Screen
    ↓ Yes              ↓
    ├──────────────→ Home Screen
                       ↓
         ┌─────────────┼─────────────┐
         ↓             ↓             ↓
    Map Screen    Explore Screen   Profile Screen
         ↓             ↓             ↓
    Tree Detail ← ─ ─ ┘             ↓
                                NGO Dashboard
```

---

## 🎨 Design System

### Color Palette

| Element | Color | Hex Code | Usage |
|---------|-------|----------|-------|
| Primary Green | Deep Forest Green | `#1B5E20` | Headers, primary buttons, highlights |
| Secondary Green | Medium Forest Green | `#2E7D32` | Secondary elements, hover states |
| Tertiary Green | Light Forest Green | `#558B2F` | Backgrounds, light accents |
| Accent Teal | Teal Blue | `#00897B` | Links, interactive elements |
| Accent Orange | Warm Orange | `#FF6F00` | Notifications, warnings, CTAs |
| Neutral Light | Off-white | `#F5F5F5` | Card backgrounds, light surfaces |
| Neutral Dark | Dark Gray | `#212121` | Text, dark surfaces |

### Typography

- **Font Family**: Nunito (Google Fonts) — Organic, friendly, rounded aesthetic
- **Weights**: 400 (Regular) → 800 (ExtraBold)
- **Hierarchy**:
  - **Display**: 32px, Weight 700 (Headings)
  - **Headline**: 24px, Weight 600 (Section titles)
  - **Body**: 16px, Weight 400 (Main text)
  - **Caption**: 12px, Weight 400 (Helper text)

### Component Styles

- **Cards**: Rounded corners (18px radius), soft shadows (0-4px blur), padding 16px
- **Buttons**: Minimum height 48px, rounded corners (12px), ripple effect on tap
- **Input Fields**: Borders with 8px radius, clear focus states, validation styling
- **Icons**: Material Design 2, 24px default size, color-matched to context
- **Animations**: Spring physics for natural motion, 300-500ms duration for transitions

---

## 💻 Tech Stack

### Frontend
- **Framework**: Flutter 3.0+ with Dart 3.0+
- **State Management**: Provider pattern for reactive, predictable state handling
- **Navigation**: GoRouter (if implemented) or Flutter's built-in Navigator
- **UI Components**: Custom widgets, Material Design 3, cupertino for iOS parity
- **Maps**: Custom-painted canvas for terrain visualization
- **Charts**: FL Chart for analytics and data visualization
- **Fonts**: Google Fonts integration for Nunito family

### Backend
- **Database**: Supabase (PostgreSQL) with real-time subscriptions
- **Authentication**: Supabase Auth + Google OAuth 2.0 API
- **Storage**: Supabase Storage for image/file uploads (if used)
- **Security**: Row-Level Security (RLS) policies, JWT token management
- **APIs**: RESTful via Supabase PostgREST

### Development Tools
- **Version Control**: Git & GitHub
- **IDE**: VS Code or Android Studio/IntelliJ IDEA
- **Testing**: Flutter's built-in unit/widget test framework
- **CI/CD**: (Optional) GitHub Actions for automated builds and deployments

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK 3.0+** — [Installation Guide](https://flutter.dev/docs/get-started/install)
- **Dart SDK 3.0+** — Included with Flutter
- **Git** — [Installation Guide](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- **A Supabase Account** — Sign up at [supabase.com](https://supabase.com) (Free Tier available)
- **Google Cloud Platform Project** — With OAuth 2.0 Web Client ID configured
- **IDE/Editor** — VS Code, Android Studio, or IntelliJ IDEA
- **Android SDK** (for Android development) — API Level 21+ minimum
- **iOS Deployment Target** (for iOS) — 12.0+ (if developing on macOS)

### Step 1: Clone the Repository

```bash
git clone https://github.com/yourusername/MapMyTree.git
cd MapMyTree
```

### Step 2: Install Flutter Dependencies

```bash
flutter pub get
```

### Step 3: Backend Setup (Supabase)

#### 3.1 Create a Supabase Project
1. Visit [supabase.com](https://supabase.com) and create a new project
2. Select your preferred region and database password
3. Wait for the project to initialize (3-5 minutes)

#### 3.2 Create Database Tables & Schema

Navigate to **SQL Editor** in your Supabase dashboard and run the following schema:

```sql
-- Users table (extends Supabase Auth)
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email VARCHAR(255) NOT NULL UNIQUE,
  full_name VARCHAR(255),
  avatar_url TEXT,
  bio TEXT,
  user_type VARCHAR(50) DEFAULT 'individual', -- 'individual', 'ngo', 'admin'
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- NGOs table
CREATE TABLE public.ngos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id),
  ngo_name VARCHAR(255) NOT NULL,
  description TEXT,
  logo_url TEXT,
  contact_email VARCHAR(255),
  website TEXT,
  verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Trees table
CREATE TABLE public.trees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  species VARCHAR(255) NOT NULL,
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  health_score INTEGER DEFAULT 50, -- 0-100
  age_years INTEGER,
  co2_offset_kg DECIMAL(10, 2) DEFAULT 0,
  planting_date DATE,
  planted_by UUID REFERENCES public.users(id),
  category VARCHAR(100), -- 'Native', 'Fruit', 'Medicinal', etc.
  photo_url TEXT,
  description TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Sponsorships table
CREATE TABLE public.sponsorship_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tree_id UUID NOT NULL REFERENCES public.trees(id),
  user_id UUID NOT NULL REFERENCES public.users(id),
  ngo_id UUID REFERENCES public.ngos(id),
  status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
  sponsorship_amount DECIMAL(10, 2),
  message TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ngos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trees ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sponsorship_requests ENABLE ROW LEVEL SECURITY;

-- Create RLS policies (example for users table)
CREATE POLICY "Users can view all users" ON public.users
  FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

-- Auto-create user profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email)
  VALUES (NEW.id, NEW.email);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
```

#### 3.3 Configure Authentication Providers

1. Navigate to **Authentication → Providers** in Supabase dashboard
2. **Email/Password**: Enable (uncheck "Confirm email" for development testing)
3. **Google**: Enable and enter your Google Web Client ID
   - Generate credentials at [Google Cloud Console](https://console.cloud.google.com/)
   - Create OAuth 2.0 Web Client ID
   - Add redirect URIs: `https://yourproject.supabase.co/auth/v1/callback`

### Step 4: Configure Environment Variables

Create a `.env` file in the project root (`mapmytree/` directory):

```env
# Supabase Configuration
SUPABASE_URL=https://your-project-url.supabase.co
SUPABASE_ANON_KEY=your_anonymous_key_here

# Google OAuth
WEB_CLIENT_ID=your_google_web_client_id.apps.googleusercontent.com

# Optional: API Keys for external services
# GOOGLE_MAPS_API_KEY=your_google_maps_key_here
```

**Important**: Add `.env` to `.gitignore` to prevent credential leaks!

```gitignore
.env
.env.local
.env.*.local
```

### Step 5: Download and Setup Custom Fonts

1. Download the **Nunito** font family from [Google Fonts](https://fonts.google.com/specimen/Nunito)
2. Create a `fonts/` directory in your project root:
   ```bash
   mkdir fonts
   ```
3. Place the font files (TTF format) in the `fonts/` directory:
   ```
   fonts/
   ├── Nunito-Regular.ttf
   ├── Nunito-Medium.ttf
   ├── Nunito-SemiBold.ttf
   ├── Nunito-Bold.ttf
   └── Nunito-ExtraBold.ttf
   ```
4. Update `pubspec.yaml` to reference the fonts:
   ```yaml
   flutter:
     fonts:
       - family: Nunito
         fonts:
           - asset: fonts/Nunito-Regular.ttf
             weight: 400
           - asset: fonts/Nunito-Medium.ttf
             weight: 500
           - asset: fonts/Nunito-SemiBold.ttf
             weight: 600
           - asset: fonts/Nunito-Bold.ttf
             weight: 700
           - asset: fonts/Nunito-ExtraBold.ttf
             weight: 800
   ```

### Step 6: Run the Application

```bash
# Get updated dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Run in release mode (for production)
flutter run --release

# Run on specific platform
flutter run -d chrome         # Web
flutter run -d emulator-5554  # Android emulator
flutter run -d iPhone         # iOS simulator
```

---

## 📁 Project Structure

```
lib/
├── main.dart                           # Application entry point & Supabase initialization
├── app_theme.dart                      # Global theme, color palette, and typography
│
├── core/                               # Core application utilities
│   ├── constants.dart                  # App-wide constants and configuration
│   ├── extensions.dart                 # Dart extension methods
│   └── utils.dart                      # Helper functions and utilities
│
├── models/                             # Data models (Supabase entities)
│   ├── tree_model.dart                 # Tree entity with serialization
│   ├── user_model.dart                 # User profile model
│   ├── ngo_model.dart                  # NGO organization model
│   └── sponsorship_model.dart          # Sponsorship request model
│
├── providers/                          # State management (Provider pattern)
│   ├── auth_provider.dart              # Authentication state and logic
│   ├── tree_provider.dart              # Tree data and CRUD operations
│   ├── user_provider.dart              # User profile state
│   └── ngo_dashboard_provider.dart     # NGO dashboard state management
│
├── screens/                            # UI Screens
│   ├── splash_screen.dart              # Animated splash screen & auth gate
│   ├── auth_screen.dart                # Login/signup UI
│   ├── onboarding_screen.dart          # First-time user introduction
│   ├── home_screen.dart                # Main dashboard
│   ├── map_screen.dart                 # Interactive map view
│   ├── explore_screen.dart             # Tree search & browse
│   ├── tree_detail_screen.dart         # Individual tree details
│   ├── profile_screen.dart             # User profile & settings
│   │
│   └── ngo_dashboard/                  # NGO Management Portal
│       ├── ngo_dashboard_screen.dart   # Main NGO dashboard view
│       ├── sponsorship_requests.dart   # Request management interface
│       ├── analytics_view.dart         # Performance charts & metrics
│       └── settings_view.dart          # NGO settings panel
│
├── services/                           # Backend integration layer
│   ├── auth_service.dart               # Supabase Auth API calls
│   ├── tree_service.dart               # Tree CRUD operations
│   ├── user_service.dart               # User profile operations
│   ├── ngo_service.dart                # NGO-specific operations
│   └── database_service.dart           # Generic database utilities
│
└── widgets/                            # Reusable UI components
    ├── common/
    │   ├── app_button.dart             # Custom button widget
    │   ├── app_card.dart               # Styled card component
    │   ├── app_input_field.dart        # Text input with validation
    │   └── app_appbar.dart             # Custom AppBar
    │
    ├── tree_widgets/
    │   ├── tree_card.dart              # Tree list item
    │   ├── tree_pin.dart               # Map marker widget
    │   └── health_indicator.dart       # Health score display
    │
    ├── ngo_widgets/
    │   ├── sponsorship_card.dart       # Sponsorship request card
    │   ├── metric_chart.dart           # Analytics chart widget
    │   └── request_approval_dialog.dart # Approval workflow UI
    │
    └── animations/
        ├── elastic_animation.dart      # Spring/elastic animation
        ├── slide_animation.dart        # Slide transitions
        └── fade_animation.dart         # Fade transitions
```

---

## 🔄 API & Data Models

### Authentication Flow

```
User Input (Email/Password or Google Sign-In)
         ↓
  Supabase Auth API
         ↓
  JWT Token Generated
         ↓
  Stored in Secure Local Storage
         ↓
  Auto-attached to all API Requests
         ↓
  Token Refresh on Expiry
```

### Tree Data Model

```json
{
  "id": "uuid",
  "species": "Neem",
  "latitude": 28.6139,
  "longitude": 77.2090,
  "health_score": 85,
  "age_years": 5,
  "co2_offset_kg": 150.25,
  "planting_date": "2021-06-15",
  "planted_by": "user-uuid",
  "category": "Medicinal",
  "photo_url": "image-url",
  "description": "Healthy neem tree in public park",
  "created_at": "2021-06-15T10:30:00Z",
  "updated_at": "2026-06-13T14:22:00Z"
}
```

### Sponsorship Request Model

```json
{
  "id": "uuid",
  "tree_id": "tree-uuid",
  "user_id": "user-uuid",
  "ngo_id": "ngo-uuid",
  "status": "pending",
  "sponsorship_amount": 1500.00,
  "message": "Sponsoring tree care",
  "created_at": "2026-06-01T08:15:00Z",
  "updated_at": "2026-06-13T12:00:00Z"
}
```

---

## 🛠️ Development Guidelines

### Code Style & Conventions

- **Dart Style Guide**: Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- **Naming**: Use camelCase for variables/methods, PascalCase for classes
- **Comments**: Use `///` for public documentation, `//` for inline comments
- **Formatting**: Run `dart format lib/` to auto-format code
- **Linting**: Run `dart analyze` to check for issues

### State Management Patterns

1. **Providers**: Use `ChangeNotifier` for complex state, `ValueNotifier` for simple values
2. **Separation of Concerns**: Services handle backend, Providers handle UI state
3. **Error Handling**: Wrap async calls in try-catch, expose errors to UI via Provider
4. **Dependency Injection**: Use Provider's `ref.watch()` pattern for dependencies

### Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

### Performance Optimization

- Use `const` constructors where possible
- Implement `shouldRebuild()` in custom Providers
- Lazy-load images with `Image.network()` or `CachedNetworkImage`
- Paginate large lists with scroll listeners
- Profile with DevTools: `flutter pub global run devtools`

---

## 🔧 Troubleshooting

### Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| **Flutter not found** | Ensure Flutter SDK is installed and added to PATH. Run `flutter doctor` |
| **Pub get fails** | Clear cache: `flutter clean && flutter pub get` |
| **Supabase connection error** | Verify `.env` file with correct URLs and keys |
| **Google Sign-In fails** | Check Web Client ID matches project, verify redirect URIs in Google Cloud |
| **Map rendering issues** | Ensure custom painter is properly implemented, test on actual device |
| **State not updating** | Verify `notifyListeners()` is called in Provider, check widget is wrapped with `Consumer` |
| **Build fails on Android** | Run `gradle clean`, ensure Gradle wrapper is executable: `chmod +x android/gradlew` |
| **iOS build issues** | Run `pod install` in iOS folder, update Xcode settings |

### Debug Commands

```bash
# Run with verbose logging
flutter run -v

# Check device connectivity
flutter devices

# Run specific build variant
flutter run --flavor dev -t lib/main_dev.dart

# Check for pub.dev package issues
flutter pub outdated

# Analyze security vulnerabilities
flutter pub audit
```

---

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

### Contribution Workflow

1. **Fork** the repository on GitHub
2. **Create** a feature branch: `git checkout -b feature/your-feature-name`
3. **Make** your changes with clear commit messages
4. **Test** thoroughly: `flutter test`
5. **Push** to your fork: `git push origin feature/your-feature-name`
6. **Create** a Pull Request with a detailed description

### Code Review Checklist

- [ ] Code follows Dart style guide
- [ ] Functionality is tested
- [ ] Documentation is updated
- [ ] No breaking changes introduced
- [ ] Performance impact is considered
- [ ] Security best practices are followed

### Reporting Bugs

1. Use GitHub Issues to report bugs
2. Provide:
   - Clear bug title and description
   - Steps to reproduce
   - Expected vs. actual behavior
   - Device/OS information
   - Relevant logs or screenshots

---

## ❓ FAQ

**Q: How often is the tree data updated?**
A: Real-time updates via Supabase subscriptions. Manual updates via NGO dashboard.

**Q: Is my personal data secure?**
A: Yes, we use Supabase's RLS policies and JWT authentication. All data is encrypted in transit.

**Q: How can I become an NGO partner?**
A: Contact us via the in-app contact form or reach out to the project maintainers.

**Q: Are there plans for a web version?**
A: Flutter Web support is possible. Currently focused on iOS and Android.

**Q: How do I report security vulnerabilities?**
A: Email security concerns directly to the maintainers (do not open public issues).

---

---

## 🙏 Acknowledgments

Special thanks to:
- **Supabase** — Backend-as-a-Service platform
- **Google** — Map APIs and authentication services
- **Flutter Team** — Amazing framework and ecosystem
- **Community Contributors** — All who've contributed code, feedback, and ideas

---

## 📦 Dependencies

This app utilizes a modern Flutter stack:

| Package | Version | Purpose |
|---------|---------|---------|
| `supabase_flutter` | ^1.0.0+ | Backend-as-a-Service integration |
| `google_sign_in` | ^5.4.0+ | Native Google OAuth authentication |
| `provider` | ^6.0.0+ | Predictable state management |
| `flutter_dotenv` | ^5.0.0+ | Secure API key management |
| `fl_chart` | ^0.60.0+ | Analytics and data visualization |
| `google_fonts` | ^5.0.0+ | Dynamic typography (Nunito family) |
| `intl` | ^0.18.0+ | Internationalization & formatting |
| `geolocator` | ^9.0.0+ | GPS location services |
| `geocoding` | ^2.0.0+ | Address-to-coordinate conversion |
| `cached_network_image` | ^3.2.0+ | Optimized image caching |
| `flutter_launcher_icons` | ^0.13.0+ | App icon generation |


---


