# KidLearn Flutter App

A beautiful, interactive kids learning app built with Flutter. Features bilingual support (English/Bangla), alphabet learning, math games, drawing canvas, AI-powered stories, and speech practice.

## Features

- **Alphabet Learning** - Learn English and Bangla alphabets with swipeable cards
- **Math Games** - Number(bangla and English), Multiplication table,Addition, subtraction, multiplication, and division with visual feedback
- **Drawing Canvas** - Creative drawing board with color picker and guide characters. Used AI to trace and recognize character(Gemini API).
future work()
- **Story Generator** - AI-powered story creation using selected words (Gemini API)
- **Speech Practice** - Learn pronunciation with text-to-speech
- **Bilingual** - Full English and Bangla language support
- **Beautiful UI** - Kid-friendly, colorful design with animations
- 
## Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code with Flutter extensions
- (Optional) Gemini API key for AI story generation

### Installation

1. **Clone or copy the project**

   ```bash
   cd kidlearn_flutter
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the app**

   Without API keys (story generation will use fallback stories):

   ```bash
   flutter run
   ```

   With Gemini API key (for AI story generation):

   ```bash
   flutter run --dart-define=GEMINI_API_KEY=your_api_key_here
   ```

### Build for Production

**Android APK:**

```bash
flutter build apk --dart-define=GEMINI_API_KEY=your_api_key
```

**iOS:**

```bash
flutter build ios --dart-define=GEMINI_API_KEY=your_api_key
```

**Web:**

```bash
flutter build web --dart-define=GEMINI_API_KEY=your_api_key
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # MaterialApp configuration
├── routing/
│   └── router.dart              # Navigation routes (go_router)
├── core/
│   ├── theme/
│   │   ├── app_theme.dart       # Colors, typography, styling
│   │   └── section_themes.dart  # Module-specific themes
│   ├── widgets/
│   │   ├── screen_background.dart
│   │   ├── kid_button.dart
│   │   ├── kid_card.dart
│   │   └── header.dart
│   ├── i18n/
│   │   └── language_controller.dart  # Localization
│   └── utils/
│       ├── bangla_digits.dart
│       └── haptics.dart
├── features/
│   ├── home/
│   ├── alphabet/
│   ├── math/
│   ├── draw/
│   ├── story/
│   ├── speak/
│   ├── onboarding/
│   └── tabs/
└── services/
    ├── gemini_service.dart      # AI story generation
    └── speech_service.dart      # Text-to-speech
```

## Key Technologies

- **Flutter** - Cross-platform UI framework
- **Riverpod** - State management
- **go_router** - Navigation
- **flutter_tts** - Text-to-speech
- **google_generative_ai** - Gemini API for stories
- **shared_preferences** - Local storage
- **hive** - Fast local database

## Customization

### Colors

Edit `lib/core/theme/app_theme.dart` to customize colors:

```dart
static const Color primaryPurple = Color(0xFF7C3AED);
static const Color primaryBlue = Color(0xFF3B82F6);
// ... more colors
```

### Adding New Languages

1. Add translation strings in `lib/core/i18n/language_controller.dart`
2. Update the `AppLanguage` enum
3. Add language toggle logic

### Adding Alphabets

Edit `lib/features/alphabet/models/letter_models.dart` to add new letters or languages.

## License

This project is open source.

## Credits

### Need for paper writing.

- Design inspired by Duolingo, Khan Academy Kids, and ABCmouse
- Built with Flutter and love for kids' education
