# KidLearn Flutter App

## Overview

KidLearn is a bilingual (English/Bangla) educational mobile application designed for early childhood learning. Built with Flutter, it provides interactive learning modules for alphabets, mathematics, handwriting/drawing, AI-powered story generation, and speech practice. The app leverages Google Gemini AI for story generation and handwriting recognition features.

## Recent Changes

### January 2026
- Enhanced UI with extensive kid-friendly animations throughout the app
- Added animated sparkle effects to progress card with pulsing animations
- Module cards now feature continuous bounce, wiggle, and pulse animations with staggered delays
- Navigation bar icons bounce when selected with glow effects
- Progress stats (points/days) have bouncing icons
- Progress circle animates on load from 0% to current value

## User Preferences

Preferred communication style: Simple, everyday language.
Preference: Child-friendly, engaging UI with extensive animations and playful design.

## System Architecture

### Frontend Architecture
- **Framework**: Flutter (Dart)
- **State Management**: Riverpod (flutter_riverpod)
- **Navigation**: go_router for declarative routing
- **UI Components**: Material Design with Google Fonts and Flutter SVG support
- **Platform Support**: Android, Web, and Windows builds configured

### Data Layer
- **Local Storage**: Hive and Hive Flutter for NoSQL local database storage
- **Preferences**: shared_preferences for simple key-value storage
- **File Storage**: path_provider for accessing device file system
- **Static Data**: JSON files in assets/data/ directory for alphabet and word bank content

### AI Integration
- **Story Generation**: Google Generative AI (Gemini) for creating personalized stories
- **Handwriting Recognition**: Google Gemini Vision API for analyzing drawings
- **API Keys**: Stored in assets/env.json configuration file

### Audio Features
- **Text-to-Speech**: flutter_tts for pronunciation and narration
- **Speech Recognition**: speech_to_text for pronunciation practice

### Network Layer
- **Connectivity**: connectivity_plus for monitoring network status

### Build Configuration
- Web builds output to build/web/ directory
- Uses CanvasKit renderer for web platform
- Service worker configured for PWA support

## External Dependencies

### Google Services
- **Google Generative AI (Gemini)**: Powers AI story generation and handwriting recognition via API keys stored in env.json

### Flutter Packages
- **flutter_riverpod**: State management
- **go_router**: Navigation and routing
- **flutter_tts**: Text-to-speech functionality
- **speech_to_text**: Speech recognition for pronunciation practice
- **hive/hive_flutter**: Local NoSQL database
- **shared_preferences**: Simple persistent storage
- **google_fonts**: Typography
- **flutter_svg**: SVG asset rendering
- **connectivity_plus**: Network connectivity monitoring
- **path_provider**: File system access
- **cupertino_icons**: iOS-style icons

### Development Dependencies
- **build_runner**: Code generation
- **hive_generator**: Hive type adapters
- **flutter_launcher_icons**: App icon generation
- **flutter_lints**: Code linting rules