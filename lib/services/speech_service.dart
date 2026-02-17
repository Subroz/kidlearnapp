import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _isSpeechInitialized = false;
  bool _isListening = false;
  Completer<void>? _speakCompleter;

  bool get isSpeaking => _isSpeaking;
  bool get isListening => _isListening;
  bool get isSpeechAvailable => _isSpeechInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.4);
    await _tts.setPitch(1.1);

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      _speakCompleter?.complete();
      _speakCompleter = null;
    });

    _tts.setCancelHandler(() {
      _isSpeaking = false;
      _speakCompleter?.complete();
      _speakCompleter = null;
    });

    _tts.setErrorHandler((msg) {
      _isSpeaking = false;
      _speakCompleter?.complete();
      _speakCompleter = null;
    });

    _isInitialized = true;
  }

  Future<void> speakEnglish(String text) async {
    await initialize();
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.4);
    await _tts.setPitch(1.2);
    await _tts.setVolume(1.0);
    await _tts.speak(text);
  }

  Future<void> speakBangla(String text) async {
    await initialize();
    await _tts.setLanguage('bn-BD');
    await _tts.setSpeechRate(0.35);
    await _tts.setPitch(1.2);
    await _tts.setVolume(1.0);
    await _tts.speak(text);
  }

  Future<void> speakLetter(String letter, {bool isBangla = false}) async {
    if (isBangla) {
      await speakBangla(letter);
    } else {
      await speakEnglish(letter);
    }
  }

  Future<void> speakWord(String word, {bool isBangla = false}) async {
    if (isBangla) {
      await speakBangla(word);
    } else {
      await speakEnglish(word);
    }
  }

  Future<void> speakNumber(int number, {bool isBangla = false}) async {
    if (isBangla) {
      await speakBangla(_getNumberWordBangla(number));
    } else {
      await speakEnglish(number.toString());
    }
  }

  Future<void> speakStory(String story, {bool isBangla = false}) async {
    await initialize();
    if (isBangla) {
      await _tts.setLanguage('bn-BD');
      await _tts.setSpeechRate(0.3);
    } else {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.35);
    }
    await _tts.setPitch(1.0);

    _speakCompleter = Completer<void>();
    _isSpeaking = true;
    await _tts.speak(story);
    await _speakCompleter?.future;
  }

  Future<void> speakEncouragement({bool isBangla = false}) async {
    final encouragements = isBangla
        ? ['অসাধারণ!', 'খুব ভালো!', 'দারুণ করেছ!', 'চালিয়ে যাও!']
        : ['Great job!', 'Excellent!', 'You\'re amazing!', 'Keep it up!'];

    final random =
        encouragements[DateTime.now().millisecond % encouragements.length];

    if (isBangla) {
      await speakBangla(random);
    } else {
      await speakEnglish(random);
    }
  }

  Future<void> stop() async {
    _isSpeaking = false;
    await _tts.stop();
    _speakCompleter?.complete();
    _speakCompleter = null;
  }

  String _getNumberWordBangla(int number) {
    const words = {
      0: 'শূন্য',
      1: 'এক',
      2: 'দুই',
      3: 'তিন',
      4: 'চার',
      5: 'পাঁচ',
      6: 'ছয়',
      7: 'সাত',
      8: 'আট',
      9: 'নয়',
      10: 'দশ',
    };
    return words[number] ?? number.toString();
  }

  // Speech Recognition Methods
  String? _lastError;
  String? get lastError => _lastError;
  
  Future<bool> initializeSpeechRecognition() async {
    if (_isSpeechInitialized) return true;
    try {
      _isSpeechInitialized = await _speech.initialize(
        onError: (error) {
          _isListening = false;
          _lastError = error.errorMsg;
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
          }
        },
      );
    } catch (e) {
      _lastError = e.toString();
      _isSpeechInitialized = false;
    }
    return _isSpeechInitialized;
  }
  
  Future<bool> reinitializeSpeechRecognition() async {
    _isSpeechInitialized = false;
    _lastError = null;
    return await initializeSpeechRecognition();
  }

  Future<bool> startListening({
    required Function(String) onResult,
    required bool isBangla,
    Duration? listenFor,
    Duration? pauseFor,
    Function(String)? onError,
  }) async {
    _lastError = null;
    
    if (!_isSpeechInitialized) {
      final initialized = await initializeSpeechRecognition();
      if (!initialized) {
        onError?.call(_lastError ?? 'Failed to initialize speech recognition');
        return false;
      }
    }

    if (_isListening) {
      await stopListening();
    }

    try {
      _isListening = true;
      await _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
        localeId: isBangla ? 'bn_BD' : 'en_US',
        listenFor: listenFor ?? const Duration(seconds: 10),
        pauseFor: pauseFor ?? const Duration(seconds: 3),
        listenOptions: stt.SpeechListenOptions(
          cancelOnError: false,
          listenMode: stt.ListenMode.dictation,
        ),
      );
      return true;
    } catch (e) {
      _isListening = false;
      _lastError = e.toString();
      onError?.call(_lastError!);
      return false;
    }
  }

  Future<void> stopListening() async {
    _isListening = false;
    await _speech.stop();
  }

  bool checkWordMatch(String spoken, String target) {
    final spokenLower = spoken.toLowerCase().trim();
    final targetLower = target.toLowerCase().trim();
    
    // Exact match
    if (spokenLower == targetLower) return true;
    
    // Check if spoken contains target or target contains spoken
    if (spokenLower.contains(targetLower) || targetLower.contains(spokenLower)) {
      return true;
    }
    
    // Calculate similarity (simple Levenshtein-like check)
    final similarity = _calculateSimilarity(spokenLower, targetLower);
    return similarity >= 0.7; // 70% match threshold
  }

  double _calculateSimilarity(String s1, String s2) {
    if (s1.isEmpty || s2.isEmpty) return 0.0;
    if (s1 == s2) return 1.0;
    
    final longer = s1.length > s2.length ? s1 : s2;
    final shorter = s1.length > s2.length ? s2 : s1;
    
    int matches = 0;
    for (int i = 0; i < shorter.length; i++) {
      if (i < longer.length && shorter[i] == longer[i]) {
        matches++;
      }
    }
    
    return matches / longer.length;
  }
}
