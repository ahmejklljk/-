import 'dart:math' as math;

/// Exception thrown when an expression cannot be parsed or evaluated.
class CalculatorException implements Exception {
  const CalculatorException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Evaluates mathematical expressions with standard operator precedence,
/// implicit multiplication, parentheses, percentages, factorials, and
/// scientific functions.
class ExpressionEvaluator {
  const ExpressionEvaluator();

  /// Evaluates [expression] and returns the numeric result.
  ///
  /// When [isDegrees] is `true`, trigonometric functions (`sin`, `cos`, `tan`)
  /// interpret their inputs in degrees.
  double evaluate(String expression, {bool isDegrees = true}) {
    final tokens = _tokenize(expression);
    if (tokens.isEmpty) {
      throw const CalculatorException('Empty expression');
    }

    final parser = _Parser(tokens, isDegrees: isDegrees);
    final value = parser.parseExpression();
    if (!parser.isAtEnd) {
      throw const CalculatorException('Invalid expression');
    }
    if (value.isNaN || value.isInfinite) {
      throw const CalculatorException('Result is undefined');
    }
    return _cleanFloatingPointNoise(value);
  }

  /// Formats a evaluated double for clean mobile display.
  static String formatNumber(double value) {
    if (value.isNaN || value.isInfinite) {
      return 'Error';
    }

    final cleaned = _cleanFloatingPointNoise(value);
    final normalized = cleaned == 0 ? 0.0 : cleaned;

    if (normalized != 0 &&
        (normalized.abs() >= 1e12 || normalized.abs() < 1e-8)) {
      return _formatScientific(normalized);
    }

    if (normalized == normalized.truncateToDouble() &&
        normalized.abs() < 1e15) {
      return _addThousandsSeparators(normalized.toInt().toString());
    }

    var text = normalized.toStringAsPrecision(12);
    if (text.contains('e') || text.contains('E')) {
      return _formatScientific(normalized);
    }
    if (text.contains('.')) {
      text = text.replaceFirst(RegExp(r'0+$'), '');
      text = text.replaceFirst(RegExp(r'\.$'), '');
    }
    return _addThousandsSeparators(text);
  }

  static String _formatScientific(double value) {
    final exp = value.toStringAsExponential(7);
    final parts = exp.split('e');
    var mantissa = parts[0];
    if (mantissa.contains('.')) {
      mantissa = mantissa.replaceFirst(RegExp(r'0+$'), '');
      mantissa = mantissa.replaceFirst(RegExp(r'\.$'), '');
    }
    return '${mantissa}e${parts[1]}';
  }

  static String _addThousandsSeparators(String numericText) {
    final isNegative = numericText.startsWith('-');
    final unsigned = isNegative ? numericText.substring(1) : numericText;
    final parts = unsigned.split('.');
    final integerPart = parts[0];

    final buffer = StringBuffer();
    for (var i = 0; i < integerPart.length; i++) {
      final remaining = integerPart.length - i;
      if (i > 0 && remaining % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(integerPart[i]);
    }

    final formattedInt = buffer.toString();
    final prefix = isNegative ? '-' : '';
    if (parts.length > 1) {
      return '$prefix$formattedInt.${parts[1]}';
    }
    return '$prefix$formattedInt';
  }

  static double _cleanFloatingPointNoise(double value) {
    if (value.abs() < 1e-13) {
      return 0.0;
    }
    final rounded = double.parse(value.toStringAsPrecision(13));
    if (rounded.abs() < 1e-13) {
      return 0.0;
    }
    return rounded;
  }

  List<_Token> _tokenize(String input) {
    final cleaned = input
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .replaceAll('−', '-')
        .replaceAll('×', '*')
        .replaceAll('÷', '/');

    final tokens = <_Token>[];
    var i = 0;

    while (i < cleaned.length) {
      final ch = cleaned[i];

      if (_isDigit(ch) || ch == '.') {
        final start = i;
        var dotCount = 0;
        while (i < cleaned.length && (_isDigit(cleaned[i]) || cleaned[i] == '.')) {
          if (cleaned[i] == '.') {
            dotCount++;
            if (dotCount > 1) {
              throw const CalculatorException('Invalid number format');
            }
          }
          i++;
        }

        // Support scientific notation like 1.5e+10 or 2e-5.
        if (i < cleaned.length &&
            (cleaned[i] == 'e' || cleaned[i] == 'E') &&
            i + 1 < cleaned.length &&
            (_isDigit(cleaned[i + 1]) ||
                ((cleaned[i + 1] == '+' || cleaned[i + 1] == '-') &&
                    i + 2 < cleaned.length &&
                    _isDigit(cleaned[i + 2])))) {
          i++;
          if (cleaned[i] == '+' || cleaned[i] == '-') {
            i++;
          }
          while (i < cleaned.length && _isDigit(cleaned[i])) {
            i++;
          }
        }

        final rawNumber = cleaned.substring(start, i);
        if (rawNumber == '.') {
          throw const CalculatorException('Invalid number format');
        }
        final number = double.tryParse(rawNumber);
        if (number == null) {
          throw const CalculatorException('Invalid number format');
        }
        _insertImplicitMultiplyIfNeeded(tokens, _TokenType.number);
        tokens.add(_Token(_TokenType.number, numberValue: number));
        continue;
      }

      if (ch == 'π') {
        _insertImplicitMultiplyIfNeeded(tokens, _TokenType.number);
        tokens.add(const _Token(_TokenType.number, numberValue: math.pi));
        i++;
        continue;
      }

      if (ch == 'e') {
        _insertImplicitMultiplyIfNeeded(tokens, _TokenType.number);
        tokens.add(const _Token(_TokenType.number, numberValue: math.e));
        i++;
        continue;
      }

      if (ch == '√') {
        _insertImplicitMultiplyIfNeeded(tokens, _TokenType.function);
        tokens.add(const _Token(_TokenType.function, text: 'sqrt'));
        i++;
        continue;
      }

      if (_isLetter(ch)) {
        final start = i;
        while (i < cleaned.length && _isLetter(cleaned[i])) {
          i++;
        }
        final name = cleaned.substring(start, i).toLowerCase();
        if (const {'sin', 'cos', 'tan', 'ln', 'log', 'sqrt'}.contains(name)) {
          _insertImplicitMultiplyIfNeeded(tokens, _TokenType.function);
          tokens.add(_Token(_TokenType.function, text: name));
        } else {
          throw CalculatorException('Unknown function: $name');
        }
        continue;
      }

      switch (ch) {
        case '+':
          tokens.add(const _Token(_TokenType.plus));
        case '-':
          tokens.add(const _Token(_TokenType.minus));
        case '*':
          tokens.add(const _Token(_TokenType.multiply));
        case '/':
          tokens.add(const _Token(_TokenType.divide));
        case '^':
          tokens.add(const _Token(_TokenType.power));
        case '%':
          tokens.add(const _Token(_TokenType.percent));
        case '!':
          tokens.add(const _Token(_TokenType.factorial));
        case '(':
          _insertImplicitMultiplyIfNeeded(tokens, _TokenType.leftParen);
          tokens.add(const _Token(_TokenType.leftParen));
        case ')':
          tokens.add(const _Token(_TokenType.rightParen));
        default:
          throw CalculatorException('Unexpected character: $ch');
      }
      i++;
    }

    return tokens;
  }

  void _insertImplicitMultiplyIfNeeded(
    List<_Token> tokens,
    _TokenType incoming,
  ) {
    if (tokens.isEmpty) return;
    final prev = tokens.last.type;
    final prevCanMultiply = prev == _TokenType.number ||
        prev == _TokenType.rightParen ||
        prev == _TokenType.percent ||
        prev == _TokenType.factorial;
    final incomingCanMultiply = incoming == _TokenType.number ||
        incoming == _TokenType.leftParen ||
        incoming == _TokenType.function;
    if (prevCanMultiply && incomingCanMultiply) {
      tokens.add(const _Token(_TokenType.multiply));
    }
  }

  static bool _isDigit(String ch) {
    final code = ch.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }

  static bool _isLetter(String ch) {
    final code = ch.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  }
}

enum _TokenType {
  number,
  function,
  plus,
  minus,
  multiply,
  divide,
  power,
  percent,
  factorial,
  leftParen,
  rightParen,
}

class _Token {
  const _Token(this.type, {this.numberValue, this.text});

  final _TokenType type;
  final double? numberValue;
  final String? text;
}

class _Parser {
  _Parser(this._tokens, {required this.isDegrees});

  final List<_Token> _tokens;
  final bool isDegrees;
  int _index = 0;

  bool get isAtEnd => _index >= _tokens.length;

  _Token get _current => _tokens[_index];

  _Token _advance() => _tokens[_index++];

  bool _match(_TokenType type) {
    if (!isAtEnd && _current.type == type) {
      _advance();
      return true;
    }
    return false;
  }

  double parseExpression() => _parseAddSub();

  double _parseAddSub() {
    var value = _parseMulDiv();
    while (!isAtEnd &&
        (_current.type == _TokenType.plus ||
            _current.type == _TokenType.minus)) {
      final op = _advance().type;
      final right = _parseMulDiv();
      value = op == _TokenType.plus ? value + right : value - right;
    }
    return value;
  }

  double _parseMulDiv() {
    var value = _parseUnary();
    while (!isAtEnd &&
        (_current.type == _TokenType.multiply ||
            _current.type == _TokenType.divide)) {
      final op = _advance().type;
      final right = _parseUnary();
      if (op == _TokenType.multiply) {
        value *= right;
      } else {
        if (right == 0) {
          throw const CalculatorException('Cannot divide by zero');
        }
        value /= right;
      }
    }
    return value;
  }

  double _parseUnary() {
    if (_match(_TokenType.plus)) {
      return _parseUnary();
    }
    if (_match(_TokenType.minus)) {
      return -_parseUnary();
    }
    return _parsePower();
  }

  double _parsePower() {
    final base = _parsePostfix();
    if (_match(_TokenType.power)) {
      // Right-associative exponentiation, allowing unary sign in exponent.
      final exponent = _parseUnary();
      final result = math.pow(base, exponent).toDouble();
      if (result.isNaN || result.isInfinite) {
        throw const CalculatorException('Domain error');
      }
      return result;
    }
    return base;
  }

  double _parsePostfix() {
    var value = _parsePrimary();
    while (!isAtEnd &&
        (_current.type == _TokenType.percent ||
            _current.type == _TokenType.factorial)) {
      final op = _advance().type;
      if (op == _TokenType.percent) {
        value /= 100.0;
      } else {
        value = _factorial(value);
      }
    }
    return value;
  }

  double _parsePrimary() {
    if (isAtEnd) {
      throw const CalculatorException('Incomplete expression');
    }

    final token = _current;
    switch (token.type) {
      case _TokenType.number:
        _advance();
        return token.numberValue!;

      case _TokenType.function:
        _advance();
        final fnName = token.text!;
        if (_match(_TokenType.leftParen)) {
          final arg = parseExpression();
          if (!_match(_TokenType.rightParen)) {
            throw const CalculatorException('Missing closing parenthesis');
          }
          return _applyFunction(fnName, arg);
        }
        final arg = _parseUnary();
        return _applyFunction(fnName, arg);

      case _TokenType.leftParen:
        _advance();
        final value = parseExpression();
        if (!_match(_TokenType.rightParen)) {
          throw const CalculatorException('Missing closing parenthesis');
        }
        return value;

      default:
        throw const CalculatorException('Invalid expression');
    }
  }

  double _applyFunction(String name, double arg) {
    final radians = isDegrees ? arg * math.pi / 180.0 : arg;
    switch (name) {
      case 'sin':
        return math.sin(radians);
      case 'cos':
        return math.cos(radians);
      case 'tan':
        if (isDegrees && ((arg % 180).abs() == 90)) {
          throw const CalculatorException('Undefined');
        }
        final result = math.tan(radians);
        if (result.abs() > 1e14) {
          throw const CalculatorException('Undefined');
        }
        return result;
      case 'sqrt':
        if (arg < 0) {
          throw const CalculatorException('Invalid input');
        }
        return math.sqrt(arg);
      case 'ln':
        if (arg <= 0) {
          throw const CalculatorException('Domain error');
        }
        return math.log(arg);
      case 'log':
        if (arg <= 0) {
          throw const CalculatorException('Domain error');
        }
        return math.log(arg) / math.ln10;
      default:
        throw CalculatorException('Unknown function: $name');
    }
  }

  double _factorial(double value) {
    if (value < 0 || value != value.truncateToDouble() || value > 170) {
      throw const CalculatorException('Domain error');
    }
    var result = 1.0;
    final n = value.toInt();
    for (var i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }
}
