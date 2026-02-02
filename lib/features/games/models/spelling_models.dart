/// Difficulty levels for the Spelling Bee game
enum SpellingDifficulty {
  easy,    // 3-4 letter words
  medium,  // 5-6 letter words
  hard,    // 7+ letter words
}

/// Represents a word in the spelling game
class SpellingWord {
  final String wordEn;
  final String wordBn;
  final String? hintEn;
  final String? hintBn;
  final SpellingDifficulty difficulty;
  final String category;

  const SpellingWord({
    required this.wordEn,
    required this.wordBn,
    this.hintEn,
    this.hintBn,
    required this.difficulty,
    required this.category,
  });

  factory SpellingWord.fromJson(Map<String, dynamic> json, SpellingDifficulty difficulty) {
    return SpellingWord(
      wordEn: json['wordEn'] ?? '',
      wordBn: json['wordBn'] ?? '',
      hintEn: json['hintEn'],
      hintBn: json['hintBn'],
      difficulty: difficulty,
      category: json['category'] ?? 'general',
    );
  }

  String getWord(bool isBangla) => isBangla ? wordBn : wordEn;
  String? getHint(bool isBangla) => isBangla ? hintBn : hintEn;
}

/// Tracks a single spelling attempt
class SpellingAttempt {
  final SpellingWord word;
  final String userInput;
  final bool isCorrect;
  final int hintsUsed;
  final DateTime timestamp;

  const SpellingAttempt({
    required this.word,
    required this.userInput,
    required this.isCorrect,
    required this.hintsUsed,
    required this.timestamp,
  });
}

/// Game session state
class SpellingGameState {
  final SpellingDifficulty currentDifficulty;
  final int score;
  final int streak;
  final int totalAttempts;
  final int correctAttempts;
  final int hintsRemaining;
  final List<SpellingAttempt> history;
  final List<String> weakWords; // Words the child struggles with

  const SpellingGameState({
    this.currentDifficulty = SpellingDifficulty.easy,
    this.score = 0,
    this.streak = 0,
    this.totalAttempts = 0,
    this.correctAttempts = 0,
    this.hintsRemaining = 3,
    this.history = const [],
    this.weakWords = const [],
  });

  SpellingGameState copyWith({
    SpellingDifficulty? currentDifficulty,
    int? score,
    int? streak,
    int? totalAttempts,
    int? correctAttempts,
    int? hintsRemaining,
    List<SpellingAttempt>? history,
    List<String>? weakWords,
  }) {
    return SpellingGameState(
      currentDifficulty: currentDifficulty ?? this.currentDifficulty,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      correctAttempts: correctAttempts ?? this.correctAttempts,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      history: history ?? this.history,
      weakWords: weakWords ?? this.weakWords,
    );
  }

  double get accuracy => totalAttempts > 0 ? correctAttempts / totalAttempts : 0.0;

  /// Determines if difficulty should change based on performance
  SpellingDifficulty? suggestDifficultyChange() {
    // Level up after 3 correct in a row
    if (streak >= 3 && currentDifficulty != SpellingDifficulty.hard) {
      return SpellingDifficulty.values[currentDifficulty.index + 1];
    }
    // Level down after 2 wrong in a row (negative streak)
    if (streak <= -2 && currentDifficulty != SpellingDifficulty.easy) {
      return SpellingDifficulty.values[currentDifficulty.index - 1];
    }
    return null;
  }
}

/// Result of AI hint generation
class SpellingHint {
  final String hint;
  final String phonetic;
  final String example;

  const SpellingHint({
    required this.hint,
    required this.phonetic,
    required this.example,
  });

  factory SpellingHint.fromJson(Map<String, dynamic> json) {
    return SpellingHint(
      hint: json['hint'] ?? '',
      phonetic: json['phonetic'] ?? '',
      example: json['example'] ?? '',
    );
  }
}

/// Result of AI spelling evaluation
class SpellingEvaluation {
  final bool isCorrect;
  final String feedback;
  final String? correction;
  final double similarity;

  const SpellingEvaluation({
    required this.isCorrect,
    required this.feedback,
    this.correction,
    required this.similarity,
  });

  factory SpellingEvaluation.fromJson(Map<String, dynamic> json) {
    return SpellingEvaluation(
      isCorrect: json['is_correct'] ?? false,
      feedback: json['feedback'] ?? 'Keep trying!',
      correction: json['correction'],
      similarity: (json['similarity'] ?? 0.0).toDouble(),
    );
  }
}

/// Static word bank for offline mode and initial data
class SpellingWordBank {
  static const List<SpellingWord> easyWords = [
    // Animals
    SpellingWord(wordEn: 'cat', wordBn: 'বিড়াল', hintEn: 'A pet that says meow', hintBn: 'মিউ মিউ করে', difficulty: SpellingDifficulty.easy, category: 'animals'),
    SpellingWord(wordEn: 'dog', wordBn: 'কুকুর', hintEn: 'A pet that barks', hintBn: 'ঘেউ ঘেউ করে', difficulty: SpellingDifficulty.easy, category: 'animals'),
    SpellingWord(wordEn: 'cow', wordBn: 'গরু', hintEn: 'Gives us milk', hintBn: 'দুধ দেয়', difficulty: SpellingDifficulty.easy, category: 'animals'),
    SpellingWord(wordEn: 'hen', wordBn: 'মুরগি', hintEn: 'Gives us eggs', hintBn: 'ডিম দেয়', difficulty: SpellingDifficulty.easy, category: 'animals'),
    SpellingWord(wordEn: 'ant', wordBn: 'পিঁপড়া', hintEn: 'Tiny insect', hintBn: 'ছোট পোকা', difficulty: SpellingDifficulty.easy, category: 'animals'),
    SpellingWord(wordEn: 'bee', wordBn: 'মৌমাছি', hintEn: 'Makes honey', hintBn: 'মধু তৈরি করে', difficulty: SpellingDifficulty.easy, category: 'animals'),
    SpellingWord(wordEn: 'pig', wordBn: 'শূকর', hintEn: 'Pink farm animal', hintBn: 'গোলাপি রঙের', difficulty: SpellingDifficulty.easy, category: 'animals'),
    SpellingWord(wordEn: 'rat', wordBn: 'ইঁদুর', hintEn: 'Small with long tail', hintBn: 'লম্বা লেজ আছে', difficulty: SpellingDifficulty.easy, category: 'animals'),
    
    // Objects
    SpellingWord(wordEn: 'pen', wordBn: 'কলম', hintEn: 'We write with it', hintBn: 'লিখতে লাগে', difficulty: SpellingDifficulty.easy, category: 'objects'),
    SpellingWord(wordEn: 'cup', wordBn: 'কাপ', hintEn: 'We drink from it', hintBn: 'পানি খাই এতে', difficulty: SpellingDifficulty.easy, category: 'objects'),
    SpellingWord(wordEn: 'bag', wordBn: 'ব্যাগ', hintEn: 'Carry books in it', hintBn: 'বই রাখি এতে', difficulty: SpellingDifficulty.easy, category: 'objects'),
    SpellingWord(wordEn: 'box', wordBn: 'বাক্স', hintEn: 'Square container', hintBn: 'চারকোনা পাত্র', difficulty: SpellingDifficulty.easy, category: 'objects'),
    SpellingWord(wordEn: 'fan', wordBn: 'পাখা', hintEn: 'Makes air cool', hintBn: 'বাতাস দেয়', difficulty: SpellingDifficulty.easy, category: 'objects'),
    SpellingWord(wordEn: 'bed', wordBn: 'বিছানা', hintEn: 'We sleep on it', hintBn: 'ঘুমাই এতে', difficulty: SpellingDifficulty.easy, category: 'objects'),
    
    // Nature
    SpellingWord(wordEn: 'sun', wordBn: 'সূর্য', hintEn: 'Bright in the sky', hintBn: 'আকাশে জ্বলে', difficulty: SpellingDifficulty.easy, category: 'nature'),
    SpellingWord(wordEn: 'sky', wordBn: 'আকাশ', hintEn: 'Above our head', hintBn: 'মাথার উপরে', difficulty: SpellingDifficulty.easy, category: 'nature'),
    SpellingWord(wordEn: 'sea', wordBn: 'সাগর', hintEn: 'Big blue water', hintBn: 'বড় জলাশয়', difficulty: SpellingDifficulty.easy, category: 'nature'),
    SpellingWord(wordEn: 'air', wordBn: 'বাতাস', hintEn: 'We breathe it', hintBn: 'শ্বাস নিই', difficulty: SpellingDifficulty.easy, category: 'nature'),
    
    // Food
    SpellingWord(wordEn: 'egg', wordBn: 'ডিম', hintEn: 'Comes from hen', hintBn: 'মুরগি দেয়', difficulty: SpellingDifficulty.easy, category: 'food'),
    SpellingWord(wordEn: 'jam', wordBn: 'জ্যাম', hintEn: 'Sweet on bread', hintBn: 'রুটিতে মাখি', difficulty: SpellingDifficulty.easy, category: 'food'),
    SpellingWord(wordEn: 'ice', wordBn: 'বরফ', hintEn: 'Frozen water', hintBn: 'জমাট পানি', difficulty: SpellingDifficulty.easy, category: 'food'),
  ];

  static const List<SpellingWord> mediumWords = [
    // Animals
    SpellingWord(wordEn: 'tiger', wordBn: 'বাঘ', hintEn: 'Striped big cat', hintBn: 'ডোরাকাটা বড় বিড়াল', difficulty: SpellingDifficulty.medium, category: 'animals'),
    SpellingWord(wordEn: 'horse', wordBn: 'ঘোড়া', hintEn: 'We can ride it', hintBn: 'চড়া যায়', difficulty: SpellingDifficulty.medium, category: 'animals'),
    SpellingWord(wordEn: 'sheep', wordBn: 'ভেড়া', hintEn: 'Gives us wool', hintBn: 'পশম দেয়', difficulty: SpellingDifficulty.medium, category: 'animals'),
    SpellingWord(wordEn: 'snake', wordBn: 'সাপ', hintEn: 'Long without legs', hintBn: 'পা নেই লম্বা', difficulty: SpellingDifficulty.medium, category: 'animals'),
    SpellingWord(wordEn: 'zebra', wordBn: 'জেব্রা', hintEn: 'Black and white stripes', hintBn: 'কালো সাদা ডোরা', difficulty: SpellingDifficulty.medium, category: 'animals'),
    SpellingWord(wordEn: 'camel', wordBn: 'উট', hintEn: 'Has a hump', hintBn: 'কুঁজ আছে', difficulty: SpellingDifficulty.medium, category: 'animals'),
    SpellingWord(wordEn: 'mouse', wordBn: 'ইঁদুর', hintEn: 'Small and squeaky', hintBn: 'ছোট এবং চিঁচিঁ করে', difficulty: SpellingDifficulty.medium, category: 'animals'),
    SpellingWord(wordEn: 'whale', wordBn: 'তিমি', hintEn: 'Biggest sea animal', hintBn: 'সবচেয়ে বড় সামুদ্রিক প্রাণী', difficulty: SpellingDifficulty.medium, category: 'animals'),
    
    // Objects
    SpellingWord(wordEn: 'chair', wordBn: 'চেয়ার', hintEn: 'We sit on it', hintBn: 'বসার জিনিস', difficulty: SpellingDifficulty.medium, category: 'objects'),
    SpellingWord(wordEn: 'table', wordBn: 'টেবিল', hintEn: 'We eat on it', hintBn: 'খাওয়ার জায়গা', difficulty: SpellingDifficulty.medium, category: 'objects'),
    SpellingWord(wordEn: 'clock', wordBn: 'ঘড়ি', hintEn: 'Shows time', hintBn: 'সময় দেখায়', difficulty: SpellingDifficulty.medium, category: 'objects'),
    SpellingWord(wordEn: 'brush', wordBn: 'ব্রাশ', hintEn: 'Clean teeth with it', hintBn: 'দাঁত মাজি', difficulty: SpellingDifficulty.medium, category: 'objects'),
    SpellingWord(wordEn: 'phone', wordBn: 'ফোন', hintEn: 'We talk on it', hintBn: 'কথা বলি', difficulty: SpellingDifficulty.medium, category: 'objects'),
    SpellingWord(wordEn: 'spoon', wordBn: 'চামচ', hintEn: 'Eat soup with it', hintBn: 'স্যুপ খাই', difficulty: SpellingDifficulty.medium, category: 'objects'),
    
    // Nature
    SpellingWord(wordEn: 'river', wordBn: 'নদী', hintEn: 'Water flows in it', hintBn: 'পানি বয়ে যায়', difficulty: SpellingDifficulty.medium, category: 'nature'),
    SpellingWord(wordEn: 'cloud', wordBn: 'মেঘ', hintEn: 'White in the sky', hintBn: 'আকাশে সাদা', difficulty: SpellingDifficulty.medium, category: 'nature'),
    SpellingWord(wordEn: 'grass', wordBn: 'ঘাস', hintEn: 'Green on ground', hintBn: 'মাটিতে সবুজ', difficulty: SpellingDifficulty.medium, category: 'nature'),
    SpellingWord(wordEn: 'stone', wordBn: 'পাথর', hintEn: 'Hard and rocky', hintBn: 'শক্ত জিনিস', difficulty: SpellingDifficulty.medium, category: 'nature'),
    SpellingWord(wordEn: 'ocean', wordBn: 'মহাসাগর', hintEn: 'Very big sea', hintBn: 'অনেক বড় সাগর', difficulty: SpellingDifficulty.medium, category: 'nature'),
    
    // Food
    SpellingWord(wordEn: 'apple', wordBn: 'আপেল', hintEn: 'Red round fruit', hintBn: 'লাল গোল ফল', difficulty: SpellingDifficulty.medium, category: 'food'),
    SpellingWord(wordEn: 'bread', wordBn: 'রুটি', hintEn: 'Made from flour', hintBn: 'আটা দিয়ে তৈরি', difficulty: SpellingDifficulty.medium, category: 'food'),
    SpellingWord(wordEn: 'juice', wordBn: 'জুস', hintEn: 'Drink from fruits', hintBn: 'ফলের পানীয়', difficulty: SpellingDifficulty.medium, category: 'food'),
    SpellingWord(wordEn: 'mango', wordBn: 'আম', hintEn: 'King of fruits', hintBn: 'ফলের রাজা', difficulty: SpellingDifficulty.medium, category: 'food'),
    SpellingWord(wordEn: 'pizza', wordBn: 'পিজা', hintEn: 'Round with cheese', hintBn: 'গোল পনির দিয়ে', difficulty: SpellingDifficulty.medium, category: 'food'),
  ];

  static const List<SpellingWord> hardWords = [
    // Animals
    SpellingWord(wordEn: 'elephant', wordBn: 'হাতি', hintEn: 'Has a long trunk', hintBn: 'লম্বা শুঁড় আছে', difficulty: SpellingDifficulty.hard, category: 'animals'),
    SpellingWord(wordEn: 'giraffe', wordBn: 'জিরাফ', hintEn: 'Tallest animal', hintBn: 'সবচেয়ে লম্বা প্রাণী', difficulty: SpellingDifficulty.hard, category: 'animals'),
    SpellingWord(wordEn: 'dolphin', wordBn: 'ডলফিন', hintEn: 'Smart sea animal', hintBn: 'বুদ্ধিমান সামুদ্রিক প্রাণী', difficulty: SpellingDifficulty.hard, category: 'animals'),
    SpellingWord(wordEn: 'penguin', wordBn: 'পেঙ্গুইন', hintEn: 'Bird that cannot fly', hintBn: 'উড়তে পারে না', difficulty: SpellingDifficulty.hard, category: 'animals'),
    SpellingWord(wordEn: 'kangaroo', wordBn: 'ক্যাঙ্গারু', hintEn: 'Jumps and has pouch', hintBn: 'লাফায় থলি আছে', difficulty: SpellingDifficulty.hard, category: 'animals'),
    SpellingWord(wordEn: 'butterfly', wordBn: 'প্রজাপতি', hintEn: 'Colorful flying insect', hintBn: 'রঙিন উড়ন্ত পোকা', difficulty: SpellingDifficulty.hard, category: 'animals'),
    SpellingWord(wordEn: 'crocodile', wordBn: 'কুমির', hintEn: 'Big reptile in water', hintBn: 'পানিতে থাকে বড়', difficulty: SpellingDifficulty.hard, category: 'animals'),
    SpellingWord(wordEn: 'squirrel', wordBn: 'কাঠবিড়ালি', hintEn: 'Collects nuts', hintBn: 'বাদাম জমায়', difficulty: SpellingDifficulty.hard, category: 'animals'),
    
    // Objects
    SpellingWord(wordEn: 'umbrella', wordBn: 'ছাতা', hintEn: 'Keeps rain away', hintBn: 'বৃষ্টি থেকে বাঁচায়', difficulty: SpellingDifficulty.hard, category: 'objects'),
    SpellingWord(wordEn: 'computer', wordBn: 'কম্পিউটার', hintEn: 'Electronic device', hintBn: 'ইলেকট্রনিক যন্ত্র', difficulty: SpellingDifficulty.hard, category: 'objects'),
    SpellingWord(wordEn: 'scissors', wordBn: 'কাঁচি', hintEn: 'Cut paper with it', hintBn: 'কাগজ কাটি', difficulty: SpellingDifficulty.hard, category: 'objects'),
    SpellingWord(wordEn: 'calendar', wordBn: 'ক্যালেন্ডার', hintEn: 'Shows dates', hintBn: 'তারিখ দেখায়', difficulty: SpellingDifficulty.hard, category: 'objects'),
    SpellingWord(wordEn: 'television', wordBn: 'টেলিভিশন', hintEn: 'Watch shows on it', hintBn: 'অনুষ্ঠান দেখি', difficulty: SpellingDifficulty.hard, category: 'objects'),
    
    // Nature
    SpellingWord(wordEn: 'rainbow', wordBn: 'রংধনু', hintEn: 'Colorful arc in sky', hintBn: 'আকাশে রঙিন বাঁকা', difficulty: SpellingDifficulty.hard, category: 'nature'),
    SpellingWord(wordEn: 'mountain', wordBn: 'পাহাড়', hintEn: 'Very tall land', hintBn: 'অনেক উঁচু জমি', difficulty: SpellingDifficulty.hard, category: 'nature'),
    SpellingWord(wordEn: 'waterfall', wordBn: 'জলপ্রপাত', hintEn: 'Water falls from high', hintBn: 'উঁচু থেকে পানি পড়ে', difficulty: SpellingDifficulty.hard, category: 'nature'),
    SpellingWord(wordEn: 'sunshine', wordBn: 'রোদ', hintEn: 'Light from sun', hintBn: 'সূর্যের আলো', difficulty: SpellingDifficulty.hard, category: 'nature'),
    SpellingWord(wordEn: 'lightning', wordBn: 'বিদ্যুৎ', hintEn: 'Flash in storm', hintBn: 'ঝড়ে ঝলকায়', difficulty: SpellingDifficulty.hard, category: 'nature'),
    
    // Food
    SpellingWord(wordEn: 'chocolate', wordBn: 'চকলেট', hintEn: 'Sweet brown candy', hintBn: 'মিষ্টি বাদামী খাবার', difficulty: SpellingDifficulty.hard, category: 'food'),
    SpellingWord(wordEn: 'sandwich', wordBn: 'স্যান্ডউইচ', hintEn: 'Bread with filling', hintBn: 'রুটির মাঝে খাবার', difficulty: SpellingDifficulty.hard, category: 'food'),
    SpellingWord(wordEn: 'pineapple', wordBn: 'আনারস', hintEn: 'Spiky tropical fruit', hintBn: 'কাঁটাওয়ালা ফল', difficulty: SpellingDifficulty.hard, category: 'food'),
    SpellingWord(wordEn: 'strawberry', wordBn: 'স্ট্রবেরি', hintEn: 'Small red fruit', hintBn: 'ছোট লাল ফল', difficulty: SpellingDifficulty.hard, category: 'food'),
    SpellingWord(wordEn: 'vegetable', wordBn: 'সবজি', hintEn: 'Healthy plant food', hintBn: 'স্বাস্থ্যকর খাবার', difficulty: SpellingDifficulty.hard, category: 'food'),
  ];

  static List<SpellingWord> getWordsByDifficulty(SpellingDifficulty difficulty) {
    switch (difficulty) {
      case SpellingDifficulty.easy:
        return easyWords;
      case SpellingDifficulty.medium:
        return mediumWords;
      case SpellingDifficulty.hard:
        return hardWords;
    }
  }

  static List<SpellingWord> get allWords => [...easyWords, ...mediumWords, ...hardWords];
}
