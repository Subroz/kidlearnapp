class Letter {
  final String id;
  final String letter;
  final String pronunciation;
  final String type; // vowel or consonant
  final List<ExampleWord> examples;

  Letter({
    required this.id,
    required this.letter,
    required this.pronunciation,
    required this.type,
    required this.examples,
  });

  factory Letter.fromJson(Map<String, dynamic> json) {
    return Letter(
      id: json['id'] ?? '',
      letter: json['letter'] ?? '',
      pronunciation: json['pronunciation'] ?? '',
      type: json['type'] ?? 'consonant',
      examples: (json['examples'] as List?)
              ?.map((e) => ExampleWord.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ExampleWord {
  final String word;
  final String meaning;
  final String? pronunciation;

  ExampleWord({
    required this.word,
    required this.meaning,
    this.pronunciation,
  });

  factory ExampleWord.fromJson(Map<String, dynamic> json) {
    return ExampleWord(
      word: json['word'] ?? '',
      meaning: json['meaning'] ?? '',
      pronunciation: json['pronunciation'],
    );
  }
}

// English Alphabet Data
class EnglishAlphabetData {
  static final List<Letter> letters = [
    // Vowels
    Letter(
      id: 'A',
      letter: 'A',
      pronunciation: 'ei',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'Apple', meaning: 'A round fruit'),
        ExampleWord(word: 'Ant', meaning: 'A small insect'),
        ExampleWord(word: 'Airplane', meaning: 'A flying vehicle'),
      ],
    ),
    Letter(
      id: 'B',
      letter: 'B',
      pronunciation: 'bee',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Ball', meaning: 'A round toy'),
        ExampleWord(word: 'Bird', meaning: 'A flying animal'),
        ExampleWord(word: 'Banana', meaning: 'A yellow fruit'),
      ],
    ),
    Letter(
      id: 'C',
      letter: 'C',
      pronunciation: 'see',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Cat', meaning: 'A pet animal'),
        ExampleWord(word: 'Car', meaning: 'A vehicle'),
        ExampleWord(word: 'Cake', meaning: 'A sweet food'),
      ],
    ),
    Letter(
      id: 'D',
      letter: 'D',
      pronunciation: 'dee',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Dog', meaning: 'A pet animal'),
        ExampleWord(word: 'Duck', meaning: 'A water bird'),
        ExampleWord(word: 'Door', meaning: 'Entry to a room'),
      ],
    ),
    Letter(
      id: 'E',
      letter: 'E',
      pronunciation: 'e',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'Elephant', meaning: 'A big animal'),
        ExampleWord(word: 'Egg', meaning: 'Bird\'s baby comes from this'),
        ExampleWord(word: 'Eye', meaning: 'We see with this'),
      ],
    ),
    Letter(
      id: 'F',
      letter: 'F',
      pronunciation: 'eff',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Fish', meaning: 'Lives in water'),
        ExampleWord(word: 'Flower', meaning: 'A beautiful plant part'),
        ExampleWord(word: 'Frog', meaning: 'Jumps and says ribbit'),
      ],
    ),
    Letter(
      id: 'G',
      letter: 'G',
      pronunciation: 'jee',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Goat', meaning: 'An animal with horns'),
        ExampleWord(word: 'Grapes', meaning: 'Small round fruits'),
        ExampleWord(word: 'Girl', meaning: 'A female child'),
      ],
    ),
    Letter(
      id: 'H',
      letter: 'H',
      pronunciation: 'aitch',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'House', meaning: 'We live here'),
        ExampleWord(word: 'Horse', meaning: 'An animal we ride'),
        ExampleWord(word: 'Hat', meaning: 'We wear on head'),
      ],
    ),
    Letter(
      id: 'I',
      letter: 'I',
      pronunciation: 'ai',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'Ice cream', meaning: 'A cold sweet'),
        ExampleWord(word: 'Igloo', meaning: 'Ice house'),
        ExampleWord(word: 'Island', meaning: 'Land in water'),
      ],
    ),
    Letter(
      id: 'J',
      letter: 'J',
      pronunciation: 'jay',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Juice', meaning: 'A fruit drink'),
        ExampleWord(word: 'Jam', meaning: 'Sweet spread'),
        ExampleWord(word: 'Jelly', meaning: 'A wobbly sweet'),
      ],
    ),
    Letter(
      id: 'K',
      letter: 'K',
      pronunciation: 'kay',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Kite', meaning: 'Flies in the sky'),
        ExampleWord(word: 'King', meaning: 'A royal ruler'),
        ExampleWord(word: 'Key', meaning: 'Opens a lock'),
      ],
    ),
    Letter(
      id: 'L',
      letter: 'L',
      pronunciation: 'ell',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Lion', meaning: 'King of the jungle'),
        ExampleWord(word: 'Leaf', meaning: 'Part of a tree'),
        ExampleWord(word: 'Lamp', meaning: 'Gives us light'),
      ],
    ),
    Letter(
      id: 'M',
      letter: 'M',
      pronunciation: 'em',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Moon', meaning: 'Shines at night'),
        ExampleWord(word: 'Monkey', meaning: 'Swings on trees'),
        ExampleWord(word: 'Milk', meaning: 'A white drink'),
      ],
    ),
    Letter(
      id: 'N',
      letter: 'N',
      pronunciation: 'en',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Nest', meaning: 'Bird\'s home'),
        ExampleWord(word: 'Nose', meaning: 'We smell with this'),
        ExampleWord(word: 'Night', meaning: 'When it\'s dark'),
      ],
    ),
    Letter(
      id: 'O',
      letter: 'O',
      pronunciation: 'oh',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'Orange', meaning: 'A citrus fruit'),
        ExampleWord(word: 'Owl', meaning: 'A night bird'),
        ExampleWord(word: 'Ocean', meaning: 'A big sea'),
      ],
    ),
    Letter(
      id: 'P',
      letter: 'P',
      pronunciation: 'pee',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Penguin', meaning: 'A bird that swims'),
        ExampleWord(word: 'Pizza', meaning: 'A yummy food'),
        ExampleWord(word: 'Pencil', meaning: 'We write with this'),
      ],
    ),
    Letter(
      id: 'Q',
      letter: 'Q',
      pronunciation: 'cue',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Queen', meaning: 'A royal lady'),
        ExampleWord(word: 'Question', meaning: 'What we ask'),
        ExampleWord(word: 'Quilt', meaning: 'A warm blanket'),
      ],
    ),
    Letter(
      id: 'R',
      letter: 'R',
      pronunciation: 'are',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Rainbow', meaning: 'Colors in the sky'),
        ExampleWord(word: 'Rabbit', meaning: 'A hopping animal'),
        ExampleWord(word: 'Rose', meaning: 'A beautiful flower'),
      ],
    ),
    Letter(
      id: 'S',
      letter: 'S',
      pronunciation: 'ess',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Sun', meaning: 'Gives us light'),
        ExampleWord(word: 'Star', meaning: 'Twinkles at night'),
        ExampleWord(word: 'Snake', meaning: 'A long reptile'),
      ],
    ),
    Letter(
      id: 'T',
      letter: 'T',
      pronunciation: 'tee',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Tiger', meaning: 'A striped big cat'),
        ExampleWord(word: 'Tree', meaning: 'A tall plant'),
        ExampleWord(word: 'Train', meaning: 'Runs on tracks'),
      ],
    ),
    Letter(
      id: 'U',
      letter: 'U',
      pronunciation: 'you',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'Umbrella', meaning: 'Keeps us dry'),
        ExampleWord(word: 'Unicorn', meaning: 'A magical horse'),
        ExampleWord(word: 'Uniform', meaning: 'School clothes'),
      ],
    ),
    Letter(
      id: 'V',
      letter: 'V',
      pronunciation: 'vee',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Violin', meaning: 'A musical instrument'),
        ExampleWord(word: 'Van', meaning: 'A big car'),
        ExampleWord(word: 'Vegetable', meaning: 'Healthy food'),
      ],
    ),
    Letter(
      id: 'W',
      letter: 'W',
      pronunciation: 'double-you',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Water', meaning: 'We drink this'),
        ExampleWord(word: 'Watch', meaning: 'Tells the time'),
        ExampleWord(word: 'Whale', meaning: 'A big sea animal'),
      ],
    ),
    Letter(
      id: 'X',
      letter: 'X',
      pronunciation: 'ex',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'X-ray', meaning: 'Sees inside body'),
        ExampleWord(word: 'Xylophone', meaning: 'A musical toy'),
        ExampleWord(word: 'Box', meaning: 'We put things in'),
      ],
    ),
    Letter(
      id: 'Y',
      letter: 'Y',
      pronunciation: 'why',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Yellow', meaning: 'A bright color'),
        ExampleWord(word: 'Yak', meaning: 'A hairy animal'),
        ExampleWord(word: 'Yo-yo', meaning: 'A spinning toy'),
      ],
    ),
    Letter(
      id: 'Z',
      letter: 'Z',
      pronunciation: 'zee',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Zebra', meaning: 'A striped animal'),
        ExampleWord(word: 'Zoo', meaning: 'Animals live here'),
        ExampleWord(word: 'Zero', meaning: 'The number 0'),
      ],
    ),
  ];
}

// Bangla Alphabet Data
class BanglaAlphabetData {
  static final List<Letter> swarabarna = [
    // Vowels (স্বরবর্ণ)
    Letter(
      id: 'অ',
      letter: 'অ',
      pronunciation: 'শ্বরেঅ',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'অজগর', meaning: 'Python'),
        ExampleWord(word: 'অনেক', meaning: 'Many'),
      ],
    ),
    Letter(
      id: 'আ',
      letter: 'আ',
      pronunciation: 'শ্বরেআ',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'আম', meaning: 'Mango'),
        ExampleWord(word: 'আকাশ', meaning: 'Sky'),
      ],
    ),
    Letter(
      id: 'ই',
      letter: 'ই',
      pronunciation: 'রশইই',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'ইলিশ', meaning: 'Hilsa fish'),
        ExampleWord(word: 'ইট', meaning: 'Brick'),
      ],
    ),
    Letter(
      id: 'ঈ',
      letter: 'ঈ',
      pronunciation: 'দীর্ঘ ঈ',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'ঈগল', meaning: 'Eagle'),
        ExampleWord(word: 'ঈদ', meaning: 'Eid'),
      ],
    ),
    Letter(
      id: 'উ',
      letter: 'উ',
      pronunciation: 'রশশউ',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'উট', meaning: 'Camel'),
        ExampleWord(word: 'উড়ি', meaning: 'Fly'),
      ],
    ),
    Letter(
      id: 'ঊ',
      letter: 'ঊ',
      pronunciation: 'দীর্ঘ ঊ',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'ঊনিশ', meaning: 'Nineteen'),
        ExampleWord(word: 'ঊষা', meaning: 'Dawn'),
      ],
    ),
    Letter(
      id: 'ঋ',
      letter: 'ঋ',
      pronunciation: 'ঋ',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'ঋতু', meaning: 'Season'),
        ExampleWord(word: 'ঋষি', meaning: 'Sage'),
      ],
    ),
    Letter(
      id: 'এ',
      letter: 'এ',
      pronunciation: 'a',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'একতা', meaning: 'Unity'),
        ExampleWord(word: 'এখন', meaning: 'Now'),
      ],
    ),
    Letter(
      id: 'ঐ',
      letter: 'ঐ',
      pronunciation: 'ঐ',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'ঐক্য', meaning: 'Harmony'),
      ],
    ),
    Letter(
      id: 'ও',
      letter: 'ও',
      pronunciation: 'ও_ও',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'ওল', meaning: 'Yam'),
        ExampleWord(word: 'ওড়না', meaning: 'Scarf'),
      ],
    ),
    Letter(
      id: 'ঔ',
      letter: 'ঔ',
      pronunciation: 'ঔ',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'ঔষধ', meaning: 'Medicine'),
      ],
    ),
  ];

  static final List<Letter> byanjanbarna = [
    // Consonants (ব্যঞ্জনবর্ণ)
    Letter(
      id: 'ক',
      letter: 'ক',
      pronunciation: 'ক',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'কলম', meaning: 'Pen'),
        ExampleWord(word: 'কাক', meaning: 'Crow'),
      ],
    ),
    Letter(
      id: 'খ',
      letter: 'খ',
      pronunciation: 'খ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'খরগোশ', meaning: 'Rabbit'),
        ExampleWord(word: 'খাবার', meaning: 'Food'),
      ],
    ),
    Letter(
      id: 'গ',
      letter: 'গ',
      pronunciation: 'গ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'গরু', meaning: 'Cow'),
        ExampleWord(word: 'গাছ', meaning: 'Tree'),
      ],
    ),
    Letter(
      id: 'ঘ',
      letter: 'ঘ',
      pronunciation: 'ঘ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'ঘড়ি', meaning: 'Clock'),
        ExampleWord(word: 'ঘোড়া', meaning: 'Horse'),
      ],
    ),
    Letter(
      id: 'ঙ',
      letter: 'ঙ',
      pronunciation: 'ঙ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'বাঙালি', meaning: 'Bengali'),
      ],
    ),
    Letter(
      id: 'চ',
      letter: 'চ',
      pronunciation: 'চ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'চাঁদ', meaning: 'Moon'),
        ExampleWord(word: 'চোখ', meaning: 'Eye'),
      ],
    ),
    Letter(
      id: 'ছ',
      letter: 'ছ',
      pronunciation: 'ছ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'ছবি', meaning: 'Picture'),
        ExampleWord(word: 'ছাতা', meaning: 'Umbrella'),
      ],
    ),
    Letter(
      id: 'জ',
      letter: 'জ',
      pronunciation: 'জ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'জল', meaning: 'Water'),
        ExampleWord(word: 'জামা', meaning: 'Shirt'),
      ],
    ),
    Letter(
      id: 'ঝ',
      letter: 'ঝ',
      pronunciation: 'ঝ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'ঝরনা', meaning: 'Waterfall'),
      ],
    ),
    Letter(
      id: 'ট',
      letter: 'ট',
      pronunciation: 'ট',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'টমেটো', meaning: 'Tomato'),
        ExampleWord(word: 'টাকা', meaning: 'Money'),
      ],
    ),
    Letter(
      id: 'ঠ',
      letter: 'ঠ',
      pronunciation: 'ঠ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'ঠোঁট', meaning: 'Lips'),
      ],
    ),
    Letter(
      id: 'ড',
      letter: 'ড',
      pronunciation: 'ড',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'ডাল', meaning: 'Lentils'),
        ExampleWord(word: 'ডিম', meaning: 'Egg'),
      ],
    ),
    Letter(
      id: 'ঢ',
      letter: 'ঢ',
      pronunciation: 'ঢ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'ঢোল', meaning: 'Drum'),
      ],
    ),
    Letter(
      id: 'ণ',
      letter: 'ণ',
      pronunciation: 'ণ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'রামায়ণ', meaning: 'Ramayana'),
      ],
    ),
    Letter(
      id: 'ত',
      letter: 'ত',
      pronunciation: 'ত',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'তারা', meaning: 'Star'),
        ExampleWord(word: 'তবলা', meaning: 'Tabla'),
      ],
    ),
    Letter(
      id: 'থ',
      letter: 'থ',
      pronunciation: 'থ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'থালা', meaning: 'Plate'),
      ],
    ),
    Letter(
      id: 'দ',
      letter: 'দ',
      pronunciation: 'দ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'দই', meaning: 'Yogurt'),
        ExampleWord(word: 'দরজা', meaning: 'Door'),
      ],
    ),
    Letter(
      id: 'ধ',
      letter: 'ধ',
      pronunciation: 'ধ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'ধান', meaning: 'Rice plant'),
      ],
    ),
    Letter(
      id: 'ন',
      letter: 'ন',
      pronunciation: 'ন',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'নদী', meaning: 'River'),
        ExampleWord(word: 'নাক', meaning: 'Nose'),
      ],
    ),
    Letter(
      id: 'প',
      letter: 'প',
      pronunciation: 'প',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'পাখি', meaning: 'Bird'),
        ExampleWord(word: 'পানি', meaning: 'Water'),
      ],
    ),
    Letter(
      id: 'ফ',
      letter: 'ফ',
      pronunciation: 'ফ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'ফুল', meaning: 'Flower'),
        ExampleWord(word: 'ফল', meaning: 'Fruit'),
      ],
    ),
    Letter(
      id: 'ব',
      letter: 'ব',
      pronunciation: 'ব',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'বই', meaning: 'Book'),
        ExampleWord(word: 'বাঘ', meaning: 'Tiger'),
      ],
    ),
    Letter(
      id: 'ভ',
      letter: 'ভ',
      pronunciation: 'ভ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'ভালুক', meaning: 'Bear'),
      ],
    ),
    Letter(
      id: 'ম',
      letter: 'ম',
      pronunciation: 'ম',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'মাছ', meaning: 'Fish'),
        ExampleWord(word: 'মা', meaning: 'Mother'),
      ],
    ),
    Letter(
      id: 'য',
      letter: 'য',
      pronunciation: 'য',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'যাত্রা', meaning: 'Journey'),
      ],
    ),
    Letter(
      id: 'র',
      letter: 'র',
      pronunciation: 'র',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'রাজা', meaning: 'King'),
        ExampleWord(word: 'রং', meaning: 'Color'),
      ],
    ),
    Letter(
      id: 'ল',
      letter: 'ল',
      pronunciation: 'ল',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'লাল', meaning: 'Red'),
        ExampleWord(word: 'লেবু', meaning: 'Lemon'),
      ],
    ),
    Letter(
      id: 'শ',
      letter: 'শ',
      pronunciation: 'শ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'শিশু', meaning: 'Child'),
      ],
    ),
    Letter(
      id: 'ষ',
      letter: 'ষ',
      pronunciation: 'ষ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'ষাঁড়', meaning: 'Bull'),
      ],
    ),
    Letter(
      id: 'স',
      letter: 'স',
      pronunciation: 'স',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'সূর্য', meaning: 'Sun'),
        ExampleWord(word: 'সাপ', meaning: 'Snake'),
      ],
    ),
    Letter(
      id: 'হ',
      letter: 'হ',
      pronunciation: 'হ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'হাতি', meaning: 'Elephant'),
        ExampleWord(word: 'হাত', meaning: 'Hand'),
      ],
    ),
  ];

  static List<Letter> get allLetters => [...swarabarna, ...byanjanbarna];
}
