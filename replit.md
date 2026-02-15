# KidLearn Flutter App

## Overview

KidLearn is an AI-enhanced mobile learning application for early childhood education, built with Flutter. It provides interactive, bilingual (English/Bangla) learning experiences across multiple modules: alphabet learning, mathematics, handwriting/drawing with AI recognition, AI-powered story generation, and speech/pronunciation practice. The app targets mobile (Android), web, and Windows platforms, with the web build being the primary deployment target on Replit.

## User Preferences

Preferred communication style: Simple, everyday language.

## System Architecture

### Framework & Language
- **Flutter/Dart** cross-platform framework targeting web, Android, and Windows
- The web build is the primary target for Replit — built output lives in `build/web/`
- To run: use `flutter build web` then serve the `build/web` directory, or use `flutter run -d chrome` for development

### State Management
- **flutter_riverpod** — the app uses Riverpod for state management, which means providers are used throughout for dependency injection and reactive state

### Routing
- **go_router** — declarative routing library for navigation between learning modules

### Local Storage
- **Hive + hive_flutter** — lightweight NoSQL database for local data persistence (user preferences, progress)
- **shared_preferences** — used for simple key-value storage like language preference
- **path_provider** — provides file system paths for Hive storage

### Data Architecture
- Static learning content (alphabets, word banks, spelling words) is stored as JSON files in `assets/data/`
  - `english_alphabets.json` — English A-Z with pronunciation and example words
  - `bangla_alphabets.json` — Bangla vowels (swarabarna) and consonants (byanjanbarna) with examples
  - `word_bank.json` — categorized vocabulary (animals, objects, actions, places, feelings)
  - `spelling_words.json` — difficulty-tiered spelling words with bilingual hints
- These JSON files are loaded as Flutter assets at runtime

### AI Integration
- **Google Gemini AI** (`google_generative_ai` package) — used for two features:
  1. **Story generation** — generates personalized stories with moral lessons from user-selected words
  2. **Handwriting recognition** — uses Gemini Vision API to recognize handwritten characters from the drawing canvas
- API keys are stored in `assets/env.json` and loaded at runtime

### Speech & Audio
- **flutter_tts** — Text-to-Speech for pronunciation of letters, words, and story narration in both English and Bangla
- **speech_to_text** — Speech recognition for pronunciation practice, providing real-time feedback

### UI & Styling
- **google_fonts** — custom typography
- **flutter_svg** — SVG asset rendering
- **cupertino_icons** — icon set
- Material Design as the base design system

### Bilingual Support
- Full English/Bangla language support throughout the app
- Language preference persisted locally
- All content data structures include both `En` and `Bn` variants (e.g., `wordEn`/`wordBn`, `nameEn`/`nameBn`)

### Build & Development
- **build_runner** — code generation (likely for Hive type adapters via `hive_generator`)
- **flutter_launcher_icons** — app icon generation
- **flutter_lints** — code quality enforcement
- Web build output is in `build/web/` — this is a compiled Flutter web app served as static files

### Project Structure
```
assets/
  data/           # JSON content files (alphabets, words, spelling)
  env.json        # API keys configuration
lib/              # Dart source code (main app logic, screens, providers)
web/              # Web platform template (index.html, manifest.json)
windows/          # Windows platform configuration
build/web/        # Compiled web output (static files to serve)
```

## External Dependencies

### AI Services
- **Google Gemini API** — Two separate API keys used:
  - `GEMINI_API_KEY` — for story generation
  - `GEMINI_HANDWRITING_API_KEY` — for handwriting/drawing recognition via Vision API
- Keys are configured in `assets/env.json`

### Platform APIs (via Flutter plugins)
- **Text-to-Speech** — platform-native TTS engines (web Speech Synthesis API on web)
- **Speech-to-Text** — platform-native speech recognition (Web Speech API on web)
- **Connectivity Plus** — network connectivity checking

### No Backend/Database Server
- This is a fully client-side application with no backend server or external database
- All data persistence is local (Hive, SharedPreferences)
- The only network calls are to Google Gemini AI APIs

### Running on Replit
- Build with `flutter build web`
- Serve the `build/web/` directory on port 5000 (or use a simple HTTP server)
- The app requires internet access for AI features (Gemini API calls)
- Speech features may have limited functionality in web browsers depending on browser support