import 'dart:math' as math;
import 'package:flutter_calculator/logic/calculator_controller.dart';
import 'package:flutter_calculator/logic/expression_evaluator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpressionEvaluator', () {
    const evaluator = ExpressionEvaluator();

    test('evaluates basic arithmetic with precedence', () {
      expect(evaluator.evaluate('2+3×4'), 14);
      expect(evaluator.evaluate('(2+3)×4'), 20);
      expect(evaluator.evaluate('10-4÷2'), 8);
      expect(evaluator.evaluate('0.1+0.2'), 0.3);
    });

    test('evaluates unary operators, powers, and percentages', () {
      expect(evaluator.evaluate('-5+8'), 3);
      expect(evaluator.evaluate('2^3^2'), 512);
      expect(evaluator.evaluate('50%'), 0.5);
      expect(evaluator.evaluate('200×15%'), 30);
      expect(evaluator.evaluate('5!'), 120);
    });

    test('evaluates scientific functions in degrees and radians', () {
      expect(evaluator.evaluate('sin(30)', isDegrees: true), 0.5);
      expect(evaluator.evaluate('cos(60)', isDegrees: true), 0.5);
      expect(evaluator.evaluate('tan(45)', isDegrees: true), 1);
      expect(
        evaluator.evaluate('sin(π÷2)', isDegrees: false),
        closeTo(1, 1e-12),
      );
      expect(evaluator.evaluate('√(81)'), 9);
      expect(evaluator.evaluate('log(1000)'), 3);
      expect(evaluator.evaluate('ln(e)'), closeTo(1, 1e-12));
    });

    test('handles implicit multiplication', () {
      expect(evaluator.evaluate('2(3+4)'), 14);
      expect(evaluator.evaluate('(1+2)(3+4)'), 21);
      expect(evaluator.evaluate('2π'), closeTo(2 * math.pi, 1e-10));
    });

    test('throws meaningful errors on invalid math', () {
      expect(
        () => evaluator.evaluate('5÷0'),
        throwsA(isA<CalculatorException>()),
      );
      expect(
        () => evaluator.evaluate('√(-4)'),
        throwsA(isA<CalculatorException>()),
      );
      expect(
        () => evaluator.evaluate('tan(90)', isDegrees: true),
        throwsA(isA<CalculatorException>()),
      );
    });

    test('formats numbers cleanly', () {
      expect(ExpressionEvaluator.formatNumber(1234567), '1,234,567');
      expect(ExpressionEvaluator.formatNumber(42.0), '42');
      expect(ExpressionEvaluator.formatNumber(-0.0), '0');
      expect(ExpressionEvaluator.formatNumber(3.1415900), '3.14159');
    });
  });

  group('CalculatorController', () {
    test('handles digit input, live result, evaluation, and history', () {
      final controller = CalculatorController();

      controller.inputDigit('1');
      controller.inputDigit('2');
      controller.inputOperator('+');
      controller.inputDigit('8');

      expect(controller.displayExpression, '12+8');
      expect(controller.liveResult, '20');

      controller.evaluate();
      expect(controller.displayExpression, '20');
      expect(controller.liveResult, '');
      expect(controller.history.length, 1);
      expect(controller.history.first.expression, '12+8');
      expect(controller.history.first.result, '20');

      // Typing a digit after '=' starts a new calculation.
      controller.inputDigit('5');
      expect(controller.displayExpression, '5');
    });

    test('smart parenthesis, sign toggle, and function backspace', () {
      final controller = CalculatorController();

      controller.inputFunction('sin(');
      controller.inputDigit('3');
      controller.inputDigit('0');
      controller.inputParenthesis();
      expect(controller.displayExpression, 'sin(30)');
      expect(controller.liveResult, '0.5');

      controller.clear();
      controller.inputFunction('cos(');
      controller.backspace();
      expect(controller.displayExpression, '0');

      controller.inputDigit('9');
      controller.toggleSign();
      expect(controller.displayExpression, '-9');
      controller.toggleSign();
      expect(controller.displayExpression, '9');
    });

    test('sets error message on division by zero without crashing', () {
      final controller = CalculatorController();
      controller.inputDigit('9');
      controller.inputOperator('÷');
      controller.inputDigit('0');
      controller.evaluate();

      expect(controller.errorMessage, 'Cannot divide by zero');
    });

    test('returns custom message for 2÷1 in live preview and evaluation', () {
      final controller = CalculatorController();
      controller.inputDigit('2');
      controller.inputOperator('÷');
      controller.inputDigit('1');

      expect(controller.liveResult, 'مش رجوله');

      controller.evaluate();
      expect(controller.displayExpression, 'مش رجوله');
      expect(controller.history.first.expression, '2÷1');
      expect(controller.history.first.result, 'مش رجوله');

      // Typing a new digit resets cleanly.
      controller.inputDigit('4');
      expect(controller.displayExpression, '4');
    });
  });
}
