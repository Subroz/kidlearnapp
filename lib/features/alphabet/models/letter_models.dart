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
  final String emoji;
  final String sentence;

  ExampleWord({
    required this.word,
    required this.meaning,
    this.pronunciation,
    this.emoji = '',
    this.sentence = '',
  });

  factory ExampleWord.fromJson(Map<String, dynamic> json) {
    return ExampleWord(
      word: json['word'] ?? '',
      meaning: json['meaning'] ?? '',
      pronunciation: json['pronunciation'],
      emoji: json['emoji'] ?? '',
      sentence: json['sentence'] ?? '',
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
        ExampleWord(word: 'Apple', meaning: 'A round fruit', emoji: '🍎', sentence: 'I eat a red apple.'),
        ExampleWord(word: 'Ant', meaning: 'A small insect', emoji: '🐜', sentence: 'The ant is very small.'),
        ExampleWord(word: 'Airplane', meaning: 'A flying vehicle', emoji: '✈️', sentence: 'The airplane flies high.'),
      ],
    ),
    Letter(
      id: 'B',
      letter: 'B',
      pronunciation: 'bee',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Ball', meaning: 'A round toy', emoji: '⚽', sentence: 'I play with a ball.'),
        ExampleWord(word: 'Bird', meaning: 'A flying animal', emoji: '🐦', sentence: 'The bird sings a song.'),
        ExampleWord(word: 'Banana', meaning: 'A yellow fruit', emoji: '🍌', sentence: 'I like to eat banana.'),
      ],
    ),
    Letter(
      id: 'C',
      letter: 'C',
      pronunciation: 'see',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Cat', meaning: 'A pet animal', emoji: '🐱', sentence: 'The cat drinks milk.'),
        ExampleWord(word: 'Car', meaning: 'A vehicle', emoji: '🚗', sentence: 'The car goes fast.'),
        ExampleWord(word: 'Cake', meaning: 'A sweet food', emoji: '🎂', sentence: 'We eat cake on birthdays.'),
      ],
    ),
    Letter(
      id: 'D',
      letter: 'D',
      pronunciation: 'dee',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Dog', meaning: 'A pet animal', emoji: '🐶', sentence: 'The dog wags its tail.'),
        ExampleWord(word: 'Duck', meaning: 'A water bird', emoji: '🦆', sentence: 'The duck swims in the pond.'),
        ExampleWord(word: 'Door', meaning: 'Entry to a room', emoji: '🚪', sentence: 'Please open the door.'),
      ],
    ),
    Letter(
      id: 'E',
      letter: 'E',
      pronunciation: 'e',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'Elephant', meaning: 'A big animal', emoji: '🐘', sentence: 'The elephant is very big.'),
        ExampleWord(word: 'Egg', meaning: 'Bird\'s baby comes from this', emoji: '🥚', sentence: 'I eat an egg for breakfast.'),
        ExampleWord(word: 'Eye', meaning: 'We see with this', emoji: '👁️', sentence: 'I can see with my eye.'),
      ],
    ),
    Letter(
      id: 'F',
      letter: 'F',
      pronunciation: 'eff',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Fish', meaning: 'Lives in water', emoji: '🐟', sentence: 'The fish lives in water.'),
        ExampleWord(word: 'Flower', meaning: 'A beautiful plant part', emoji: '🌸', sentence: 'The flower smells nice.'),
        ExampleWord(word: 'Frog', meaning: 'Jumps and says ribbit', emoji: '🐸', sentence: 'The frog jumps high.'),
      ],
    ),
    Letter(
      id: 'G',
      letter: 'G',
      pronunciation: 'jee',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Goat', meaning: 'An animal with horns', emoji: '🐐', sentence: 'The goat eats grass.'),
        ExampleWord(word: 'Grapes', meaning: 'Small round fruits', emoji: '🍇', sentence: 'I like to eat grapes.'),
        ExampleWord(word: 'Girl', meaning: 'A female child', emoji: '👧', sentence: 'The girl reads a book.'),
      ],
    ),
    Letter(
      id: 'H',
      letter: 'H',
      pronunciation: 'aitch',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'House', meaning: 'We live here', emoji: '🏠', sentence: 'I live in a house.'),
        ExampleWord(word: 'Horse', meaning: 'An animal we ride', emoji: '🐴', sentence: 'The horse runs fast.'),
        ExampleWord(word: 'Hat', meaning: 'We wear on head', emoji: '🎩', sentence: 'I wear a hat on my head.'),
      ],
    ),
    Letter(
      id: 'I',
      letter: 'I',
      pronunciation: 'ai',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'Ice cream', meaning: 'A cold sweet', emoji: '🍦', sentence: 'I love ice cream.'),
        ExampleWord(word: 'Igloo', meaning: 'Ice house', emoji: '🏔️', sentence: 'An igloo is made of ice.'),
        ExampleWord(word: 'Island', meaning: 'Land in water', emoji: '🏝️', sentence: 'The island is in the sea.'),
      ],
    ),
    Letter(
      id: 'J',
      letter: 'J',
      pronunciation: 'jay',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Juice', meaning: 'A fruit drink', emoji: '🧃', sentence: 'I drink orange juice.'),
        ExampleWord(word: 'Jam', meaning: 'Sweet spread', emoji: '🫙', sentence: 'I put jam on bread.'),
        ExampleWord(word: 'Jelly', meaning: 'A wobbly sweet', emoji: '🍮', sentence: 'The jelly is wobbly.'),
      ],
    ),
    Letter(
      id: 'K',
      letter: 'K',
      pronunciation: 'kay',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Kite', meaning: 'Flies in the sky', emoji: '🪁', sentence: 'I fly a kite in the wind.'),
        ExampleWord(word: 'King', meaning: 'A royal ruler', emoji: '👑', sentence: 'The king wears a crown.'),
        ExampleWord(word: 'Key', meaning: 'Opens a lock', emoji: '🔑', sentence: 'The key opens the lock.'),
      ],
    ),
    Letter(
      id: 'L',
      letter: 'L',
      pronunciation: 'ell',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Lion', meaning: 'King of the jungle', emoji: '🦁', sentence: 'The lion roars loudly.'),
        ExampleWord(word: 'Leaf', meaning: 'Part of a tree', emoji: '🍃', sentence: 'The leaf falls from the tree.'),
        ExampleWord(word: 'Lamp', meaning: 'Gives us light', emoji: '💡', sentence: 'The lamp gives us light.'),
      ],
    ),
    Letter(
      id: 'M',
      letter: 'M',
      pronunciation: 'em',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Moon', meaning: 'Shines at night', emoji: '🌙', sentence: 'The moon shines at night.'),
        ExampleWord(word: 'Monkey', meaning: 'Swings on trees', emoji: '🐒', sentence: 'The monkey swings on trees.'),
        ExampleWord(word: 'Milk', meaning: 'A white drink', emoji: '🥛', sentence: 'I drink milk every day.'),
      ],
    ),
    Letter(
      id: 'N',
      letter: 'N',
      pronunciation: 'en',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Nest', meaning: 'Bird\'s home', emoji: '🪺', sentence: 'The bird lives in a nest.'),
        ExampleWord(word: 'Nose', meaning: 'We smell with this', emoji: '👃', sentence: 'I smell with my nose.'),
        ExampleWord(word: 'Night', meaning: 'When it\'s dark', emoji: '🌃', sentence: 'Stars come out at night.'),
      ],
    ),
    Letter(
      id: 'O',
      letter: 'O',
      pronunciation: 'oh',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'Orange', meaning: 'A citrus fruit', emoji: '🍊', sentence: 'The orange is sweet.'),
        ExampleWord(word: 'Owl', meaning: 'A night bird', emoji: '🦉', sentence: 'The owl hoots at night.'),
        ExampleWord(word: 'Ocean', meaning: 'A big sea', emoji: '🌊', sentence: 'The ocean has big waves.'),
      ],
    ),
    Letter(
      id: 'P',
      letter: 'P',
      pronunciation: 'pee',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Penguin', meaning: 'A bird that swims', emoji: '🐧', sentence: 'The penguin walks on ice.'),
        ExampleWord(word: 'Pizza', meaning: 'A yummy food', emoji: '🍕', sentence: 'I love eating pizza.'),
        ExampleWord(word: 'Pencil', meaning: 'We write with this', emoji: '✏️', sentence: 'I write with a pencil.'),
      ],
    ),
    Letter(
      id: 'Q',
      letter: 'Q',
      pronunciation: 'cue',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Queen', meaning: 'A royal lady', emoji: '👸', sentence: 'The queen lives in a castle.'),
        ExampleWord(word: 'Question', meaning: 'What we ask', emoji: '❓', sentence: 'I ask a question to learn.'),
        ExampleWord(word: 'Quilt', meaning: 'A warm blanket', emoji: '🛏️', sentence: 'The quilt keeps me warm.'),
      ],
    ),
    Letter(
      id: 'R',
      letter: 'R',
      pronunciation: 'are',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Rainbow', meaning: 'Colors in the sky', emoji: '🌈', sentence: 'The rainbow has many colors.'),
        ExampleWord(word: 'Rabbit', meaning: 'A hopping animal', emoji: '🐰', sentence: 'The rabbit hops around.'),
        ExampleWord(word: 'Rose', meaning: 'A beautiful flower', emoji: '🌹', sentence: 'The rose is red.'),
      ],
    ),
    Letter(
      id: 'S',
      letter: 'S',
      pronunciation: 'ess',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Sun', meaning: 'Gives us light', emoji: '☀️', sentence: 'The sun gives us light.'),
        ExampleWord(word: 'Star', meaning: 'Twinkles at night', emoji: '⭐', sentence: 'The star twinkles at night.'),
        ExampleWord(word: 'Snake', meaning: 'A long reptile', emoji: '🐍', sentence: 'The snake is very long.'),
      ],
    ),
    Letter(
      id: 'T',
      letter: 'T',
      pronunciation: 'tee',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Tiger', meaning: 'A striped big cat', emoji: '🐯', sentence: 'The tiger has stripes.'),
        ExampleWord(word: 'Tree', meaning: 'A tall plant', emoji: '🌳', sentence: 'The tree gives us shade.'),
        ExampleWord(word: 'Train', meaning: 'Runs on tracks', emoji: '🚂', sentence: 'The train runs on tracks.'),
      ],
    ),
    Letter(
      id: 'U',
      letter: 'U',
      pronunciation: 'you',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'Umbrella', meaning: 'Keeps us dry', emoji: '☂️', sentence: 'The umbrella keeps me dry.'),
        ExampleWord(word: 'Unicorn', meaning: 'A magical horse', emoji: '🦄', sentence: 'The unicorn is magical.'),
        ExampleWord(word: 'Uniform', meaning: 'School clothes', emoji: '👔', sentence: 'I wear uniform to school.'),
      ],
    ),
    Letter(
      id: 'V',
      letter: 'V',
      pronunciation: 'vee',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Violin', meaning: 'A musical instrument', emoji: '🎻', sentence: 'She plays the violin.'),
        ExampleWord(word: 'Van', meaning: 'A big car', emoji: '🚐', sentence: 'The van carries things.'),
        ExampleWord(word: 'Vegetable', meaning: 'Healthy food', emoji: '🥦', sentence: 'Vegetables are good for health.'),
      ],
    ),
    Letter(
      id: 'W',
      letter: 'W',
      pronunciation: 'double-you',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Water', meaning: 'We drink this', emoji: '💧', sentence: 'I drink water every day.'),
        ExampleWord(word: 'Watch', meaning: 'Tells the time', emoji: '⌚', sentence: 'The watch tells the time.'),
        ExampleWord(word: 'Whale', meaning: 'A big sea animal', emoji: '🐋', sentence: 'The whale is very big.'),
      ],
    ),
    Letter(
      id: 'X',
      letter: 'X',
      pronunciation: 'ex',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'X-ray', meaning: 'Sees inside body', emoji: '🩻', sentence: 'The x-ray shows my bones.'),
        ExampleWord(word: 'Xylophone', meaning: 'A musical toy', emoji: '🎵', sentence: 'I play the xylophone.'),
        ExampleWord(word: 'Box', meaning: 'We put things in', emoji: '📦', sentence: 'I put toys in the box.'),
      ],
    ),
    Letter(
      id: 'Y',
      letter: 'Y',
      pronunciation: 'why',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Yellow', meaning: 'A bright color', emoji: '💛', sentence: 'Yellow is a bright color.'),
        ExampleWord(word: 'Yak', meaning: 'A hairy animal', emoji: '🐂', sentence: 'The yak has long hair.'),
        ExampleWord(word: 'Yo-yo', meaning: 'A spinning toy', emoji: '🪀', sentence: 'The yo-yo goes up and down.'),
      ],
    ),
    Letter(
      id: 'Z',
      letter: 'Z',
      pronunciation: 'zee',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'Zebra', meaning: 'A striped animal', emoji: '🦓', sentence: 'The zebra has black and white stripes.'),
        ExampleWord(word: 'Zoo', meaning: 'Animals live here', emoji: '🦁', sentence: 'I see animals at the zoo.'),
        ExampleWord(word: 'Zero', meaning: 'The number 0', emoji: '0️⃣', sentence: 'Zero means nothing.'),
      ],
    ),
  ];
}

// Bangla Alphabet Data
class BanglaAlphabetData {
  static final List<Letter> swarabarna = [
    Letter(
      id: 'অ',
      letter: 'অ',
      pronunciation: 'শ্বরেঅ',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'অজগর', meaning: 'Python', emoji: '🐍', sentence: 'অজগর অনেক লম্বা সাপ।'),
        ExampleWord(word: 'অনেক', meaning: 'Many', emoji: '🌟', sentence: 'আকাশে অনেক তারা আছে।'),
      ],
    ),
    Letter(
      id: 'আ',
      letter: 'আ',
      pronunciation: 'শ্বরেআ',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'আম', meaning: 'Mango', emoji: '🥭', sentence: 'আম খেতে খুব মিষ্টি।'),
        ExampleWord(word: 'আকাশ', meaning: 'Sky', emoji: '🌤️', sentence: 'আকাশ নীল রঙের।'),
      ],
    ),
    Letter(
      id: 'ই',
      letter: 'ই',
      pronunciation: 'রশইই',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'ইলিশ', meaning: 'Hilsa fish', emoji: '🐟', sentence: 'ইলিশ মাছ খুব সুস্বাদু।'),
        ExampleWord(word: 'ইট', meaning: 'Brick', emoji: '🧱', sentence: 'ইট দিয়ে ঘর তৈরি হয়।'),
      ],
    ),
    Letter(
      id: 'ঈ',
      letter: 'ঈ',
      pronunciation: 'দীর্ঘ ঈ',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'ঈগল', meaning: 'Eagle', emoji: '🦅', sentence: 'ঈগল অনেক উঁচুতে ওড়ে।'),
        ExampleWord(word: 'ঈদ', meaning: 'Eid', emoji: '🌙', sentence: 'ঈদে আমরা সবাই খুশি।'),
      ],
    ),
    Letter(
      id: 'উ',
      letter: 'উ',
      pronunciation: 'রশশউ',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'উট', meaning: 'Camel', emoji: '🐫', sentence: 'উট মরুভূমিতে চলে।'),
        ExampleWord(word: 'উড়ি', meaning: 'Fly', emoji: '🕊️', sentence: 'পাখি আকাশে উড়ি দেয়।'),
      ],
    ),
    Letter(
      id: 'ঊ',
      letter: 'ঊ',
      pronunciation: 'দীর্ঘ ঊ',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'ঊনিশ', meaning: 'Nineteen', emoji: '🔢', sentence: 'ঊনিশ একটি সংখ্যা।'),
        ExampleWord(word: 'ঊষা', meaning: 'Dawn', emoji: '🌅', sentence: 'ঊষার আলো খুব সুন্দর।'),
      ],
    ),
    Letter(
      id: 'ঋ',
      letter: 'ঋ',
      pronunciation: 'ঋ',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'ঋতু', meaning: 'Season', emoji: '🍂', sentence: 'বাংলাদেশে ছয়টি ঋতু আছে।'),
        ExampleWord(word: 'ঋষি', meaning: 'Sage', emoji: '🧘', sentence: 'ঋষি ধ্যান করেন।'),
      ],
    ),
    Letter(
      id: 'এ',
      letter: 'এ',
      pronunciation: 'a',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'একতা', meaning: 'Unity', emoji: '🤝', sentence: 'একতাতেই শক্তি।'),
        ExampleWord(word: 'এখন', meaning: 'Now', emoji: '⏰', sentence: 'এখন পড়ার সময়।'),
      ],
    ),
    Letter(
      id: 'ঐ',
      letter: 'ঐ',
      pronunciation: 'ঐ',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'ঐক্য', meaning: 'Harmony', emoji: '🕊️', sentence: 'ঐক্যে অনেক শক্তি।'),
      ],
    ),
    Letter(
      id: 'ও',
      letter: 'ও',
      pronunciation: 'ও_ও',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'ওল', meaning: 'Yam', emoji: '🥔', sentence: 'ওল একটি সবজি।'),
        ExampleWord(word: 'ওড়না', meaning: 'Scarf', emoji: '🧣', sentence: 'মেয়েটি ওড়না পরে।'),
      ],
    ),
    Letter(
      id: 'ঔ',
      letter: 'ঔ',
      pronunciation: 'ঔ',
      type: 'vowel',
      examples: [
        ExampleWord(word: 'ঔষধ', meaning: 'Medicine', emoji: '💊', sentence: 'অসুখ হলে ঔষধ খাই।'),
      ],
    ),
  ];

  static final List<Letter> byanjanbarna = [
    Letter(
      id: 'ক',
      letter: 'ক',
      pronunciation: 'ক',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'কলম', meaning: 'Pen', emoji: '🖊️', sentence: 'আমি কলম দিয়ে লিখি।'),
        ExampleWord(word: 'কাক', meaning: 'Crow', emoji: '🐦‍⬛', sentence: 'কাক কা কা করে ডাকে।'),
      ],
    ),
    Letter(
      id: 'খ',
      letter: 'খ',
      pronunciation: 'খ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'খরগোশ', meaning: 'Rabbit', emoji: '🐰', sentence: 'খরগোশ লাফিয়ে চলে।'),
        ExampleWord(word: 'খাবার', meaning: 'Food', emoji: '🍛', sentence: 'মা সুন্দর খাবার রান্না করেন।'),
      ],
    ),
    Letter(
      id: 'গ',
      letter: 'গ',
      pronunciation: 'গ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'গরু', meaning: 'Cow', emoji: '🐄', sentence: 'গরু আমাদের দুধ দেয়।'),
        ExampleWord(word: 'গাছ', meaning: 'Tree', emoji: '🌳', sentence: 'গাছ আমাদের ফল দেয়।'),
      ],
    ),
    Letter(
      id: 'ঘ',
      letter: 'ঘ',
      pronunciation: 'ঘ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'ঘড়ি', meaning: 'Clock', emoji: '🕐', sentence: 'ঘড়ি দেখে সময় জানি।'),
        ExampleWord(word: 'ঘোড়া', meaning: 'Horse', emoji: '🐴', sentence: 'ঘোড়া খুব দ্রুত দৌড়ায়।'),
      ],
    ),
    Letter(
      id: 'ঙ',
      letter: 'ঙ',
      pronunciation: 'ঙ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'বাঙালি', meaning: 'Bengali', emoji: '🇧🇩', sentence: 'আমরা বাঙালি জাতি।'),
      ],
    ),
    Letter(
      id: 'চ',
      letter: 'চ',
      pronunciation: 'চ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'চাঁদ', meaning: 'Moon', emoji: '🌙', sentence: 'রাতে চাঁদ আলো দেয়।'),
        ExampleWord(word: 'চোখ', meaning: 'Eye', emoji: '👁️', sentence: 'চোখ দিয়ে আমরা দেখি।'),
      ],
    ),
    Letter(
      id: 'ছ',
      letter: 'ছ',
      pronunciation: 'ছ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'ছবি', meaning: 'Picture', emoji: '🖼️', sentence: 'আমি সুন্দর ছবি আঁকি।'),
        ExampleWord(word: 'ছাতা', meaning: 'Umbrella', emoji: '☂️', sentence: 'বৃষ্টিতে ছাতা ব্যবহার করি।'),
      ],
    ),
    Letter(
      id: 'জ',
      letter: 'জ',
      pronunciation: 'জ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'জল', meaning: 'Water', emoji: '💧', sentence: 'জল পান করা স্বাস্থ্যকর।'),
        ExampleWord(word: 'জামা', meaning: 'Shirt', emoji: '👕', sentence: 'আমি নতুন জামা পরি।'),
      ],
    ),
    Letter(
      id: 'ঝ',
      letter: 'ঝ',
      pronunciation: 'ঝ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'ঝরনা', meaning: 'Waterfall', emoji: '🏞️', sentence: 'ঝরনা থেকে জল পড়ে।'),
      ],
    ),
    Letter(
      id: 'ট',
      letter: 'ট',
      pronunciation: 'ট',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'টমেটো', meaning: 'Tomato', emoji: '🍅', sentence: 'টমেটো লাল রঙের।'),
        ExampleWord(word: 'টাকা', meaning: 'Money', emoji: '💰', sentence: 'জিনিস কিনতে টাকা লাগে।'),
      ],
    ),
    Letter(
      id: 'ঠ',
      letter: 'ঠ',
      pronunciation: 'ঠ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'ঠোঁট', meaning: 'Lips', emoji: '👄', sentence: 'ঠোঁট দিয়ে আমরা কথা বলি।'),
      ],
    ),
    Letter(
      id: 'ড',
      letter: 'ড',
      pronunciation: 'ড',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'ডাল', meaning: 'Lentils', emoji: '🥣', sentence: 'ভাতের সাথে ডাল খাই।'),
        ExampleWord(word: 'ডিম', meaning: 'Egg', emoji: '🥚', sentence: 'সকালে ডিম খাই।'),
      ],
    ),
    Letter(
      id: 'ঢ',
      letter: 'ঢ',
      pronunciation: 'ঢ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'ঢোল', meaning: 'Drum', emoji: '🥁', sentence: 'উৎসবে ঢোল বাজে।'),
      ],
    ),
    Letter(
      id: 'ণ',
      letter: 'ণ',
      pronunciation: 'ণ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'রামায়ণ', meaning: 'Ramayana', emoji: '📖', sentence: 'রামায়ণ একটি মহাকাব্য।'),
      ],
    ),
    Letter(
      id: 'ত',
      letter: 'ত',
      pronunciation: 'ত',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'তারা', meaning: 'Star', emoji: '⭐', sentence: 'রাতে আকাশে তারা জ্বলে।'),
        ExampleWord(word: 'তবলা', meaning: 'Tabla', emoji: '🪘', sentence: 'তবলা একটি বাদ্যযন্ত্র।'),
      ],
    ),
    Letter(
      id: 'থ',
      letter: 'থ',
      pronunciation: 'থ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'থালা', meaning: 'Plate', emoji: '🍽️', sentence: 'থালায় ভাত দাও।'),
      ],
    ),
    Letter(
      id: 'দ',
      letter: 'দ',
      pronunciation: 'দ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'দই', meaning: 'Yogurt', emoji: '🥛', sentence: 'দই খেতে টক লাগে।'),
        ExampleWord(word: 'দরজা', meaning: 'Door', emoji: '🚪', sentence: 'দরজা বন্ধ করো।'),
      ],
    ),
    Letter(
      id: 'ধ',
      letter: 'ধ',
      pronunciation: 'ধ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'ধান', meaning: 'Rice plant', emoji: '🌾', sentence: 'মাঠে ধান ফলে।'),
      ],
    ),
    Letter(
      id: 'ন',
      letter: 'ন',
      pronunciation: 'ন',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'নদী', meaning: 'River', emoji: '🏞️', sentence: 'নদীতে নৌকা চলে।'),
        ExampleWord(word: 'নাক', meaning: 'Nose', emoji: '👃', sentence: 'নাক দিয়ে গন্ধ পাই।'),
      ],
    ),
    Letter(
      id: 'প',
      letter: 'প',
      pronunciation: 'প',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'পাখি', meaning: 'Bird', emoji: '🐦', sentence: 'পাখি গান গায়।'),
        ExampleWord(word: 'পানি', meaning: 'Water', emoji: '💧', sentence: 'পানি পান করো।'),
      ],
    ),
    Letter(
      id: 'ফ',
      letter: 'ফ',
      pronunciation: 'ফ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'ফুল', meaning: 'Flower', emoji: '🌸', sentence: 'ফুল সুন্দর গন্ধ দেয়।'),
        ExampleWord(word: 'ফল', meaning: 'Fruit', emoji: '🍎', sentence: 'ফল খাওয়া স্বাস্থ্যকর।'),
      ],
    ),
    Letter(
      id: 'ব',
      letter: 'ব',
      pronunciation: 'ব',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'বই', meaning: 'Book', emoji: '📚', sentence: 'আমি বই পড়তে ভালোবাসি।'),
        ExampleWord(word: 'বাঘ', meaning: 'Tiger', emoji: '🐯', sentence: 'বাঘ বনে থাকে।'),
      ],
    ),
    Letter(
      id: 'ভ',
      letter: 'ভ',
      pronunciation: 'ভ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'ভালুক', meaning: 'Bear', emoji: '🐻', sentence: 'ভালুক মধু খায়।'),
      ],
    ),
    Letter(
      id: 'ম',
      letter: 'ম',
      pronunciation: 'ম',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'মাছ', meaning: 'Fish', emoji: '🐟', sentence: 'মাছ পানিতে সাঁতার কাটে।'),
        ExampleWord(word: 'মা', meaning: 'Mother', emoji: '👩', sentence: 'মা আমাকে ভালোবাসেন।'),
      ],
    ),
    Letter(
      id: 'য',
      letter: 'য',
      pronunciation: 'য',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'যাত্রা', meaning: 'Journey', emoji: '🚶', sentence: 'আমরা যাত্রা শুরু করি।'),
      ],
    ),
    Letter(
      id: 'র',
      letter: 'র',
      pronunciation: 'র',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'রাজা', meaning: 'King', emoji: '👑', sentence: 'রাজা মুকুট পরেন।'),
        ExampleWord(word: 'রং', meaning: 'Color', emoji: '🎨', sentence: 'আমি রং দিয়ে ছবি আঁকি।'),
      ],
    ),
    Letter(
      id: 'ল',
      letter: 'ল',
      pronunciation: 'ল',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'লাল', meaning: 'Red', emoji: '🔴', sentence: 'গোলাপ ফুল লাল।'),
        ExampleWord(word: 'লেবু', meaning: 'Lemon', emoji: '🍋', sentence: 'লেবু টক হয়।'),
      ],
    ),
    Letter(
      id: 'শ',
      letter: 'শ',
      pronunciation: 'শ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'শিশু', meaning: 'Child', emoji: '👶', sentence: 'শিশু হাসতে ভালোবাসে।'),
      ],
    ),
    Letter(
      id: 'ষ',
      letter: 'ষ',
      pronunciation: 'ষ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'ষাঁড়', meaning: 'Bull', emoji: '🐂', sentence: 'ষাঁড় অনেক শক্তিশালী।'),
      ],
    ),
    Letter(
      id: 'স',
      letter: 'স',
      pronunciation: 'স',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'সূর্য', meaning: 'Sun', emoji: '☀️', sentence: 'সূর্য আলো দেয়।'),
        ExampleWord(word: 'সাপ', meaning: 'Snake', emoji: '🐍', sentence: 'সাপ ঘাসে লুকিয়ে থাকে।'),
      ],
    ),
    Letter(
      id: 'হ',
      letter: 'হ',
      pronunciation: 'হ',
      type: 'consonant',
      examples: [
        ExampleWord(word: 'হাতি', meaning: 'Elephant', emoji: '🐘', sentence: 'হাতি অনেক বড়।'),
        ExampleWord(word: 'হাত', meaning: 'Hand', emoji: '✋', sentence: 'আমরা হাত দিয়ে কাজ করি।'),
      ],
    ),
  ];

  static List<Letter> get allLetters => [...swarabarna, ...byanjanbarna];
}
