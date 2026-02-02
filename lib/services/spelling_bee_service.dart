import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import '../features/games/models/spelling_models.dart';

void _log(String message) {
  if (kDebugMode) {
    print('[SpellingBeeService] $message');
  }
}

class SpellingBeeService {
  static String _geminiApiKey = '';
  static String _openAiApiKey = '';
  static bool _initialized = false;

  GenerativeModel? _geminiModel;
  final Random _random = Random();

  // Track used words to avoid repetition in a session
  final Set<String> _usedWords = {};

  /// Initialize the service by loading API keys from env.json
  static Future<void> init() async {
    if (_initialized) return;

    try {
      final jsonString = await rootBundle.loadString('assets/env.json');
      final config = jsonDecode(jsonString) as Map<String, dynamic>;
      _geminiApiKey = config['GEMINI_API_KEY'] ?? '';
      _openAiApiKey = config['OPENAI_API_KEY'] ?? '';
      _initialized = true;
      _log('Initialized - Gemini: ${_geminiApiKey.isNotEmpty}, OpenAI: ${_openAiApiKey.isNotEmpty}');
    } catch (e) {
      _geminiApiKey = '';
      _openAiApiKey = '';
      _initialized = true;
      _log('Failed to load API keys: $e');
    }
  }

  SpellingBeeService() {
    if (_geminiApiKey.isNotEmpty) {
      _geminiModel = GenerativeModel(
        model: 'gemini-2.5-flash-lite',
        apiKey: _geminiApiKey,
      );
    }
  }

  bool get isGeminiConfigured => _geminiApiKey.isNotEmpty && _geminiModel != null;
  bool get isOpenAiConfigured => _openAiApiKey.isNotEmpty;
  bool get hasAnyAiConfigured => isGeminiConfigured || isOpenAiConfigured;

  /// Reset used words for a new game session
  void resetSession() {
    _usedWords.clear();
  }

  /// Get a random word for the given difficulty level
  SpellingWord getRandomWord(SpellingDifficulty difficulty, {bool isBangla = false}) {
    final words = SpellingWordBank.getWordsByDifficulty(difficulty);
    
    // Filter out already used words
    final availableWords = words.where((w) => !_usedWords.contains(w.wordEn)).toList();
    
    // If all words used, reset and use all
    final wordPool = availableWords.isEmpty ? words : availableWords;
    
    final word = wordPool[_random.nextInt(wordPool.length)];
    _usedWords.add(word.wordEn);
    
    return word;
  }

  /// Check if the user's spelling is correct
  SpellingEvaluation checkSpelling(String userInput, SpellingWord targetWord, {bool isBangla = false}) {
    final target = isBangla ? targetWord.wordBn : targetWord.wordEn;
    final input = userInput.trim().toLowerCase();
    final targetLower = target.toLowerCase();

    final isCorrect = input == targetLower;
    final similarity = _calculateSimilarity(input, targetLower);

    String feedback;
    if (isCorrect) {
      feedback = isBangla 
          ? 'অসাধারণ! তুমি সঠিক বানান করেছ!' 
          : 'Amazing! You spelled it correctly!';
    } else if (similarity >= 0.8) {
      feedback = isBangla 
          ? 'প্রায় হয়ে গেছে! আরেকটু চেষ্টা করো!' 
          : 'So close! Try one more time!';
    } else if (similarity >= 0.5) {
      feedback = isBangla 
          ? 'ভালো চেষ্টা! আবার চেষ্টা করো!' 
          : 'Good try! Keep practicing!';
    } else {
      feedback = isBangla 
          ? 'চেষ্টা চালিয়ে যাও! তুমি পারবে!' 
          : 'Keep trying! You can do it!';
    }

    return SpellingEvaluation(
      isCorrect: isCorrect,
      feedback: feedback,
      correction: isCorrect ? null : target,
      similarity: similarity,
    );
  }

  /// Generate a hint using AI (Gemini with OpenAI fallback)
  Future<SpellingHint> generateHint(SpellingWord word, {bool isBangla = false, int hintLevel = 1}) async {
    // Try Gemini first
    if (isGeminiConfigured) {
      try {
        final hint = await _generateHintWithGemini(word, isBangla: isBangla, hintLevel: hintLevel);
        if (hint != null) return hint;
      } catch (e) {
        _log('Gemini hint generation failed: $e');
      }
    }

    // Try OpenAI as fallback
    if (isOpenAiConfigured) {
      try {
        final hint = await _generateHintWithOpenAi(word, isBangla: isBangla, hintLevel: hintLevel);
        if (hint != null) return hint;
      } catch (e) {
        _log('OpenAI hint generation failed: $e');
      }
    }

    // Return fallback hint
    return _getFallbackHint(word, isBangla: isBangla, hintLevel: hintLevel);
  }

  Future<SpellingHint?> _generateHintWithGemini(SpellingWord word, {bool isBangla = false, int hintLevel = 1}) async {
    final targetWord = isBangla ? word.wordBn : word.wordEn;
    final language = isBangla ? 'Bengali/Bangla' : 'English';
    final languageInstruction = isBangla 
        ? 'IMPORTANT: Write ALL text in Bengali/Bangla script. Do NOT use English.'
        : 'Write all text in simple English.';
    
    final prompt = '''You are helping a child (age 4-10) learn to spell the word "$targetWord" in $language.

$languageInstruction

Generate a helpful hint based on hint level $hintLevel:
- Level 1: Give a general clue about what the word means (without saying the word)
- Level 2: Tell them the first letter and how many letters total
- Level 3: Spell out the first half of the word

Respond ONLY with valid JSON:
{
  "hint": "the helpful hint text IN $language",
  "phonetic": "how to pronounce/sound out the word",
  "example": "use the word in a simple sentence IN $language"
}

Keep language simple and kid-friendly. Be encouraging! Remember: ALL text must be in $language.''';

    final response = await _geminiModel!.generateContent([Content.text(prompt)]);
    
    if (response.text != null && response.text!.isNotEmpty) {
      try {
        String jsonString = response.text!;
        if (jsonString.contains('```json')) {
          jsonString = jsonString.split('```json')[1].split('```')[0];
        } else if (jsonString.contains('```')) {
          jsonString = jsonString.split('```')[1].split('```')[0];
        }
        final json = jsonDecode(jsonString.trim());
        return SpellingHint.fromJson(json);
      } catch (e) {
        _log('Gemini JSON parse error: $e');
      }
    }
    return null;
  }

  Future<SpellingHint?> _generateHintWithOpenAi(SpellingWord word, {bool isBangla = false, int hintLevel = 1}) async {
    final targetWord = isBangla ? word.wordBn : word.wordEn;
    final language = isBangla ? 'Bengali/Bangla' : 'English';
    final systemPrompt = isBangla 
        ? 'You are a friendly teacher helping Bengali children learn to spell. Write ALL responses in Bengali/Bangla script only. Never use English. Always respond with valid JSON only.'
        : 'You are a friendly teacher helping children learn to spell. Always respond with valid JSON only in English.';

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_openAiApiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': systemPrompt
          },
          {
            'role': 'user',
            'content': '''Generate a spelling hint for the word "$targetWord".
Hint level: $hintLevel (1=meaning clue, 2=first letter + length, 3=first half spelled)
IMPORTANT: Write ALL text in $language only.

Respond ONLY with JSON:
{"hint": "hint text in $language", "phonetic": "pronunciation", "example": "sentence in $language"}'''
          }
        ],
        'temperature': 0.7,
        'max_tokens': 200,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      try {
        String jsonString = content;
        if (jsonString.contains('```json')) {
          jsonString = jsonString.split('```json')[1].split('```')[0];
        } else if (jsonString.contains('```')) {
          jsonString = jsonString.split('```')[1].split('```')[0];
        }
        final json = jsonDecode(jsonString.trim());
        return SpellingHint.fromJson(json);
      } catch (e) {
        _log('OpenAI JSON parse error: $e');
      }
    }
    return null;
  }

  SpellingHint _getFallbackHint(SpellingWord word, {bool isBangla = false, int hintLevel = 1}) {
    final targetWord = isBangla ? word.wordBn : word.wordEn;
    final storedHint = isBangla ? word.hintBn : word.hintEn;
    
    String hint;
    switch (hintLevel) {
      case 1:
        hint = storedHint ?? (isBangla ? 'এটি একটি ${word.category} সম্পর্কিত শব্দ' : 'This word is about ${word.category}');
        break;
      case 2:
        final firstLetter = targetWord.isNotEmpty ? targetWord[0].toUpperCase() : '?';
        hint = isBangla 
            ? 'প্রথম অক্ষর "$firstLetter" এবং ${targetWord.length}টি অক্ষর আছে'
            : 'Starts with "$firstLetter" and has ${targetWord.length} letters';
        break;
      case 3:
        final halfLength = (targetWord.length / 2).ceil();
        final firstHalf = targetWord.substring(0, halfLength);
        hint = isBangla 
            ? 'শুরু হয়: $firstHalf...'
            : 'It starts: $firstHalf...';
        break;
      default:
        hint = storedHint ?? (isBangla ? 'চেষ্টা করো!' : 'Give it a try!');
    }

    return SpellingHint(
      hint: hint,
      phonetic: targetWord,
      example: isBangla 
          ? 'এই শব্দটি বানান করো: $targetWord'
          : 'Spell this word: $targetWord',
    );
  }

  /// Get encouraging feedback using AI
  Future<String> getEncouragingFeedback(bool isCorrect, int streak, {bool isBangla = false}) async {
    // Quick local responses for better UX
    if (isCorrect) {
      final positiveResponses = isBangla
          ? ['অসাধারণ! 🌟', 'দারুণ হয়েছে! 🎉', 'তুমি সেরা! ⭐', 'চমৎকার! 👏', 'বাহ! খুব ভালো! 🏆']
          : ['Amazing! 🌟', 'Great job! 🎉', 'You\'re a star! ⭐', 'Wonderful! 👏', 'Fantastic! 🏆'];
      
      if (streak >= 3) {
        return isBangla 
            ? '🔥 $streak টা সঠিক! তুমি আগুন!' 
            : '🔥 $streak in a row! You\'re on fire!';
      }
      return positiveResponses[_random.nextInt(positiveResponses.length)];
    } else {
      final encouragements = isBangla
          ? ['চেষ্টা চালিয়ে যাও! 💪', 'আবার চেষ্টা করো! 🌈', 'তুমি পারবে! ✨', 'হাল ছেড়ো না! 🌻']
          : ['Keep trying! 💪', 'Try again! 🌈', 'You can do it! ✨', 'Don\'t give up! 🌻'];
      return encouragements[_random.nextInt(encouragements.length)];
    }
  }

  /// Calculate similarity between two strings (0.0 to 1.0)
  double _calculateSimilarity(String s1, String s2) {
    if (s1.isEmpty || s2.isEmpty) return 0.0;
    if (s1 == s2) return 1.0;

    final longer = s1.length > s2.length ? s1 : s2;
    final shorter = s1.length > s2.length ? s2 : s1;

    final longerLength = longer.length;
    if (longerLength == 0) return 1.0;

    return (longerLength - _editDistance(longer, shorter)) / longerLength;
  }

  /// Calculate Levenshtein edit distance
  int _editDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;

    final dp = List.generate(len1 + 1, (i) => List.filled(len2 + 1, 0));

    for (var i = 0; i <= len1; i++) {
      dp[i][0] = i;
    }
    for (var j = 0; j <= len2; j++) {
      dp[0][j] = j;
    }

    for (var i = 1; i <= len1; i++) {
      for (var j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1,
          dp[i][j - 1] + 1,
          dp[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return dp[len1][len2];
  }

  /// Speak the word letter by letter (for voice spelling practice)
  String spellOutWord(String word) {
    return word.split('').join(' - ');
  }

  /// Get pronunciation guide for a word
  String getPronunciationGuide(SpellingWord word, {bool isBangla = false}) {
    final targetWord = isBangla ? word.wordBn : word.wordEn;
    // Simple phonetic breakdown
    return targetWord.split('').map((c) => c.toUpperCase()).join('-');
  }
}
