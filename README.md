# MapMyTree 🌳

MapMyTree is a beautiful Flutter-based mobile application designed to gamify tree planting and carbon footprint tracking. Plant trees, map them to your location, and watch your eco-contributions grow!

## Features 🚀

*   **Interactive Map:** View your local area and see where trees have been planted by you and the community.
*   **Plant a Tree:** A seamless, multi-step form to log newly planted trees, including species selection, geolocation, details, and optional photo uploads.
*   **Tree Details & Health:** View comprehensive stats about each mapped tree, including height, age, carbon offset, and health score.
*   **User Profiles & Achievements:** Track your personal eco-journey, earn badges, and monitor your personal CO2 offset.
*   **Modern Aesthetics:** A premium, smooth, and vibrant user interface built with Flutter.

## Prerequisites 🛠️

Before you begin, ensure you have the following installed and configured:
*   [Flutter SDK](https://flutter.dev/docs/get-started/install) (version `>=3.0.0 <4.0.0`)
*   [Dart SDK](https://dart.dev/get-dart)
*   A **[Supabase](https://supabase.com/)** Project (Free Tier) to host the PostgreSQL database and Auth layer.
*   A **Google Cloud** Project with an OAuth 2.0 Web Client ID (for Google Sign-In).

## Getting Started 🏃‍♂️

Follow these steps to get the full-stack project running on your local machine:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/codewithharshit17/MapMyTree.git
    cd MapMyTree/mapmytree
    ```

2.  **Environment Variables (`.env`):**
    For security, API keys are excluded from source control. Create a `.env` file in the `mapmytree` root:
    ```env
    SUPABASE_URL=your_supabase_url
    SUPABASE_ANON_KEY=your_supabase_anon_key
    WEB_CLIENT_ID=your_google_web_client_id
    ```

3.  **Database Setup:**
    Run the provided SQL Schema script directly in your Supabase Dashboard's SQL Editor to automatically spin up the `users`, `ngos`, and `trees` tables and configure all Row Level Security triggers. (Ensure Email auth and Google Auth are strictly enabled).

4.  **Install dependencies & Run:**
    ```bash
    flutter pub get
    flutter run
    ```

## Project Structure 📁

The core Flutter application code is located in the `mapmytree/lib/` directory:
*   `/screens`: Contains all the main UI views (`home_screen.dart`, `map_screen.dart`, `plant_tree_screen.dart`, etc.)
*   `/widgets`: Reusable UI components (`bottom_nav.dart`, `tree_card.dart`, etc.)
*   `/models`: Data models for the application (`tree_model.dart`)
*   `app_theme.dart`: Centralized color palettes and styling definitions.

## Built With 💙

*   [Flutter](https://flutter.dev/) - UI toolkit for building natively compiled applications for mobile, web, and desktop.
*   [Google Fonts](https://pub.dev/packages/google_fonts) - Dynamic typography (Nunito).
