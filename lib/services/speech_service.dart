import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  Completer<void>? _speakCompleter;

  bool get isSpeaking => _isSpeaking;

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
    await _tts.setPitch(1.1);
    await _tts.speak(text);
  }

  Future<void> speakBangla(String text) async {
    await initialize();
    await _tts.setLanguage('bn-BD');
    await _tts.setSpeechRate(0.35);
    await _tts.setPitch(1.0);
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
    
    final random = encouragements[DateTime.now().millisecond % encouragements.length];
    
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
}
