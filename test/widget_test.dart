import 'package:material_ui/material_ui.dart';
import 'package:flutter_calculator/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('performs basic calculation through UI taps', (tester) async {
    await tester.pumpWidget(const CalculatorApp(initialDarkMode: true));

    expect(find.text('0'), findsWidgets);
    expect(find.text('اله حاسبه بي الاصول'), findsOneWidget);

    await tester.tap(find.text('7'));
    await tester.pump();
    await tester.tap(find.text('×'));
    await tester.pump();
    await tester.tap(find.text('8'));
    await tester.pump();

    expect(find.text('7×8'), findsOneWidget);
    expect(find.text('= 56'), findsOneWidget);

    await tester.tap(find.text('='));
    await tester.pumpAndSettle();

    expect(find.text('56'), findsOneWidget);
  });

  testWidgets('toggles scientific mode, theme, and opens history', (
    tester,
  ) async {
    await tester.pumpWidget(const CalculatorApp(initialDarkMode: false));

    // Toggle scientific mode
    await tester.tap(find.text('SCI'));
    await tester.pumpAndSettle();
    expect(find.text('sin'), findsOneWidget);
    expect(find.text('cos'), findsOneWidget);

    // Perform a calculation so history has an item
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('+'));
    await tester.pump();
    await tester.tap(find.text('3'));
    await tester.pump();
    await tester.tap(find.text('='));
    await tester.pumpAndSettle();

    // Open history sheet
    await tester.tap(find.byIcon(Icons.history_rounded));
    await tester.pumpAndSettle();
    expect(find.text('History'), findsOneWidget);
    expect(find.text('2+3'), findsOneWidget);
    expect(find.text('= 5'), findsOneWidget);
  });

  testWidgets('shows custom message when calculating 2÷1', (tester) async {
    await tester.pumpWidget(const CalculatorApp(initialDarkMode: true));

    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('÷'));
    await tester.pump();
    await tester.tap(find.text('1'));
    await tester.pump();

    expect(find.text('= مش رجوله'), findsOneWidget);

    await tester.tap(find.text('='));
    await tester.pumpAndSettle();

    expect(find.text('مش رجوله'), findsOneWidget);
  });
}
