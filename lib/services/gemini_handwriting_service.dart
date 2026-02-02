import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class HandwritingResult {
  final String character;
  final String feedback;
  final double confidence;
  final bool isMatch;
  final String? expectedCharacter;

  HandwritingResult({
    required this.character,
    required this.feedback,
    required this.confidence,
    required this.isMatch,
    this.expectedCharacter,
  });

  factory HandwritingResult.fromJson(Map<String, dynamic> json, {String? guideCharacter}) {
    final character = json['character'] ?? '?';
    final isMatch = json['is_match'] ?? false;
    
    return HandwritingResult(
      character: character,
      feedback: json['feedback'] ?? 'Keep practicing!',
      confidence: (json['confidence'] ?? 0.5).toDouble(),
      isMatch: isMatch,
      expectedCharacter: guideCharacter,
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
      return _getFallbackResult(guideCharacter);
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
        return _getFallbackResult(guideCharacter);
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
        return HandwritingResult.fromJson(json, guideCharacter: guideCharacter);
      } catch (e) {
        debugPrint('GeminiHandwritingService: JSON parse error: $e');
        // Try to extract character from plain text response
        return _parseTextResponse(response.text!, guideCharacter);
      }
    } catch (e) {
      debugPrint('GeminiHandwritingService: Error: $e');
      return _getFallbackResult(guideCharacter);
    }
  }

  String _buildPrompt(String? guideCharacter, bool isBangla) {
    final language = isBangla ? 'Bangla/Bengali' : 'English';
    
    if (guideCharacter != null) {
      return '''You are a handwriting recognition expert helping a child learn to write letters. The child is trying to draw the character "$guideCharacter".

IMPORTANT: Carefully analyze the handwritten drawing in the image and determine:
1. What character did the child actually draw?
2. Does it match the target character "$guideCharacter"?
3. How accurate/confident is the match (0.0 to 1.0)?

Respond ONLY with valid JSON in this exact format:
{
  "character": "the single character you recognized from the drawing",
  "is_match": true or false,
  "feedback": "encouraging feedback for the child",
  "confidence": 0.85
}

CRITICAL GUIDELINES:
- "is_match" should be TRUE only if the drawn character clearly matches "$guideCharacter"
- "is_match" should be FALSE if the child drew a different character, even if well-written
- Be strict but fair in matching - the letter shape must be recognizable as "$guideCharacter"
- For numbers and letters, compare the actual shape, not just any mark
- If the drawing is unclear or unrecognizable, set is_match to false and character to "?"

FEEDBACK GUIDELINES:
- If is_match is TRUE: Praise them enthusiastically! ("Great job!", "Perfect!", "You did it!")
- If is_match is FALSE: Be encouraging but clear ("Good try! That looks like [X]. Let's try $guideCharacter again!")
- Keep feedback simple and kid-friendly (ages 4-10)
- Use positive language even for mistakes

The character should be a single $language character or number.''';
    } else {
      return '''Analyze this handwritten character drawing.

Recognize the character and provide encouraging feedback for a child learning to write.

Respond ONLY with valid JSON in this exact format:
{
  "character": "the single character you recognized",
  "is_match": true,
  "feedback": "encouraging, kid-friendly feedback",
  "confidence": 0.85
}

The character should be a single $language character or number (0-9, A-Z, a-z${isBangla ? ', or Bengali/Bangla character' : ''}).
Be very encouraging and positive in your feedback!
If the drawing is unclear, set character to "?" and confidence to a low value.''';
    }
  }

  HandwritingResult _parseTextResponse(String text, String? guideCharacter) {
    // Try to extract a character from the response
    String character = '?';
    String feedback = 'Good try! Keep practicing!';
    double confidence = 0.5;
    bool isMatch = false;

    // Simple heuristic: look for single characters in the response
    final singleChars = RegExp(r'\b[A-Za-z0-9অ-ৰ]\b').allMatches(text);
    if (singleChars.isNotEmpty) {
      character = singleChars.first.group(0) ?? '?';
      // Check if the extracted character matches the guide
      if (guideCharacter != null) {
        isMatch = character.toLowerCase() == guideCharacter.toLowerCase();
      }
    }

    return HandwritingResult(
      character: character,
      feedback: feedback,
      confidence: confidence,
      isMatch: isMatch,
      expectedCharacter: guideCharacter,
    );
  }

  HandwritingResult _getFallbackResult(String? guideCharacter) {
    return HandwritingResult(
      character: '?',
      feedback: 'Keep practicing! You\'re doing great!',
      confidence: 0.5,
      isMatch: false,
      expectedCharacter: guideCharacter,
    );
  }
}
