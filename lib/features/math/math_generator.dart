import 'dart:math';
import 'models/math_models.dart';

class MathGenerator {
  static final Random _random = Random();

  static MathProblem generateProblem({
    required MathOperation operation,
    MathDifficulty difficulty = MathDifficulty.easy,
  }) {
    int operand1, operand2, answer;
    final maxNumber = _getMaxNumber(difficulty);

    switch (operation) {
      case MathOperation.addition:
        operand1 = _random.nextInt(maxNumber) + 1;
        operand2 = _random.nextInt(maxNumber) + 1;
        answer = operand1 + operand2;
        break;

      case MathOperation.subtraction:
        // Ensure non-negative result
        operand1 = _random.nextInt(maxNumber) + 1;
        operand2 = _random.nextInt(operand1) + 1;
        answer = operand1 - operand2;
        break;

      case MathOperation.multiplication:
        operand1 = _random.nextInt(12) + 1;
        operand2 = _random.nextInt(10) + 1;
        answer = operand1 * operand2;
        break;

      case MathOperation.division:
        // Ensure whole number result
        operand2 = _random.nextInt(10) + 1;
        answer = _random.nextInt(10) + 1;
        operand1 = operand2 * answer;
        break;

      case MathOperation.numbersBangla:
      case MathOperation.numbersEnglish:
      case MathOperation.multiplicationTable:
      case MathOperation.mathPractice:
        // These operations don't use this generator
        // Return a default problem
        operand1 = 1;
        operand2 = 1;
        answer = 2;
        break;
    }

    final options = _generateOptions(answer, operation);

    return MathProblem(
      operand1: operand1,
      operand2: operand2,
      operation: operation,
      correctAnswer: answer,
      options: options,
    );
  }

  static int _getMaxNumber(MathDifficulty difficulty) {
    switch (difficulty) {
      case MathDifficulty.easy:
        return 10;
      case MathDifficulty.medium:
        return 50;
      case MathDifficulty.hard:
        return 100;
    }
  }

  static List<int> _generateOptions(int correctAnswer, MathOperation operation) {
    final options = <int>{correctAnswer};
    
    while (options.length < 4) {
      int wrongAnswer;
      final offset = _random.nextInt(10) + 1;
      
      if (_random.nextBool()) {
        wrongAnswer = correctAnswer + offset;
      } else {
        wrongAnswer = correctAnswer - offset;
        if (wrongAnswer < 0) {
          wrongAnswer = correctAnswer + offset;
        }
      }
      
      if (wrongAnswer >= 0 && wrongAnswer != correctAnswer) {
        options.add(wrongAnswer);
      }
    }

    final optionsList = options.toList();
    optionsList.shuffle(_random);
    return optionsList;
  }

  static MultiplicationTable generateTable(int number) {
    final rows = List.generate(
      10,
      (index) => MultiplicationRow(
        multiplier: number,
        multiplicand: index + 1,
        product: number * (index + 1),
      ),
    );

    return MultiplicationTable(number: number, rows: rows);
  }

  static List<int> generateCountableObjects(int count) {
    return List.generate(count, (index) => index);
  }
}
