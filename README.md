# KidLearn Flutter App

A beautiful, interactive kids learning app built with Flutter. Features bilingual support (English/Bangla), alphabet learning, math games, drawing canvas, AI-powered stories, and speech practice.

## Features

### **System Features Overview**

- AI-enhanced mobile application for early childhood learning
- Supports interactive, bilingual, and personalized education

### **Alphabet Learning Module**

- English alphabets (A–Z) with pronunciation
- Bangla alphabets: স্বরবর্ণ and ব্যঞ্জনবর্ণ
- Example words for each letter
- Text-to-Speech based pronunciation support

### **Mathematics Learning Module**

- English and Bangla number systems
- Multiplication tables
- Basic arithmetic: addition, subtraction, multiplication, division
- Adjustable difficulty levels

### **Handwriting & Drawing Module**

- Free-hand drawing and guided tracing
- Adjustable stroke width and color options
- AI-based handwriting recognition using Google Gemini Vision
- Undo and clear functionality

### **AI Story Generation Module**

- Word-based personalized story generation
- Powered by Google Gemini AI
- Stories include moral lessons and comprehension questions
- Text-to-Speech narration in English and Bangla
- Speech & Pronunciation Module
- Speech recognition for pronunciation practice
- Vocabulary categories (animals, food, colors, numbers, family)
- Real-time pronunciation feedback
- Reference pronunciation using Text-to-Speech

### **Bilingual Support**

- Full support for English and Bangla
- Easy language switching from home screen
- Persistent language preference storage
  
### **Additional System Features**

- Child-friendly UI with animations and transitions
- Haptic feedback and onboarding tutorial
- Offline support for core learning features
  
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

  ### 📱 Android

#### Using Emulator

```bash
# List available emulators
flutter emulators
```

```bash
# Launch an emulator
flutter emulators --launch <emulator_id>
```

```bash
# Run the app
flutter run
```

### Build for Production

**Android APK:**

```bash
flutter build apk --release
```

**iOS:**

```bash
flutter build ios --release
```

**Web:**

```bash
flutter build web
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


## Future Work

- **Content Expansion:** Multi-language support, phonics-based learning, and advanced Bangla literacy (যুক্তবর্ণ).

- **Gamification:** Rewards, streaks, leaderboards, and interactive learning games.

- **AI Enhancements:** Personalized learning paths, adaptive difficulty, handwriting recognition, and pronunciation feedback.

- **Parental Controls:** Progress monitoring, screen time management, and multi-child profiles.

- **UI/UX & Media:** Dark mode, animated guides, accessibility improvements, audio/video learning support.

- **Platform & Backend:** Offline mode, cloud sync, Firebase integration, analytics, and cross-device support.

## License

This project is open source.

## Credits

- Jahidul Islam Sajib and Abu Bakar Siddiq — Application design and development

- Abu Bakar Siddiq and Jahidul Islam Sajib — AI model research and integration

- Abu Bakar Siddiq — UI/UX design support

- Syed Muhaiminul Haque — Testing and feedback
  
- Tusher Islam and Muhammad Ashraful - Paper Writing 
