import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class HandwritingResult {
  final String character;
  final String feedback;
  final double confidence;

  HandwritingResult({
    required this.character,
    required this.feedback,
    required this.confidence,
  });

  factory HandwritingResult.fromJson(Map<String, dynamic> json) {
    return HandwritingResult(
      character: json['character'] ?? '?',
      feedback: json['feedback'] ?? 'Keep practicing!',
      confidence: (json['confidence'] ?? 0.5).toDouble(),
    );
  }
}

class GeminiHandwritingService {
  static String _apiKey = '';
  static bool _initialized = false;

  GenerativeModel? _model;

  /// Initialize the service by loading the API key from env.json
  static Future<void> init() async {
    if (_initialized) return;

    try {
      final jsonString = await rootBundle.loadString('assets/env.json');
      final config = jsonDecode(jsonString) as Map<String, dynamic>;
      _apiKey = config['GEMINI_HANDWRITING_API_KEY'] ?? '';
      _initialized = true;
      debugPrint('GeminiHandwritingService: Initialized, API key loaded: ${_apiKey.isNotEmpty}');
    } catch (e) {
      _apiKey = '';
      _initialized = true;
      debugPrint('GeminiHandwritingService: Failed to load API key: $e');
    }
  }

  GeminiHandwritingService() {
    if (_apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
      );
    }
  }

  bool get isConfigured => _apiKey.isNotEmpty && _model != null;

  Future<HandwritingResult> recognizeDrawing(
    Uint8List imageBytes, {
    String? guideCharacter,
    bool isBangla = false,
  }) async {
    if (!isConfigured) {
      debugPrint('GeminiHandwritingService: Not configured');
      return _getFallbackResult();
    }

    try {
      debugPrint('GeminiHandwritingService: Recognizing drawing...');
      
      final prompt = _buildPrompt(guideCharacter, isBangla);
      final imagePart = DataPart('image/png', imageBytes);
      
      final content = [
        Content.multi([
          TextPart(prompt),
          imagePart,
        ])
      ];

      final response = await _model!.generateContent(content);
      
      if (response.text == null || response.text!.isEmpty) {
        debugPrint('GeminiHandwritingService: Empty response');
        return _getFallbackResult();
      }

      // Parse JSON response
      try {
        String jsonString = response.text!;
        
        // Clean up potential markdown code blocks
        if (jsonString.contains('```json')) {
          jsonString = jsonString.split('```json')[1].split('```')[0];
        } else if (jsonString.contains('```')) {
          jsonString = jsonString.split('```')[1].split('```')[0];
        }

        final json = jsonDecode(jsonString.trim());
        debugPrint('GeminiHandwritingService: Recognition successful!');
        return HandwritingResult.fromJson(json);
      } catch (e) {
        debugPrint('GeminiHandwritingService: JSON parse error: $e');
        // Try to extract character from plain text response
        return _parseTextResponse(response.text!, guideCharacter);
      }
    } catch (e) {
      debugPrint('GeminiHandwritingService: Error: $e');
      return _getFallbackResult();
    }
  }

  String _buildPrompt(String? guideCharacter, bool isBangla) {
    final language = isBangla ? 'Bangla' : 'English';
    
    if (guideCharacter != null) {
      return '''You are helping a child learn to write. The child is trying to draw the character "$guideCharacter".

Analyze the handwritten drawing and:
1. Recognize what character they actually drew
2. Provide encouraging, age-appropriate feedback (1-2 sentences)
3. Rate their confidence/accuracy (0.0 to 1.0)

Respond ONLY with valid JSON in this exact format:
{
  "character": "the character you recognized",
  "feedback": "encouraging feedback for the child",
  "confidence": 0.85
}

Guidelines:
- Be very encouraging and positive
- If they drew the target character, praise them!
- If they drew something else, gently encourage them to try again
- Use simple, kid-friendly language
- The character should be a single $language character or number''';
    } else {
      return '''Analyze this handwritten character drawing.

Recognize the character and provide encouraging feedback for a child learning to write.

Respond ONLY with valid JSON in this exact format:
{
  "character": "the character you recognized",
  "feedback": "encouraging, kid-friendly feedback",
  "confidence": 0.85
}

The character should be a single $language character or number (0-9, A-Z, a-z${isBangla ? ', or Bengali character' : ''}).
Be very encouraging and positive in your feedback!''';
    }
  }

  HandwritingResult _parseTextResponse(String text, String? guideCharacter) {
    // Try to extract a character from the response
    String character = '?';
    String feedback = 'Good try! Keep practicing!';
    double confidence = 0.5;

    // Simple heuristic: look for single characters in the response
    final singleChars = RegExp(r'\b[A-Za-z0-9অ-ৰ]\b').allMatches(text);
    if (singleChars.isNotEmpty) {
      character = singleChars.first.group(0) ?? '?';
    }

    return HandwritingResult(
      character: character,
      feedback: feedback,
      confidence: confidence,
    );
  }

  HandwritingResult _getFallbackResult() {
    return HandwritingResult(
      character: '?',
      feedback: 'Keep practicing! You\'re doing great!',
      confidence: 0.5,
    );
  }
}

