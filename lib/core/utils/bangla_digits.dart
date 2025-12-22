class BanglaDigits {
  static const Map<String, String> _digitMap = {
    '0': '০',
    '1': '১',
    '2': '২',
    '3': '৩',
    '4': '৪',
    '5': '৫',
    '6': '৬',
    '7': '৭',
    '8': '৮',
    '9': '৯',
  };

  static const Map<String, String> _reverseDigitMap = {
    '০': '0',
    '১': '1',
    '২': '2',
    '৩': '3',
    '৪': '4',
    '৫': '5',
    '৬': '6',
    '৭': '7',
    '৮': '8',
    '৯': '9',
  };

  /// Converts English digits to Bangla digits
  static String toBangla(dynamic number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final char = str[i];
      buffer.write(_digitMap[char] ?? char);
    }
    return buffer.toString();
  }

  /// Converts Bangla digits to English digits
  static String toEnglish(String banglaNumber) {
    final buffer = StringBuffer();
    for (int i = 0; i < banglaNumber.length; i++) {
      final char = banglaNumber[i];
      buffer.write(_reverseDigitMap[char] ?? char);
    }
    return buffer.toString();
  }

  /// Converts Bangla digit string to int
  static int? parseInt(String banglaNumber) {
    final english = toEnglish(banglaNumber);
    return int.tryParse(english);
  }

  /// Get Bangla number word (1-100)
  static String getNumberWord(int number) {
    const words = {
      0: 'শূন্য',
      1: 'এক',
      2: 'দুই',
      3: 'তিন',
      4: 'চার',
      5: 'পাঁচ',
      6: 'ছয়',
      7: 'সাত',
      8: 'আট',
      9: 'নয়',
      10: 'দশ',
      11: 'এগারো',
      12: 'বারো',
      13: 'তেরো',
      14: 'চৌদ্দ',
      15: 'পনেরো',
      16: 'ষোল',
      17: 'সতেরো',
      18: 'আঠারো',
      19: 'উনিশ',
      20: 'বিশ',
      21: 'একুশ',
      22: 'বাইশ',
      23: 'তেইশ',
      24: 'চব্বিশ',
      25: 'পঁচিশ',
      30: 'ত্রিশ',
      40: 'চল্লিশ',
      50: 'পঞ্চাশ',
      60: 'ষাট',
      70: 'সত্তর',
      80: 'আশি',
      90: 'নব্বই',
      100: 'একশো',
    };

    if (words.containsKey(number)) {
      return words[number]!;
    }

    // For numbers 26-99 not in the map
    if (number > 25 && number < 100) {
      final tens = (number ~/ 10) * 10;
      final ones = number % 10;
      if (ones == 0) {
        return words[tens] ?? toBangla(number);
      }
      return '${words[tens]} ${words[ones]}';
    }

    return toBangla(number);
  }
}
