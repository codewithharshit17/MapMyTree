# MapMyTree 🌳

MapMyTree is a beautiful Flutter-based mobile application designed to gamify tree planting and carbon footprint tracking. Plant trees, map them to your location, and watch your eco-contributions grow!

## Features 🚀

*   **Interactive Map:** View your local area and see where trees have been planted by you and the community.
*   **Plant a Tree:** A seamless, multi-step form to log newly planted trees, including species selection, geolocation, details, and optional photo uploads.
*   **Tree Details & Health:** View comprehensive stats about each mapped tree, including height, age, carbon offset, and health score.
*   **User Profiles & Achievements:** Track your personal eco-journey, earn badges, and monitor your personal CO2 offset.
*   **Modern Aesthetics:** A premium, smooth, and vibrant user interface built with Flutter.

## Prerequisites 🛠️

Before you begin, ensure you have the following installed:
*   [Flutter SDK](https://flutter.dev/docs/get-started/install) (version `>=3.0.0 <4.0.0`)
*   [Dart SDK](https://dart.dev/get-dart)
*   An IDE like [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio)
*   An Android Emulator or physical device for testing

## Getting Started 🏃‍♂️

Follow these steps to get the project running on your local machine:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/codewithharshit17/MapMyTree.git
    ```

2.  **Navigate to the project directory:**
    ```bash
    cd MapMyTree/mapmytree
    ```

3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

4.  **Run the application:**
    Ensure your emulator is running or device is connected, then execute:
    ```bash
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
