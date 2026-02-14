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
        ? 'You are an expert in Bengali/Bangla script recognition. You can accurately distinguish between Bangla consonants (ব্যঞ্জনবর্ণ), vowels (স্বরবর্ণ), and Bangla digits (০-৯). IMPORTANT: Bangla letters and Bangla digits can look similar but are different. For example, ছ (cho, a consonant) is NOT ৫ (5, a digit). Always consider the context: if the user is practicing a Bangla letter, recognize it as a letter, not a digit. Respond only with valid JSON.'
        : 'You are an expert handwriting recognition assistant for children. Respond only with valid JSON.';

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
    
    // Build Bangla-specific context when needed
    final banglaContext = isBangla ? '''

BANGLA SCRIPT CONTEXT (VERY IMPORTANT):
- The child is practicing BANGLA SCRIPT (বাংলা লিপি)
- Bangla consonants (ব্যঞ্জনবর্ণ): ক খ গ ঘ ঙ চ ছ জ ঝ ঞ ট ঠ ড ঢ ণ ত থ দ ধ ন প ফ ব ভ ম য র ল শ ষ স হ ড় ঢ় য় ৎ ং ঃ ঁ
- Bangla vowels (স্বরবর্ণ): অ আ ই ঈ উ ঊ ঋ এ ঐ ও ঔ
- Bangla digits: ০ ১ ২ ৩ ৪ ৫ ৬ ৭ ৮ ৯
- WARNING: Some Bangla letters look similar to Bangla digits but they are DIFFERENT:
  * ছ (cho, consonant) vs ৫ (5, digit) - these look similar but are different!
  * ৯ (9, digit) vs ৯ - context matters
- If the target character is a Bangla LETTER, recognize the drawing as a LETTER, NOT a digit
- If the target character is a Bangla DIGIT, recognize the drawing as a DIGIT
- The "character" field in your response MUST be a Bangla character from the lists above, matching the type (letter vs digit) of the target''' : '';

    if (guideCharacter != null) {
      return '''You are a strict but fair handwriting recognition expert helping a child learn to write correctly. The child is trying to draw the $language character "$guideCharacter".

IMPORTANT: Carefully analyze the handwritten drawing in the image and determine:
1. What character did the child actually draw? (MUST be a $language character)
2. Does it structurally match the target character "$guideCharacter"?
3. How accurate/confident is the match (0.0 to 1.0)?
$banglaContext

Respond ONLY with valid JSON in this exact format:
{
  "character": "the character you actually see in the drawing",
  "is_match": true or false,
  "feedback": "encouraging feedback for the child",
  "confidence": 0.0 to 1.0
}

EVALUATION GUIDELINES (BE STRICT):
- The child is specifically practicing "$guideCharacter" - evaluate how well they drew THIS character
- "character" should be the character you ACTUALLY recognize from the drawing, NOT just "$guideCharacter" by default
- Evaluate the STRUCTURAL ACCURACY of the drawing:
  * Are the key strokes and curves of "$guideCharacter" present?
  * Is the overall structure and proportion correct?
  * Are the distinct parts of the character properly formed?
- "is_match" should be TRUE only if the drawing clearly shows the key structural elements of "$guideCharacter" with reasonable accuracy
- "is_match" should be FALSE if:
  * The drawing is missing key structural parts of "$guideCharacter"
  * The strokes are in wrong positions or directions
  * The drawing looks like a different character
  * The drawing is just random scribbles or lines
  * The drawing is too messy to be recognized as "$guideCharacter"
- "confidence" scoring:
  * 0.9-1.0: Excellent, very clear and well-formed "$guideCharacter"
  * 0.7-0.89: Good attempt, recognizable as "$guideCharacter" with minor issues
  * 0.5-0.69: Mediocre attempt, somewhat recognizable but significant issues
  * 0.3-0.49: Poor attempt, barely recognizable
  * 0.0-0.29: Not recognizable as "$guideCharacter"
- Set is_match to true ONLY when confidence is 0.5 or above
- Do NOT be overly lenient - the goal is to help the child learn proper handwriting

FEEDBACK GUIDELINES:
- If is_match is TRUE and confidence >= 0.8: Praise them enthusiastically! ("Great job!", "Perfect!", "You did it!")
- If is_match is TRUE and confidence < 0.8: Praise with tips ("Good work! Try to make the curves smoother next time!")
- If is_match is FALSE: Be encouraging but clear ("Good try! Let's try $guideCharacter again! Focus on the shape.")
- Keep feedback simple and kid-friendly (ages 4-10)
- Use positive language even for mistakes

The "character" field MUST be a single $language character or "?" if unrecognizable.''';
    } else {
      return '''Analyze this handwritten character drawing.

Recognize the character and provide encouraging feedback for a child learning to write.
$banglaContext

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
