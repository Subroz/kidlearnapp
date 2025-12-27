import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void _log(String message) {
  if (kDebugMode) {
    print(message);
  }
}

class StoryRequest {
  final List<String> words;
  final bool isBangla;

  StoryRequest({
    required this.words,
    this.isBangla = false,
  });
}

class StoryResponse {
  final String title;
  final String content;
  final String moral;
  final List<String> vocabulary;
  final List<String> questions;

  StoryResponse({
    required this.title,
    required this.content,
    required this.moral,
    required this.vocabulary,
    required this.questions,
  });

  factory StoryResponse.fromJson(Map<String, dynamic> json) {
    return StoryResponse(
      title: json['title'] ?? 'A Magical Story',
      content: json['content'] ?? json['story'] ?? '',
      moral: json['moral'] ?? '',
      vocabulary: List<String>.from(json['vocabulary'] ?? []),
      questions: List<String>.from(json['questions'] ?? []),
    );
  }
}

class GeminiService {
  static String _apiKey = '';
  static bool _initialized = false;

  GenerativeModel? _model;

  /// Initialize the service by loading the API key from env.json
  /// Call this once at app startup before using GeminiService
  static Future<void> init() async {
    if (_initialized) return;

    try {
      final jsonString = await rootBundle.loadString('assets/env.json');
      final config = jsonDecode(jsonString) as Map<String, dynamic>;
      _apiKey = config['GEMINI_API_KEY'] ?? '';
      _initialized = true;
      _log('GeminiService: Initialized, API key loaded: ${_apiKey.isNotEmpty}');
    } catch (e) {
      // If env.json doesn't exist or can't be parsed, continue without API key
      _apiKey = '';
      _initialized = true;
      _log('GeminiService: Failed to load API key: $e');
    }
  }

  GeminiService() {
    if (_apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-2.5-flash-lite',
        apiKey: _apiKey,
      );
    }
  }

  bool get isConfigured => _apiKey.isNotEmpty && _model != null;

  Future<StoryResponse> generateStory(StoryRequest request) async {
    _log(
        'GeminiService: isConfigured = $isConfigured, apiKey empty = ${_apiKey.isEmpty}');

    if (!isConfigured) {
      _log('GeminiService: Not configured, using fallback story');
      return _getFallbackStory(request);
    }

    try {
      _log('GeminiService: Generating story with AI...');
      final prompt = _buildPrompt(request);
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      _log('GeminiService: Got response from Gemini');

      if (response.text == null || response.text!.isEmpty) {
        _log('GeminiService: Empty response, using fallback');
        return _getFallbackStory(request);
      }

      // Try to parse JSON response
      try {
        String jsonString = response.text!;
        _log('GeminiService: Parsing response...');

        // Clean up potential markdown code blocks
        if (jsonString.contains('```json')) {
          jsonString = jsonString.split('```json')[1].split('```')[0];
        } else if (jsonString.contains('```')) {
          jsonString = jsonString.split('```')[1].split('```')[0];
        }

        final json = jsonDecode(jsonString.trim());
        _log('GeminiService: Story generated successfully with AI!');
        return StoryResponse.fromJson(json);
      } catch (e) {
        _log('GeminiService: JSON parse error: $e');
        // If JSON parsing fails, create a basic response
        return StoryResponse(
          title: request.isBangla ? 'একটি সুন্দর গল্প' : 'A Beautiful Story',
          content: response.text!,
          moral: request.isBangla
              ? 'ভালো কাজ করলে ভালো ফল পাওয়া যায়'
              : 'Good deeds bring good results',
          vocabulary: request.words,
          questions: [
            request.isBangla
                ? 'গল্পটা তোমার কেমন লাগলো?'
                : 'How did you like the story?'
          ],
        );
      }
    } catch (e) {
      _log('GeminiService: Error generating story: $e');
      return _getFallbackStory(request);
    }
  }

  String _buildPrompt(StoryRequest request) {
    final words = request.words.join(', ');
    final language = request.isBangla ? 'Bangla' : 'English';

    return '''
Generate a short, engaging children's story in $language using these words: $words

Requirements:
- The story should be appropriate for children ages 4-10
- It should be fun, educational, and have a positive message
- Keep it under 200 words
- Include a clear moral lesson

Return the response as a JSON object with this exact structure:
{
  "title": "Story title",
  "content": "The full story text",
  "moral": "The moral of the story",
  "vocabulary": ["word1", "word2"],
  "questions": ["Question about the story?"]
}

Only return the JSON, no other text.
''';
  }

  StoryResponse _getFallbackStory(StoryRequest request) {
    if (request.isBangla) {
      return StoryResponse(
        title: 'বন্ধুত্বের গল্প',
        content: '''
একদিন একটি ছোট্ট খরগোশ বনে হাঁটছিল। সে দেখল একটি কচ্ছপ খুব ধীরে ধীরে হাঁটছে।

"তুমি এত ধীরে কেন হাঁটো?" খরগোশ জিজ্ঞেস করল।

"আমি ধীরে হাঁটি, কিন্তু আমি কখনো থামি না," কচ্ছপ হেসে বলল।

তারা দুজনে বন্ধু হয়ে গেল। খরগোশ দ্রুত দৌড়াতো আর কচ্ছপ ধীরে চলতো, কিন্তু তারা সবসময় একসাথে থাকতো।

একদিন বৃষ্টি এলো। খরগোশ দ্রুত দৌড়ে গেল, কিন্তু কচ্ছপ ভিজে গেল। তখন খরগোশ ফিরে এসে কচ্ছপকে সাহায্য করল।

"সত্যিকারের বন্ধু সবসময় পাশে থাকে," তারা দুজনে বলল।
''',
        moral: 'সত্যিকারের বন্ধুত্ব মানে একে অপরকে সাহায্য করা',
        vocabulary: ['খরগোশ', 'কচ্ছপ', 'বন্ধুত্ব', 'সাহায্য'],
        questions: [
          'খরগোশ কীভাবে কচ্ছপকে সাহায্য করেছিল?',
          'তোমার সেরা বন্ধু কে?',
        ],
      );
    }

    return StoryResponse(
      title: 'The Helpful Friends',
      content: '''
Once upon a time, in a beautiful garden, there lived a little butterfly named Bella and a tiny ant named Andy.

Bella could fly high in the sky, while Andy worked hard on the ground. They were very different, but they were best friends.

One sunny day, Bella saw Andy trying to carry a big leaf. It was too heavy for the little ant!

"Let me help you!" said Bella. She held one end of the leaf while Andy pushed from below.

Together, they carried the leaf to Andy's home. Andy was so happy!

"Thank you, Bella!" said Andy. "You're the best friend ever!"

From that day on, whenever one friend needed help, the other was always there. And they lived happily, helping each other every day.
''',
      moral: 'True friends always help each other',
      vocabulary: ['butterfly', 'ant', 'garden', 'help', 'together'],
      questions: [
        'How did Bella help Andy?',
        'Who is your best friend?',
        'How do you help your friends?',
      ],
    );
  }
}
