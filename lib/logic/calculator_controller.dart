import 'package:flutter/foundation.dart';
import 'expression_evaluator.dart';

/// A single entry saved in the calculator's history list.
class CalculationHistoryItem {
  const CalculationHistoryItem({
    required this.expression,
    required this.result,
    required this.timestamp,
  });

  final String expression;
  final String result;
  final DateTime timestamp;
}

/// Manages calculator expression state, live evaluation, history, and modes.
class CalculatorController extends ChangeNotifier {
  CalculatorController({ExpressionEvaluator? evaluator})
      : _evaluator = evaluator ?? const ExpressionEvaluator();

  final ExpressionEvaluator _evaluator;

  static const _binaryOperators = {'+', '-', '×', '÷', '^'};
  static const _easterEggResult = 'مش رجوله';
  static const _functionTokens = [
    'sin(',
    'cos(',
    'tan(',
    'log(',
    'ln(',
    '√(',
  ];

  String _expression = '';
  String _liveResult = '';
  String? _errorMessage;
  bool _justEvaluated = false;
  bool _isDegrees = true;
  bool _isScientific = false;
  final List<CalculationHistoryItem> _history = [];

  String get expression => _expression;
  String get displayExpression => _expression.isEmpty ? '0' : _expression;
  String get liveResult => _liveResult;
  String? get errorMessage => _errorMessage;
  bool get isDegrees => _isDegrees;
  bool get isScientific => _isScientific;
  List<CalculationHistoryItem> get history => List.unmodifiable(_history);

  void toggleAngleUnit() {
    _isDegrees = !_isDegrees;
    _recomputeLiveResult();
    notifyListeners();
  }

  void toggleScientificMode() {
    _isScientific = !_isScientific;
    notifyListeners();
  }

  void inputDigit(String digit) {
    _errorMessage = null;
    if (_justEvaluated) {
      _expression = '';
      _justEvaluated = false;
    }

    if (_expression == '0' && digit == '0') {
      return;
    }
    if (_expression == '0' && digit != '0') {
      _expression = digit;
    } else if (_endsWithStandaloneZero()) {
      _expression =
          '${_expression.substring(0, _expression.length - 1)}$digit';
    } else {
      _expression += digit;
    }

    _recomputeLiveResult();
    notifyListeners();
  }

  void inputDecimal() {
    _errorMessage = null;
    if (_justEvaluated) {
      _expression = '0.';
      _justEvaluated = false;
      _recomputeLiveResult();
      notifyListeners();
      return;
    }

    if (_expression.isEmpty) {
      _expression = '0.';
      _recomputeLiveResult();
      notifyListeners();
      return;
    }

    final currentSegment = _trailingNumberSegment();
    if (currentSegment.contains('.')) {
      return;
    }

    final last = _expression[_expression.length - 1];
    if (_isDigit(last)) {
      _expression += '.';
    } else if (last == ')' ||
        last == '%' ||
        last == '!' ||
        last == 'π' ||
        last == 'e') {
      _expression += '×0.';
    } else {
      _expression += '0.';
    }

    _recomputeLiveResult();
    notifyListeners();
  }

  void inputOperator(String op) {
    if (!_binaryOperators.contains(op)) return;
    _errorMessage = null;
    _justEvaluated = false;
    if (_expression == _easterEggResult) {
      _expression = '';
    }

    if (_expression.isEmpty) {
      if (op == '-') {
        _expression = '-';
      } else {
        _expression = '0$op';
      }
      _recomputeLiveResult();
      notifyListeners();
      return;
    }

    final last = _expression[_expression.length - 1];
    if (last == '(') {
      if (op == '-') {
        _expression += '-';
        _recomputeLiveResult();
        notifyListeners();
      }
      return;
    }

    if (_binaryOperators.contains(last)) {
      // Allow negative exponent or negative factor like 5×-3.
      if (op == '-' && (last == '×' || last == '÷' || last == '^')) {
        _expression += '-';
      } else {
        // Replace trailing operator(s), e.g., ×- -> +
        var end = _expression.length;
        while (end > 0 && _binaryOperators.contains(_expression[end - 1])) {
          end--;
        }
        if (end == 0) {
          _expression = op == '-' ? '-' : '0$op';
        } else if (_expression[end - 1] == '(') {
          if (op == '-') {
            _expression = '${_expression.substring(0, end)}-';
          }
        } else {
          _expression = '${_expression.substring(0, end)}$op';
        }
      }
    } else {
      if (last == '.') {
        _expression += '0';
      }
      _expression += op;
    }

    _recomputeLiveResult();
    notifyListeners();
  }

  void inputParenthesis() {
    _errorMessage = null;
    if (_justEvaluated) {
      _expression = '(';
      _justEvaluated = false;
      _recomputeLiveResult();
      notifyListeners();
      return;
    }

    if (_expression.isEmpty) {
      _expression = '(';
      _recomputeLiveResult();
      notifyListeners();
      return;
    }

    final openCount = '('.allMatches(_expression).length;
    final closeCount = ')'.allMatches(_expression).length;
    final last = _expression[_expression.length - 1];

    final canClose = openCount > closeCount &&
        (_isDigit(last) ||
            last == ')' ||
            last == '%' ||
            last == '!' ||
            last == 'π' ||
            last == 'e');

    _expression += canClose ? ')' : '(';
    _recomputeLiveResult();
    notifyListeners();
  }

  void inputFunction(String fnToken) {
    _errorMessage = null;
    if (_justEvaluated) {
      _expression = fnToken;
      _justEvaluated = false;
      _recomputeLiveResult();
      notifyListeners();
      return;
    }

    _expression += fnToken;
    _recomputeLiveResult();
    notifyListeners();
  }

  void inputConstant(String constant) {
    _errorMessage = null;
    if (_justEvaluated) {
      _expression = constant;
      _justEvaluated = false;
      _recomputeLiveResult();
      notifyListeners();
      return;
    }

    _expression += constant;
    _recomputeLiveResult();
    notifyListeners();
  }

  void inputPercent() {
    _errorMessage = null;
    _justEvaluated = false;
    if (_expression.isEmpty || _expression == _easterEggResult) return;

    final last = _expression[_expression.length - 1];
    if (_isDigit(last) || last == ')' || last == 'π' || last == 'e') {
      _expression += '%';
      _recomputeLiveResult();
      notifyListeners();
    }
  }

  void inputFactorial() {
    _errorMessage = null;
    _justEvaluated = false;
    if (_expression.isEmpty || _expression == _easterEggResult) return;

    final last = _expression[_expression.length - 1];
    if (_isDigit(last) || last == ')') {
      _expression += '!';
      _recomputeLiveResult();
      notifyListeners();
    }
  }

  void inputSquare() {
    _errorMessage = null;
    _justEvaluated = false;
    if (_expression.isEmpty || _expression == _easterEggResult) return;

    final last = _expression[_expression.length - 1];
    if (_isDigit(last) || last == ')' || last == 'π' || last == 'e') {
      _expression += '^2';
      _recomputeLiveResult();
      notifyListeners();
    }
  }

  void toggleSign() {
    _errorMessage = null;
    _justEvaluated = false;
    if (_expression == _easterEggResult) {
      _expression = '';
    }

    if (_expression.isEmpty) {
      _expression = '-';
      notifyListeners();
      return;
    }

    if (_expression == '-') {
      _expression = '';
      notifyListeners();
      return;
    }

    // Check if expression ends with `(-number)` pattern.
    final wrappedNegMatch = RegExp(r'\(-(\d+(?:\.\d+)?)\)$').firstMatch(_expression);
    if (wrappedNegMatch != null) {
      final number = wrappedNegMatch.group(1)!;
      _expression =
          _expression.substring(0, wrappedNegMatch.start) + number;
      _recomputeLiveResult();
      notifyListeners();
      return;
    }

    // Check if expression is just `-number`.
    final leadingNegMatch = RegExp(r'^-(\d+(?:\.\d+)?)$').firstMatch(_expression);
    if (leadingNegMatch != null) {
      _expression = leadingNegMatch.group(1)!;
      _recomputeLiveResult();
      notifyListeners();
      return;
    }

    // Check trailing positive number.
    final trailingNumMatch = RegExp(r'(\d+(?:\.\d+)?)$').firstMatch(_expression);
    if (trailingNumMatch != null) {
      final number = trailingNumMatch.group(1)!;
      final prefix = _expression.substring(0, trailingNumMatch.start);
      if (prefix.isEmpty) {
        _expression = '-$number';
      } else {
        _expression = '$prefix(-$number)';
      }
      _recomputeLiveResult();
      notifyListeners();
    }
  }

  void backspace() {
    _errorMessage = null;
    _justEvaluated = false;

    if (_expression.isEmpty) return;
    if (_expression == _easterEggResult) {
      _expression = '';
      _liveResult = '';
      notifyListeners();
      return;
    }

    for (final fn in _functionTokens) {
      if (_expression.endsWith(fn)) {
        _expression = _expression.substring(0, _expression.length - fn.length);
        _recomputeLiveResult();
        notifyListeners();
        return;
      }
    }

    _expression = _expression.substring(0, _expression.length - 1);
    _recomputeLiveResult();
    notifyListeners();
  }

  void clear() {
    _expression = '';
    _liveResult = '';
    _errorMessage = null;
    _justEvaluated = false;
    notifyListeners();
  }

  void evaluate() {
    if (_expression.isEmpty || _expression == _easterEggResult) return;

    final candidate = _autoCloseParentheses(_expression);
    if (_isTwoDividedByOne(candidate)) {
      _history.insert(
        0,
        CalculationHistoryItem(
          expression: candidate,
          result: _easterEggResult,
          timestamp: DateTime.now(),
        ),
      );
      _expression = _easterEggResult;
      _liveResult = '';
      _errorMessage = null;
      _justEvaluated = true;
      notifyListeners();
      return;
    }

    try {
      final value = _evaluator.evaluate(candidate, isDegrees: _isDegrees);
      final formatted = ExpressionEvaluator.formatNumber(value);

      if (candidate != formatted.replaceAll(',', '')) {
        _history.insert(
          0,
          CalculationHistoryItem(
            expression: candidate,
            result: formatted,
            timestamp: DateTime.now(),
          ),
        );
      }

      _expression = formatted.replaceAll(',', '');
      _liveResult = '';
      _errorMessage = null;
      _justEvaluated = true;
    } on CalculatorException catch (e) {
      _errorMessage = e.message;
    }
    notifyListeners();
  }

  void useHistoryItem(CalculationHistoryItem item, {bool useResult = true}) {
    _errorMessage = null;
    if (useResult) {
      if (item.result == _easterEggResult) {
        _expression = _easterEggResult;
        _liveResult = '';
        _justEvaluated = true;
        notifyListeners();
        return;
      }
      final raw = item.result.replaceAll(',', '');
      if (_justEvaluated ||
          _expression.isEmpty ||
          _expression == _easterEggResult) {
        _expression = raw;
      } else {
        final last = _expression[_expression.length - 1];
        if (_binaryOperators.contains(last) || last == '(') {
          _expression += raw;
        } else {
          _expression = raw;
        }
      }
      _justEvaluated = false;
    } else {
      _expression = item.expression;
      _justEvaluated = false;
    }
    _recomputeLiveResult();
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  void _recomputeLiveResult() {
    if (_expression.isEmpty) {
      _liveResult = '';
      return;
    }

    final last = _expression[_expression.length - 1];
    if (_binaryOperators.contains(last) || last == '(' || last == '.') {
      _liveResult = '';
      return;
    }

    final candidate = _autoCloseParentheses(_expression);
    if (_isTwoDividedByOne(candidate)) {
      _liveResult = _easterEggResult;
      return;
    }

    try {
      final value = _evaluator.evaluate(candidate, isDegrees: _isDegrees);
      final formatted = ExpressionEvaluator.formatNumber(value);
      final rawFormatted = formatted.replaceAll(',', '');
      if (rawFormatted == _expression) {
        _liveResult = '';
      } else {
        _liveResult = formatted;
      }
    } on CalculatorException {
      _liveResult = '';
    }
  }

  bool _isTwoDividedByOne(String expr) {
    final normalized = expr.replaceAll(' ', '');
    return normalized == '2÷1' || normalized == '2/1';
  }

  String _autoCloseParentheses(String expr) {
    final openCount = '('.allMatches(expr).length;
    final closeCount = ')'.allMatches(expr).length;
    if (openCount > closeCount) {
      return '$expr${')' * (openCount - closeCount)}';
    }
    return expr;
  }

  bool _endsWithStandaloneZero() {
    if (_expression.length < 2) return false;
    if (!_expression.endsWith('0')) return false;
    final prev = _expression[_expression.length - 2];
    return _binaryOperators.contains(prev) || prev == '(';
  }

  String _trailingNumberSegment() {
    var i = _expression.length - 1;
    while (i >= 0 && (_isDigit(_expression[i]) || _expression[i] == '.')) {
      i--;
    }
    return _expression.substring(i + 1);
  }

  static bool _isDigit(String ch) {
    final code = ch.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }
}
