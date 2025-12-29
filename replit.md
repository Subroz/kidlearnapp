# KidLearn Flutter App

## Overview
A beautiful, interactive kids learning app built with Flutter for web. Features bilingual support (English/Bangla), alphabet learning, math games, drawing canvas, AI-powered stories, and speech practice.

## Key Technologies
- **Framework**: Flutter 3.x (web build)
- **State Management**: Riverpod
- **Navigation**: go_router
- **AI Integration**: Google Gemini API (for stories and handwriting recognition)
- **Storage**: Hive, SharedPreferences

## Running the App
The app is built and served as a static web application from `build/web/` directory.

To rebuild after changes:
```bash
flutter pub get
flutter build web --release
```

The workflow will automatically serve the built app on port 5000.

## Configuration

### API Keys (Optional)
For AI features (story generation and handwriting recognition), create `assets/env.json`:
```json
{
  "GEMINI_API_KEY": "your-gemini-api-key",
  "GEMINI_HANDWRITING_API_KEY": "your-gemini-handwriting-api-key"
}
```

The app works without these keys - AI features will simply be unavailable.

## Project Structure
```
lib/
├── main.dart                    # App entry point
├── app.dart                     # MaterialApp configuration
├── routing/router.dart          # Navigation routes
├── core/                        # Shared components
│   ├── theme/                   # Colors, typography
│   ├── widgets/                 # Reusable widgets
│   ├── i18n/                    # Localization
│   └── utils/                   # Utilities
├── features/                    # Feature modules
│   ├── home/                    # Home screen
│   ├── alphabet/                # English & Bangla alphabets
│   ├── math/                    # Math learning
│   ├── draw/                    # Drawing canvas
│   ├── story/                   # AI stories
│   ├── speak/                   # Speech practice
│   ├── games/                   # Educational games
│   ├── onboarding/              # Tutorial
│   └── tabs/                    # Tab navigation
└── services/                    # Backend services
    ├── gemini_service.dart      # AI story generation
    └── speech_service.dart      # Text-to-speech
```

## Features
- English and Bangla alphabet learning with pronunciation
- Math operations with adjustable difficulty
- Free-hand drawing with AI handwriting recognition
- AI-powered story generation with moral lessons
- Animated speaking cat character that appears during story narration
- Speech recognition for pronunciation practice
- Child-friendly UI with animations
- Educational games section with:
  - Memory Match: Find matching pairs of cards
  - Counting Game: Learn to count objects
  - Shape Match: Identify shapes by their silhouettes
  - Color Quiz: Learn to identify colors
  - Pattern Puzzle: Find the next item in a sequence pattern
