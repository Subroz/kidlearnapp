import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

class HandwritingResult {
  final String character;
  final String feedback;
  final double confidence;
  final bool isMatch;
  final String? expectedCharacter;
  final int structureScore;
  final int readabilityScore;
  final int neatnessScore;

  HandwritingResult({
    required this.character,
    required this.feedback,
    required this.confidence,
    required this.isMatch,
    this.expectedCharacter,
    this.structureScore = 0,
    this.readabilityScore = 0,
    this.neatnessScore = 0,
  });

  factory HandwritingResult.fromJson(Map<String, dynamic> json, {String? guideCharacter}) {
    final character = json['character'] ?? '?';
    final neatness = (json['neatness_score'] ?? 5).toInt().clamp(1, 10);
    
    // Confidence from neatness score
    final confidence = (neatness / 10.0).clamp(0.0, 1.0);
    
    // CLIENT-SIDE decision: match ONLY if the AI recognized the same character as the guide
    // The AI does NOT know the target - this is a blind recognition
    final bool isMatch;
    if (guideCharacter == null || character == '?') {
      isMatch = false;
    } else {
      isMatch = character == guideCharacter;
    }
    
    debugPrint('HandwritingResult: recognized="$character", expected="$guideCharacter", neatness=$neatness, isMatch=$isMatch');
    
    return HandwritingResult(
      character: character,
      feedback: json['feedback'] ?? 'Keep practicing!',
      confidence: confidence,
      isMatch: isMatch,
      expectedCharacter: guideCharacter,
      neatnessScore: neatness,
    );
  }
}

class GeminiHandwritingService {
  static String _geminiApiKey = '';
  static String _openAiApiKey = '';
  static bool _initialized = false;

  GenerativeModel? _model;

  /// Initialize the service by loading API keys from env.json
  static Future<void> init() async {
    if (_initialized) return;

    try {
      final jsonString = await rootBundle.loadString('assets/env.json');
      final config = jsonDecode(jsonString) as Map<String, dynamic>;
      _geminiApiKey = config['GEMINI_HANDWRITING_API_KEY'] ?? '';
      _openAiApiKey = config['OPENAI_API_KEY'] ?? '';
      _initialized = true;
      debugPrint('GeminiHandwritingService: Initialized, Gemini: ${_geminiApiKey.isNotEmpty}, OpenAI: ${_openAiApiKey.isNotEmpty}');
    } catch (e) {
      _geminiApiKey = '';
      _openAiApiKey = '';
      _initialized = true;
      debugPrint('GeminiHandwritingService: Failed to load API keys: $e');
    }
  }

  GeminiHandwritingService() {
    if (_geminiApiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _geminiApiKey,
      );
    }
  }

  bool get isGeminiConfigured => _geminiApiKey.isNotEmpty && _model != null;
  bool get isOpenAiConfigured => _openAiApiKey.isNotEmpty;
  bool get isConfigured => isGeminiConfigured || isOpenAiConfigured;

  Future<HandwritingResult> recognizeDrawing(
    Uint8List imageBytes, {
    String? guideCharacter,
    bool isBangla = false,
  }) async {
    if (!isConfigured) {
      debugPrint('GeminiHandwritingService: No AI service configured');
      return _getFallbackResult(guideCharacter);
    }

    // Try Gemini first
    if (isGeminiConfigured) {
      try {
        final result = await _recognizeWithGemini(imageBytes, guideCharacter: guideCharacter, isBangla: isBangla);
        if (result != null) return result;
      } catch (e) {
        debugPrint('GeminiHandwritingService: Gemini failed: $e');
        // Fall through to OpenAI
      }
    }

    // Fallback to OpenAI
    if (isOpenAiConfigured) {
      try {
        final result = await _recognizeWithOpenAi(imageBytes, guideCharacter: guideCharacter, isBangla: isBangla);
        if (result != null) return result;
      } catch (e) {
        debugPrint('GeminiHandwritingService: OpenAI failed: $e');
      }
    }

    return _getFallbackResult(guideCharacter);
  }

  Future<HandwritingResult?> _recognizeWithGemini(
    Uint8List imageBytes, {
    String? guideCharacter,
    bool isBangla = false,
  }) async {
    debugPrint('GeminiHandwritingService: Trying Gemini...');

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
      debugPrint('GeminiHandwritingService: Empty Gemini response');
      return null;
    }

    return _parseJsonResponse(response.text!, guideCharacter, 'Gemini');
  }

  Future<HandwritingResult?> _recognizeWithOpenAi(
    Uint8List imageBytes, {
    String? guideCharacter,
    bool isBangla = false,
  }) async {
    debugPrint('GeminiHandwritingService: Trying OpenAI fallback...');

    final prompt = _buildPrompt(guideCharacter, isBangla);
    final base64Image = base64Encode(imageBytes);

    final systemPrompt = isBangla
        ? 'You are a handwriting recognition system for Bengali/Bangla script. Identify the character drawn in the image. You can distinguish between Bangla consonants, vowels, and digits. Be honest about what you see. Respond only with valid JSON.'
        : 'You are a handwriting recognition system. Identify the character drawn in the image. Be honest about what you see. Respond only with valid JSON.';

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_openAiApiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'system',
            'content': systemPrompt,
          },
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': prompt},
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/png;base64,$base64Image',
                  'detail': 'high',
                },
              },
            ],
          }
        ],
        'temperature': 0.2,
        'max_tokens': 300,
      }),
    );

    if (response.statusCode != 200) {
      debugPrint('GeminiHandwritingService: OpenAI HTTP ${response.statusCode}: ${response.body}');
      return null;
    }

    final data = jsonDecode(response.body);
    final content = data['choices']?[0]?['message']?['content'];
    if (content == null || content.isEmpty) {
      debugPrint('GeminiHandwritingService: Empty OpenAI response');
      return null;
    }

    return _parseJsonResponse(content, guideCharacter, 'OpenAI');
  }

  HandwritingResult? _parseJsonResponse(String text, String? guideCharacter, String source) {
    try {
      String jsonString = text;

      // Clean up potential markdown code blocks
      if (jsonString.contains('```json')) {
        jsonString = jsonString.split('```json')[1].split('```')[0];
      } else if (jsonString.contains('```')) {
        jsonString = jsonString.split('```')[1].split('```')[0];
      }

      final json = jsonDecode(jsonString.trim());
      debugPrint('GeminiHandwritingService: $source recognition successful!');
      return HandwritingResult.fromJson(json, guideCharacter: guideCharacter);
    } catch (e) {
      debugPrint('GeminiHandwritingService: $source JSON parse error: $e');
      return _parseTextResponse(text, guideCharacter);
    }
  }

  String _buildPrompt(String? guideCharacter, bool isBangla) {
    final language = isBangla ? 'Bangla/Bengali' : 'English';
    
    // Build character list context for recognition
    final charContext = isBangla ? '''
The drawing is a $language character. Possible characters include:
- Bangla vowels (স্বরবর্ণ): অ আ ই ঈ উ ঊ ঋ এ ঐ ও ঔ
- Bangla consonants (ব্যঞ্জনবর্ণ): ক খ গ ঘ ঙ চ ছ জ ঝ ঞ ট ঠ ড ঢ ণ ত থ দ ধ ন প ফ ব ভ ম য র ল শ ষ স হ ড় ঢ় য় ৎ ং ঃ ঁ
- Bangla digits: ০ ১ ২ ৩ ৪ ৫ ৬ ৭ ৮ ৯
WARNING: Some Bangla letters look similar to digits but are different (e.g. ছ vs ৫).''' : '''
The drawing is a $language character (A-Z, a-z, or 0-9).''';

    if (guideCharacter != null) {
      return '''You are a handwriting recognition system. A child drew a character on a white canvas. The image shows colored strokes on a white background.

YOUR TASK: Identify what character the child drew and rate the drawing quality.
$charContext

IMPORTANT: You do NOT know what the child was trying to draw. Just look at the strokes and identify the character based purely on what you see.

RESPOND ONLY with valid JSON:
{
  "character": "the single character you recognize",
  "neatness_score": 1 to 10,
  "feedback": "specific tips to improve"
}

RULES:
- "character": The single character you actually see in the drawing. Must be one of the characters listed above. If unrecognizable, put "?".
- "neatness_score" (1-10): How clean and well-formed is the drawing?
  * 9-10: Very clean, smooth, well-proportioned
  * 7-8: Clearly readable with minor wobbles
  * 5-6: Readable but messy/rough
  * 3-4: Barely readable, very messy
  * 1-2: Unreadable scribbles
- "feedback": Short, specific tip for the child to improve their handwriting. Keep it kid-friendly.
- Be HONEST about what character you see. Do NOT guess - if it is unclear, say "?".''';
    } else {
      return '''Identify the handwritten character in this image. Colored strokes on white background.
$charContext

Respond ONLY with valid JSON:
{
  "character": "?",
  "neatness_score": 1,
  "feedback": "Please select a guide character first!"
}''';
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
