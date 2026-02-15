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
  final bool isClose;
  final String? hint;

  HandwritingResult({
    required this.character,
    required this.feedback,
    required this.confidence,
    required this.isMatch,
    this.expectedCharacter,
    this.structureScore = 0,
    this.readabilityScore = 0,
    this.neatnessScore = 0,
    this.isClose = false,
    this.hint,
  });

  factory HandwritingResult.fromJson(Map<String, dynamic> json, {String? guideCharacter}) {
    final character = (json['character'] ?? '?').toString().trim();
    final neatness = (json['neatness_score'] ?? 5).toInt().clamp(1, 10);
    final feedback = (json['feedback'] ?? 'Keep practicing!').toString();
    final confidence = (neatness / 10.0).clamp(0.0, 1.0);

    bool isMatch = false;
    bool isClose = false;
    String? hint;

    if (guideCharacter != null && character != '?') {
      if (character == guideCharacter) {
        isMatch = true;
      } else {
        isClose = _areSimilarCharacters(character, guideCharacter);
        if (isClose) {
          hint = _getSimilarityHint(character, guideCharacter);
        }
      }
    }

    debugPrint('HandwritingResult: recognized="$character", expected="$guideCharacter", neatness=$neatness, isMatch=$isMatch, isClose=$isClose');

    return HandwritingResult(
      character: character,
      feedback: feedback,
      confidence: confidence,
      isMatch: isMatch,
      expectedCharacter: guideCharacter,
      neatnessScore: neatness,
      isClose: isClose,
      hint: hint,
    );
  }

  static bool _areSimilarCharacters(String a, String b) {
    final similarGroups = [
      {'ক', 'ফ'},
      {'খ', 'যু'},
      {'গ', 'ণ'},
      {'ঘ', 'ধ'},
      {'চ', 'ব'},
      {'ছ', '৫'},
      {'জ', 'ঝ'},
      {'ট', 'ড'},
      {'ঠ', 'ঢ'},
      {'ত', 'ন'},
      {'থ', 'ধ'},
      {'দ', 'ল'},
      {'প', 'শ'},
      {'ফ', 'ক'},
      {'ব', 'চ'},
      {'ভ', 'ম'},
      {'ম', 'ভ'},
      {'য', 'ষ'},
      {'র', 'ব'},
      {'শ', 'প'},
      {'ষ', 'য'},
      {'স', 'হ'},
      {'ড়', 'ড'},
      {'ঢ়', 'ঢ'},
      {'অ', 'আ'},
      {'ই', 'ঈ'},
      {'উ', 'ঊ'},
      {'এ', 'ঐ'},
      {'ও', 'ঔ'},
      {'০', 'ও'},
      {'৩', '৫'},
      {'b', 'd'},
      {'p', 'q'},
      {'m', 'n'},
      {'u', 'v'},
      {'i', 'l'},
      {'O', '0'},
    ];

    for (final group in similarGroups) {
      if (group.contains(a) && group.contains(b)) {
        return true;
      }
    }
    return false;
  }

  static String? _getSimilarityHint(String recognized, String expected) {
    final banglaHints = <String, Map<String, String>>{
      'ক': {'ফ': 'ক has a shorter tail than ফ'},
      'ফ': {'ক': 'ফ has a longer tail going down'},
      'ঘ': {'ধ': 'ঘ has a dot on top, ধ does not'},
      'থ': {'ধ': 'থ has a straight line, ধ has a curve'},
      'চ': {'ব': 'চ curves to the left, ব curves to the right'},
      'ছ': {'৫': 'ছ is a letter, ৫ is the number 5'},
      'জ': {'ঝ': 'ঝ has an extra hook at the bottom'},
      'ট': {'ড': 'ড has a dot underneath'},
      'ঠ': {'ঢ': 'ঢ has a dot underneath'},
      'ত': {'ন': 'ন has a longer bottom stroke'},
      'দ': {'ল': 'দ has a rounded top, ল is more angular'},
      'প': {'শ': 'প has one curve, শ has extra lines'},
      'ভ': {'ম': 'ভ has a dot, ম does not'},
      'ম': {'ভ': 'ম has no dot, ভ has one'},
      'অ': {'আ': 'আ has an extra vertical line on the right'},
      'ই': {'ঈ': 'ঈ has an extra mark at the bottom'},
      'উ': {'ঊ': 'ঊ has an extra curve at the bottom'},
      'এ': {'ঐ': 'ঐ has an extra mark on top'},
      'ও': {'ঔ': 'ঔ has an extra mark on top'},
    };

    final key = recognized;
    if (banglaHints.containsKey(key) && banglaHints[key]!.containsKey(expected)) {
      return banglaHints[key]![expected];
    }

    final reverseKey = expected;
    if (banglaHints.containsKey(reverseKey) && banglaHints[reverseKey]!.containsKey(recognized)) {
      return banglaHints[reverseKey]![recognized];
    }

    return 'Look carefully at the shape — your drawing looks like "$recognized" but should be "$expected"';
  }
}

class GeminiHandwritingService {
  static String _geminiApiKey = '';
  static String _openAiApiKey = '';
  static bool _initialized = false;

  GenerativeModel? _model;

  static Future<void> init() async {
    if (_initialized) return;

    try {
      final jsonString = await rootBundle.loadString('assets/env.json');
      final config = jsonDecode(jsonString) as Map<String, dynamic>;
      _geminiApiKey = config['GEMINI_HANDWRITING_API_KEY'] ?? '';
      _openAiApiKey = config['OPENAI_API_KEY'] ?? '';
      _initialized = true;
      debugPrint('GeminiHandwritingService: Initialized, API key loaded: ${_openAiApiKey.isNotEmpty || _geminiApiKey.isNotEmpty}');
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

    if (isOpenAiConfigured) {
      try {
        final result = await _recognizeWithOpenAi(imageBytes, guideCharacter: guideCharacter, isBangla: isBangla);
        if (result != null) return result;
      } catch (e) {
        debugPrint('GeminiHandwritingService: OpenAI failed: $e');
      }
    }

    if (isGeminiConfigured) {
      try {
        final result = await _recognizeWithGemini(imageBytes, guideCharacter: guideCharacter, isBangla: isBangla);
        if (result != null) return result;
      } catch (e) {
        debugPrint('GeminiHandwritingService: Gemini fallback failed: $e');
      }
    }

    return _getFallbackResult(guideCharacter);
  }

  Future<HandwritingResult?> _recognizeWithOpenAi(
    Uint8List imageBytes, {
    String? guideCharacter,
    bool isBangla = false,
  }) async {
    debugPrint('GeminiHandwritingService: Trying OpenAI (primary)...');

    final prompt = _buildPrompt(guideCharacter, isBangla);
    final base64Image = base64Encode(imageBytes);

    final systemPrompt = isBangla
        ? '''You are an expert handwriting recognition system specialized in Bengali/Bangla script for children's education.
You have deep knowledge of all Bangla characters including:
- Vowels (স্বরবর্ণ): অ আ ই ঈ উ ঊ ঋ এ ঐ ও ঔ
- Consonants (ব্যঞ্জনবর্ণ): ক খ গ ঘ ঙ চ ছ জ ঝ ঞ ট ঠ ড ঢ ণ ত থ দ ধ ন প ফ ব ভ ম য র ল শ ষ স হ ড় ঢ় য় ৎ ং ঃ ঁ
- Digits: ০ ১ ২ ৩ ৪ ৫ ৬ ৭ ৮ ৯

CRITICAL RULES:
- Children's handwriting is often messy, wobbly, and imperfect. Be understanding but accurate.
- Pay close attention to distinguishing similar-looking characters (e.g., ছ vs ৫, ক vs ফ, ট vs ড, চ vs ব).
- Look at the overall shape and stroke direction, not just individual parts.
- Never confuse Bangla digits with letters that look similar.
- Respond ONLY with valid JSON. No extra text.'''
        : '''You are an expert handwriting recognition system for children's education.
Children's handwriting is often messy, wobbly, and imperfect. Be understanding but accurate.
Pay close attention to distinguishing similar-looking characters (e.g., b vs d, p vs q, m vs n).
Respond ONLY with valid JSON. No extra text.''';

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_openAiApiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4.1',
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
        'temperature': 0.1,
        'max_tokens': 400,
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

  Future<HandwritingResult?> _recognizeWithGemini(
    Uint8List imageBytes, {
    String? guideCharacter,
    bool isBangla = false,
  }) async {
    debugPrint('GeminiHandwritingService: Trying Gemini (fallback)...');

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

  HandwritingResult? _parseJsonResponse(String text, String? guideCharacter, String source) {
    try {
      String jsonString = text;

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

    final charContext = isBangla ? '''
The drawing is a $language character written by a young child. Possible characters include:
- Bangla vowels (স্বরবর্ণ): অ আ ই ঈ উ ঊ ঋ এ ঐ ও ঔ
- Bangla consonants (ব্যঞ্জনবর্ণ): ক খ গ ঘ ঙ চ ছ জ ঝ ঞ ট ঠ ড ঢ ণ ত থ দ ধ ন প ফ ব ভ ম য র ল শ ষ স হ ড় ঢ় য় ৎ ং ঃ ঁ
- Bangla digits: ০ ১ ২ ৩ ৪ ৫ ৬ ৭ ৮ ৯

IMPORTANT DISTINCTIONS for similar-looking Bangla characters:
- ছ (letter cho) vs ৫ (digit 5): ছ has a more elaborate top, ৫ is simpler
- ক (ko) vs ফ (pho): ফ has a longer descending tail
- ট (to) vs ড (do): ড has a dot (nukta) underneath
- ঠ (tho) vs ঢ (dho): ঢ has a dot underneath
- চ (cho) vs ব (bo): Different curves - চ opens left, ব opens right
- ত (to) vs ন (no): ন has a longer horizontal base stroke
- ঘ (gho) vs ধ (dho): ঘ has a distinct dot/mark on top
- ভ (bho) vs ম (mo): ভ has a dot, ম does not
- অ (o) vs আ (aa): আ has an extra vertical line
- ই (i) vs ঈ (ii): ঈ has an extra mark below''' : '''
The drawing is a $language character (A-Z, a-z, or 0-9) written by a young child.

IMPORTANT DISTINCTIONS:
- b vs d: mirror images, check direction of bump
- p vs q: mirror images, check direction of bump
- m vs n: m has two humps, n has one
- u vs v: u is rounded, v is pointed
- O vs 0: context matters, treat as same
- i vs l vs 1: i has a dot, l is taller, 1 may have serif''';

    if (guideCharacter != null) {
      return '''A young child (ages 3-7) drew a character on a white canvas using colored strokes. This is their handwriting practice.

YOUR TASK: Identify what character the child drew and rate the drawing quality.
$charContext

ANALYSIS STEPS:
1. Look at the overall shape of the strokes
2. Count the major strokes and their directions
3. Compare against known character shapes
4. Pick the BEST matching character from the list above

RESPOND ONLY with valid JSON:
{
  "character": "the single character you recognize",
  "neatness_score": 1 to 10,
  "feedback": "specific, encouraging tip for the child"
}

SCORING GUIDE (be lenient for children):
- "character": The character you see. Must be from the list above. Use "?" only if truly unrecognizable.
- "neatness_score" (1-10): Rate for a CHILD's ability level.
  * 9-10: Excellent for a child - clear and well-formed
  * 7-8: Good - clearly readable with some wobbles
  * 5-6: Okay - recognizable but messy
  * 3-4: Needs practice - hard to read
  * 1-2: Just scribbles
- "feedback": Give one specific, encouraging tip. Use simple words a child can understand. Example: "Try to make the round part bigger!" or "Great curves! Make the line a bit straighter next time."
- Be HONEST about what character you see. Do NOT guess or assume what they intended.''';
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
    String character = '?';
    String feedback = 'Good try! Keep practicing!';
    double confidence = 0.5;
    bool isMatch = false;

    final singleChars = RegExp(r'\b[A-Za-z0-9অ-ৰ]\b').allMatches(text);
    if (singleChars.isNotEmpty) {
      character = singleChars.first.group(0) ?? '?';
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
