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
├── main.dart                    # Entry point
├── app_theme.dart               # Color palette & theme
├── models/
│   └── tree_model.dart          # Tree data model
├── screens/
│   ├── splash_screen.dart       # Animated splash
│   ├── onboarding_screen.dart   # 3-step onboarding
│   ├── home_screen.dart         # Main dashboard
│   ├── map_screen.dart          # Map view
│   ├── explore_screen.dart      # Search & browse
│   ├── tree_detail_screen.dart  # Tree info detail
│   └── profile_screen.dart      # User profile
└── widgets/
    ├── tree_card.dart           # Tree list card
    ├── stat_card.dart           # Stat summary card
    └── bottom_nav.dart          # Bottom navigation bar
```

## 🌍 Features

- 🗺️ **Interactive Map View** — Custom-painted map with tree pin markers
- 🌱 **Tree Catalogue** — Browse and search all mapped trees
- 📊 **Health Tracking** — Visual health score with progress bars
- 📍 **Tree Detail** — Full info: species, CO₂ offset, age, planting history
- 🎯 **Category Filters** — Filter by tree type (Oak, Maple, Flowering, etc.)
- 👤 **Profile & Badges** — Track personal impact and achievements

## 📦 Dependencies

Only standard Flutter packages — no third-party map SDK required:
- `flutter` (SDK)
- `cupertino_icons`

The map is rendered using Flutter's `CustomPainter` for a dependency-free implementation.

---

> Inspired by the [Figma design](https://www.figma.com/design/4pgztiVJOIOFNZsHcQRYgG/MapMyTree-Mobile-App-UI) by codewithharshit17
