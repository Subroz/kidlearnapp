enum MathOperation {
  addition,
  subtraction,
  multiplication,
  division,
}

enum MathDifficulty {
  easy,
  medium,
  hard,
}

class MathProblem {
  final int operand1;
  final int operand2;
  final MathOperation operation;
  final int correctAnswer;
  final List<int> options;

  MathProblem({
    required this.operand1,
    required this.operand2,
    required this.operation,
    required this.correctAnswer,
    required this.options,
  });

  String get operationSymbol {
    switch (operation) {
      case MathOperation.addition:
        return '+';
      case MathOperation.subtraction:
        return '-';
      case MathOperation.multiplication:
        return '×';
      case MathOperation.division:
        return '÷';
    }
  }

  String get questionText {
    return '$operand1 $operationSymbol $operand2 = ?';
  }
}

class MultiplicationTable {
  final int number;
  final List<MultiplicationRow> rows;

  MultiplicationTable({
    required this.number,
    required this.rows,
  });
}

class MultiplicationRow {
  final int multiplier;
  final int multiplicand;
  final int product;

  MultiplicationRow({
    required this.multiplier,
    required this.multiplicand,
    required this.product,
  });

  String get text => '$multiplier × $multiplicand = $product';
}
