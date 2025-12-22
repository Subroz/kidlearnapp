import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  english,
  bangla,
}

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(AppLanguage.english) {
    _loadLanguage();
  }

  static const String _languageKey = 'app_language';

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageString = prefs.getString(_languageKey);
    if (languageString == 'bangla') {
      state = AppLanguage.bangla;
    } else {
      state = AppLanguage.english;
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _languageKey,
      language == AppLanguage.bangla ? 'bangla' : 'english',
    );
  }

  void toggleLanguage() {
    if (state == AppLanguage.english) {
      setLanguage(AppLanguage.bangla);
    } else {
      setLanguage(AppLanguage.english);
    }
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>(
  (ref) => LanguageNotifier(),
);

// Localization strings
class AppStrings {
  static String get(String key, AppLanguage language) {
    final strings = language == AppLanguage.bangla ? _banglaStrings : _englishStrings;
    return strings[key] ?? key;
  }

  static const Map<String, String> _englishStrings = {
    // Navigation
    'nav.home': 'Home',
    'nav.learn': 'Learn',
    'nav.math': 'Math',
    'nav.draw': 'Draw',
    'nav.story': 'Stories',
    'nav.speak': 'Speak',
    
    // Home
    'home.welcome': 'Welcome to KidLearn!',
    'home.subtitle': 'Let\'s learn something new today',
    'home.alphabet': 'Alphabet',
    'home.math': 'Math',
    'home.draw': 'Draw',
    'home.story': 'Stories',
    'home.speak': 'Speak',
    'home.games': 'Games',
    
    // Alphabet
    'alphabet.english': 'English Alphabet',
    'alphabet.bangla': 'Bangla Alphabet',
    'alphabet.vowels': 'Vowels',
    'alphabet.consonants': 'Consonants',
    'alphabet.all': 'All',
    'alphabet.listen': 'Listen',
    'alphabet.examples': 'Example Words',
    
    // Math
    'math.title': 'Math Fun',
    'math.numbers': 'Numbers',
    'math.addition': 'Addition',
    'math.subtraction': 'Subtraction',
    'math.multiplication': 'Multiplication',
    'math.division': 'Division',
    'math.tables': 'Times Tables',
    'math.correct': 'Correct!',
    'math.tryAgain': 'Try Again!',
    'math.score': 'Score',
    'math.next': 'Next',
    
    // Draw
    'draw.title': 'Drawing Board',
    'draw.clear': 'Clear',
    'draw.undo': 'Undo',
    'draw.colors': 'Colors',
    'draw.brushSize': 'Brush Size',
    'draw.guide': 'Show Guide',
    
    // Story
    'story.title': 'Story Time',
    'story.selectWords': 'Select words to create a story',
    'story.generate': 'Generate Story',
    'story.generating': 'Creating your story...',
    'story.animals': 'Animals',
    'story.objects': 'Objects',
    'story.actions': 'Actions',
    'story.places': 'Places',
    'story.feelings': 'Feelings',
    'story.moral': 'Moral of the Story',
    'story.vocabulary': 'New Words',
    'story.questions': 'Think About It',
    'story.readAloud': 'Read Aloud',
    'story.favorite': 'Favorite',
    
    // Speak
    'speak.title': 'Let\'s Speak',
    'speak.listen': 'Listen',
    'speak.record': 'Record',
    'speak.tryAgain': 'Try Again',
    'speak.great': 'Great Job!',
    
    // Common
    'common.continue': 'Continue',
    'common.back': 'Back',
    'common.next': 'Next',
    'common.done': 'Done',
    'common.skip': 'Skip',
    'common.loading': 'Loading...',
    'common.error': 'Oops! Something went wrong',
    'common.retry': 'Try Again',
  };

  static const Map<String, String> _banglaStrings = {
    // Navigation
    'nav.home': 'হোম',
    'nav.learn': 'শিখি',
    'nav.math': 'গণিত',
    'nav.draw': 'আঁকা',
    'nav.story': 'গল্প',
    'nav.speak': 'বলা',
    
    // Home
    'home.welcome': 'কিডলার্নে স্বাগতম!',
    'home.subtitle': 'চলো আজ নতুন কিছু শিখি',
    'home.alphabet': 'বর্ণমালা',
    'home.math': 'গণিত',
    'home.draw': 'আঁকা',
    'home.story': 'গল্প',
    'home.speak': 'বলা',
    'home.games': 'খেলা',
    
    // Alphabet
    'alphabet.english': 'ইংরেজি বর্ণমালা',
    'alphabet.bangla': 'বাংলা বর্ণমালা',
    'alphabet.vowels': 'স্বরবর্ণ',
    'alphabet.consonants': 'ব্যঞ্জনবর্ণ',
    'alphabet.all': 'সব',
    'alphabet.listen': 'শুনুন',
    'alphabet.examples': 'উদাহরণ শব্দ',
    
    // Math
    'math.title': 'গণিত মজা',
    'math.numbers': 'সংখ্যা',
    'math.addition': 'যোগ',
    'math.subtraction': 'বিয়োগ',
    'math.multiplication': 'গুণ',
    'math.division': 'ভাগ',
    'math.tables': 'নামতা',
    'math.correct': 'সঠিক!',
    'math.tryAgain': 'আবার চেষ্টা করো!',
    'math.score': 'স্কোর',
    'math.next': 'পরবর্তী',
    
    // Draw
    'draw.title': 'আঁকার বোর্ড',
    'draw.clear': 'মুছুন',
    'draw.undo': 'বাতিল',
    'draw.colors': 'রং',
    'draw.brushSize': 'ব্রাশের আকার',
    'draw.guide': 'গাইড দেখান',
    
    // Story
    'story.title': 'গল্পের সময়',
    'story.selectWords': 'গল্প তৈরি করতে শব্দ বেছে নাও',
    'story.generate': 'গল্প তৈরি করো',
    'story.generating': 'তোমার গল্প তৈরি হচ্ছে...',
    'story.animals': 'পশুপাখি',
    'story.objects': 'জিনিসপত্র',
    'story.actions': 'কাজ',
    'story.places': 'জায়গা',
    'story.feelings': 'অনুভূতি',
    'story.moral': 'গল্পের শিক্ষা',
    'story.vocabulary': 'নতুন শব্দ',
    'story.questions': 'ভেবে দেখো',
    'story.readAloud': 'পড়ে শোনাও',
    'story.favorite': 'প্রিয়',
    
    // Speak
    'speak.title': 'চলো বলি',
    'speak.listen': 'শুনুন',
    'speak.record': 'রেকর্ড',
    'speak.tryAgain': 'আবার চেষ্টা করো',
    'speak.great': 'অসাধারণ!',
    
    // Common
    'common.continue': 'এগিয়ে যাও',
    'common.back': 'পিছনে',
    'common.next': 'পরবর্তী',
    'common.done': 'সম্পন্ন',
    'common.skip': 'এড়িয়ে যাও',
    'common.loading': 'লোড হচ্ছে...',
    'common.error': 'উফ! কিছু ভুল হয়েছে',
    'common.retry': 'আবার চেষ্টা করো',
  };
}
