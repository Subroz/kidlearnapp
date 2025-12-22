class WordCategory {
  final String id;
  final String nameEn;
  final String nameBn;
  final List<StoryWord> words;

  WordCategory({
    required this.id,
    required this.nameEn,
    required this.nameBn,
    required this.words,
  });
}

class StoryWord {
  final String wordEn;
  final String wordBn;

  StoryWord({
    required this.wordEn,
    required this.wordBn,
  });
}

class WordBankData {
  static final List<WordCategory> categories = [
    WordCategory(
      id: 'animals',
      nameEn: 'Animals',
      nameBn: 'পশুপাখি',
      words: [
        StoryWord(wordEn: 'Lion', wordBn: 'সিংহ'),
        StoryWord(wordEn: 'Rabbit', wordBn: 'খরগোশ'),
        StoryWord(wordEn: 'Elephant', wordBn: 'হাতি'),
        StoryWord(wordEn: 'Bird', wordBn: 'পাখি'),
        StoryWord(wordEn: 'Fish', wordBn: 'মাছ'),
        StoryWord(wordEn: 'Butterfly', wordBn: 'প্রজাপতি'),
        StoryWord(wordEn: 'Dog', wordBn: 'কুকুর'),
        StoryWord(wordEn: 'Cat', wordBn: 'বিড়াল'),
        StoryWord(wordEn: 'Tiger', wordBn: 'বাঘ'),
        StoryWord(wordEn: 'Monkey', wordBn: 'বানর'),
      ],
    ),
    WordCategory(
      id: 'objects',
      nameEn: 'Objects',
      nameBn: 'জিনিসপত্র',
      words: [
        StoryWord(wordEn: 'Book', wordBn: 'বই'),
        StoryWord(wordEn: 'Ball', wordBn: 'বল'),
        StoryWord(wordEn: 'Star', wordBn: 'তারা'),
        StoryWord(wordEn: 'Flower', wordBn: 'ফুল'),
        StoryWord(wordEn: 'Tree', wordBn: 'গাছ'),
        StoryWord(wordEn: 'House', wordBn: 'বাড়ি'),
        StoryWord(wordEn: 'Moon', wordBn: 'চাঁদ'),
        StoryWord(wordEn: 'Sun', wordBn: 'সূর্য'),
        StoryWord(wordEn: 'Rainbow', wordBn: 'রংধনু'),
        StoryWord(wordEn: 'Gift', wordBn: 'উপহার'),
      ],
    ),
    WordCategory(
      id: 'actions',
      nameEn: 'Actions',
      nameBn: 'কাজ',
      words: [
        StoryWord(wordEn: 'Run', wordBn: 'দৌড়ানো'),
        StoryWord(wordEn: 'Jump', wordBn: 'লাফানো'),
        StoryWord(wordEn: 'Fly', wordBn: 'উড়া'),
        StoryWord(wordEn: 'Sing', wordBn: 'গান গাওয়া'),
        StoryWord(wordEn: 'Dance', wordBn: 'নাচ'),
        StoryWord(wordEn: 'Play', wordBn: 'খেলা'),
        StoryWord(wordEn: 'Sleep', wordBn: 'ঘুমানো'),
        StoryWord(wordEn: 'Eat', wordBn: 'খাওয়া'),
        StoryWord(wordEn: 'Help', wordBn: 'সাহায্য করা'),
        StoryWord(wordEn: 'Learn', wordBn: 'শেখা'),
      ],
    ),
    WordCategory(
      id: 'places',
      nameEn: 'Places',
      nameBn: 'জায়গা',
      words: [
        StoryWord(wordEn: 'Forest', wordBn: 'বন'),
        StoryWord(wordEn: 'Garden', wordBn: 'বাগান'),
        StoryWord(wordEn: 'School', wordBn: 'স্কুল'),
        StoryWord(wordEn: 'River', wordBn: 'নদী'),
        StoryWord(wordEn: 'Mountain', wordBn: 'পাহাড়'),
        StoryWord(wordEn: 'Beach', wordBn: 'সমুদ্র সৈকত'),
        StoryWord(wordEn: 'Village', wordBn: 'গ্রাম'),
        StoryWord(wordEn: 'City', wordBn: 'শহর'),
      ],
    ),
    WordCategory(
      id: 'feelings',
      nameEn: 'Feelings',
      nameBn: 'অনুভূতি',
      words: [
        StoryWord(wordEn: 'Happy', wordBn: 'খুশি'),
        StoryWord(wordEn: 'Brave', wordBn: 'সাহসী'),
        StoryWord(wordEn: 'Kind', wordBn: 'দয়ালু'),
        StoryWord(wordEn: 'Curious', wordBn: 'কৌতূহলী'),
        StoryWord(wordEn: 'Excited', wordBn: 'উত্তেজিত'),
        StoryWord(wordEn: 'Peaceful', wordBn: 'শান্ত'),
        StoryWord(wordEn: 'Grateful', wordBn: 'কৃতজ্ঞ'),
        StoryWord(wordEn: 'Friendly', wordBn: 'বন্ধুত্বপূর্ণ'),
      ],
    ),
  ];
}
