import 'package:material_ui/material_ui.dart';

/// Custom Liquid Glass design tokens inspired by iOS 26 Calculator.
@immutable
class CalculatorPalette extends ThemeExtension<CalculatorPalette> {
  const CalculatorPalette({
    required this.scaffoldBackground,
    required this.ambientPrimaryOrb,
    required this.ambientSecondaryOrb,
    required this.ambientWarmOrb,
    required this.displayBackground,
    required this.digitGlassTop,
    required this.digitGlassBottom,
    required this.digitKeyForeground,
    required this.functionGlassTop,
    required this.functionGlassBottom,
    required this.functionKeyForeground,
    required this.operatorGlassTop,
    required this.operatorGlassBottom,
    required this.operatorKeyForeground,
    required this.equalsGlassTop,
    required this.equalsGlassBottom,
    required this.equalsKeyForeground,
    required this.clearGlassTop,
    required this.clearGlassBottom,
    required this.clearKeyForeground,
    required this.specularRimTop,
    required this.specularRimBottom,
    required this.secondaryText,
    required this.errorText,
    required this.subtleBorder,
    required this.chipBackground,
    required this.chipActiveBackground,
    required this.chipActiveForeground,
    required this.glassShadow,
  });

  final Color scaffoldBackground;
  final Color ambientPrimaryOrb;
  final Color ambientSecondaryOrb;
  final Color ambientWarmOrb;
  final Color displayBackground;
  final Color digitGlassTop;
  final Color digitGlassBottom;
  final Color digitKeyForeground;
  final Color functionGlassTop;
  final Color functionGlassBottom;
  final Color functionKeyForeground;
  final Color operatorGlassTop;
  final Color operatorGlassBottom;
  final Color operatorKeyForeground;
  final Color equalsGlassTop;
  final Color equalsGlassBottom;
  final Color equalsKeyForeground;
  final Color clearGlassTop;
  final Color clearGlassBottom;
  final Color clearKeyForeground;
  final Color specularRimTop;
  final Color specularRimBottom;
  final Color secondaryText;
  final Color errorText;
  final Color subtleBorder;
  final Color chipBackground;
  final Color chipActiveBackground;
  final Color chipActiveForeground;
  final Color glassShadow;

  static const light = CalculatorPalette(
    scaffoldBackground: Color(0xFFEBEFF7),
    ambientPrimaryOrb: Color(0x6696B9FF),
    ambientSecondaryOrb: Color(0x55C7D8FF),
    ambientWarmOrb: Color(0x55FFB870),
    displayBackground: Color(0x88FFFFFF),
    digitGlassTop: Color(0xCCFFFFFF),
    digitGlassBottom: Color(0x88F4F7FC),
    digitKeyForeground: Color(0xFF11141C),
    functionGlassTop: Color(0xB8DCE3F0),
    functionGlassBottom: Color(0x80C8D2E3),
    functionKeyForeground: Color(0xFF1B2230),
    operatorGlassTop: Color(0xF0FFA31A),
    operatorGlassBottom: Color(0xE0FF8200),
    operatorKeyForeground: Color(0xFFFFFFFF),
    equalsGlassTop: Color(0xFAFFA726),
    equalsGlassBottom: Color(0xEBFF7A00),
    equalsKeyForeground: Color(0xFFFFFFFF),
    clearGlassTop: Color(0xB8E0E5F0),
    clearGlassBottom: Color(0x85CBD4E4),
    clearKeyForeground: Color(0xFF1B2230),
    specularRimTop: Color(0xE6FFFFFF),
    specularRimBottom: Color(0x4DFFFFFF),
    secondaryText: Color(0xFF5D6678),
    errorText: Color(0xFFD92D4A),
    subtleBorder: Color(0x70FFFFFF),
    chipBackground: Color(0x99FFFFFF),
    chipActiveBackground: Color(0xFFFF9500),
    chipActiveForeground: Color(0xFFFFFFFF),
    glassShadow: Color(0x18152238),
  );

  static const dark = CalculatorPalette(
    scaffoldBackground: Color(0xFF040507),
    ambientPrimaryOrb: Color(0x383A63D8),
    ambientSecondaryOrb: Color(0x2E24488F),
    ambientWarmOrb: Color(0x45FF8C1A),
    displayBackground: Color(0x14FFFFFF),
    digitGlassTop: Color(0x28FFFFFF),
    digitGlassBottom: Color(0x12FFFFFF),
    digitKeyForeground: Color(0xFFFFFFFF),
    functionGlassTop: Color(0x56FFFFFF),
    functionGlassBottom: Color(0x2EFFFFFF),
    functionKeyForeground: Color(0xFFFFFFFF),
    operatorGlassTop: Color(0xEAFFA217),
    operatorGlassBottom: Color(0xCCFF7D00),
    operatorKeyForeground: Color(0xFFFFFFFF),
    equalsGlassTop: Color(0xF7FFA61F),
    equalsGlassBottom: Color(0xE6FF7800),
    equalsKeyForeground: Color(0xFFFFFFFF),
    clearGlassTop: Color(0x56FFFFFF),
    clearGlassBottom: Color(0x2EFFFFFF),
    clearKeyForeground: Color(0xFFFFFFFF),
    specularRimTop: Color(0x75FFFFFF),
    specularRimBottom: Color(0x16FFFFFF),
    secondaryText: Color(0x99FFFFFF),
    errorText: Color(0xFFFF6B7A),
    subtleBorder: Color(0x2AFFFFFF),
    chipBackground: Color(0x1EFFFFFF),
    chipActiveBackground: Color(0xFFFF9F0A),
    chipActiveForeground: Color(0xFFFFFFFF),
    glassShadow: Color(0x55000000),
  );

  @override
  CalculatorPalette copyWith({
    Color? scaffoldBackground,
    Color? ambientPrimaryOrb,
    Color? ambientSecondaryOrb,
    Color? ambientWarmOrb,
    Color? displayBackground,
    Color? digitGlassTop,
    Color? digitGlassBottom,
    Color? digitKeyForeground,
    Color? functionGlassTop,
    Color? functionGlassBottom,
    Color? functionKeyForeground,
    Color? operatorGlassTop,
    Color? operatorGlassBottom,
    Color? operatorKeyForeground,
    Color? equalsGlassTop,
    Color? equalsGlassBottom,
    Color? equalsKeyForeground,
    Color? clearGlassTop,
    Color? clearGlassBottom,
    Color? clearKeyForeground,
    Color? specularRimTop,
    Color? specularRimBottom,
    Color? secondaryText,
    Color? errorText,
    Color? subtleBorder,
    Color? chipBackground,
    Color? chipActiveBackground,
    Color? chipActiveForeground,
    Color? glassShadow,
  }) {
    return CalculatorPalette(
      scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
      ambientPrimaryOrb: ambientPrimaryOrb ?? this.ambientPrimaryOrb,
      ambientSecondaryOrb: ambientSecondaryOrb ?? this.ambientSecondaryOrb,
      ambientWarmOrb: ambientWarmOrb ?? this.ambientWarmOrb,
      displayBackground: displayBackground ?? this.displayBackground,
      digitGlassTop: digitGlassTop ?? this.digitGlassTop,
      digitGlassBottom: digitGlassBottom ?? this.digitGlassBottom,
      digitKeyForeground: digitKeyForeground ?? this.digitKeyForeground,
      functionGlassTop: functionGlassTop ?? this.functionGlassTop,
      functionGlassBottom: functionGlassBottom ?? this.functionGlassBottom,
      functionKeyForeground:
          functionKeyForeground ?? this.functionKeyForeground,
      operatorGlassTop: operatorGlassTop ?? this.operatorGlassTop,
      operatorGlassBottom: operatorGlassBottom ?? this.operatorGlassBottom,
      operatorKeyForeground:
          operatorKeyForeground ?? this.operatorKeyForeground,
      equalsGlassTop: equalsGlassTop ?? this.equalsGlassTop,
      equalsGlassBottom: equalsGlassBottom ?? this.equalsGlassBottom,
      equalsKeyForeground: equalsKeyForeground ?? this.equalsKeyForeground,
      clearGlassTop: clearGlassTop ?? this.clearGlassTop,
      clearGlassBottom: clearGlassBottom ?? this.clearGlassBottom,
      clearKeyForeground: clearKeyForeground ?? this.clearKeyForeground,
      specularRimTop: specularRimTop ?? this.specularRimTop,
      specularRimBottom: specularRimBottom ?? this.specularRimBottom,
      secondaryText: secondaryText ?? this.secondaryText,
      errorText: errorText ?? this.errorText,
      subtleBorder: subtleBorder ?? this.subtleBorder,
      chipBackground: chipBackground ?? this.chipBackground,
      chipActiveBackground: chipActiveBackground ?? this.chipActiveBackground,
      chipActiveForeground: chipActiveForeground ?? this.chipActiveForeground,
      glassShadow: glassShadow ?? this.glassShadow,
    );
  }

  @override
  CalculatorPalette lerp(
    covariant ThemeExtension<CalculatorPalette>? other,
    double t,
  ) {
    if (other is! CalculatorPalette) return this;
    return CalculatorPalette(
      scaffoldBackground:
          Color.lerp(scaffoldBackground, other.scaffoldBackground, t)!,
      ambientPrimaryOrb:
          Color.lerp(ambientPrimaryOrb, other.ambientPrimaryOrb, t)!,
      ambientSecondaryOrb:
          Color.lerp(ambientSecondaryOrb, other.ambientSecondaryOrb, t)!,
      ambientWarmOrb: Color.lerp(ambientWarmOrb, other.ambientWarmOrb, t)!,
      displayBackground:
          Color.lerp(displayBackground, other.displayBackground, t)!,
      digitGlassTop: Color.lerp(digitGlassTop, other.digitGlassTop, t)!,
      digitGlassBottom:
          Color.lerp(digitGlassBottom, other.digitGlassBottom, t)!,
      digitKeyForeground:
          Color.lerp(digitKeyForeground, other.digitKeyForeground, t)!,
      functionGlassTop:
          Color.lerp(functionGlassTop, other.functionGlassTop, t)!,
      functionGlassBottom:
          Color.lerp(functionGlassBottom, other.functionGlassBottom, t)!,
      functionKeyForeground:
          Color.lerp(functionKeyForeground, other.functionKeyForeground, t)!,
      operatorGlassTop:
          Color.lerp(operatorGlassTop, other.operatorGlassTop, t)!,
      operatorGlassBottom:
          Color.lerp(operatorGlassBottom, other.operatorGlassBottom, t)!,
      operatorKeyForeground:
          Color.lerp(operatorKeyForeground, other.operatorKeyForeground, t)!,
      equalsGlassTop: Color.lerp(equalsGlassTop, other.equalsGlassTop, t)!,
      equalsGlassBottom:
          Color.lerp(equalsGlassBottom, other.equalsGlassBottom, t)!,
      equalsKeyForeground:
          Color.lerp(equalsKeyForeground, other.equalsKeyForeground, t)!,
      clearGlassTop: Color.lerp(clearGlassTop, other.clearGlassTop, t)!,
      clearGlassBottom:
          Color.lerp(clearGlassBottom, other.clearGlassBottom, t)!,
      clearKeyForeground:
          Color.lerp(clearKeyForeground, other.clearKeyForeground, t)!,
      specularRimTop: Color.lerp(specularRimTop, other.specularRimTop, t)!,
      specularRimBottom:
          Color.lerp(specularRimBottom, other.specularRimBottom, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      errorText: Color.lerp(errorText, other.errorText, t)!,
      subtleBorder: Color.lerp(subtleBorder, other.subtleBorder, t)!,
      chipBackground: Color.lerp(chipBackground, other.chipBackground, t)!,
      chipActiveBackground:
          Color.lerp(chipActiveBackground, other.chipActiveBackground, t)!,
      chipActiveForeground:
          Color.lerp(chipActiveForeground, other.chipActiveForeground, t)!,
      glassShadow: Color.lerp(glassShadow, other.glassShadow, t)!,
    );
  }
}

class AppTheme {
  static ThemeData buildLight() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: CalculatorPalette.light.scaffoldBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFF9F0A),
        brightness: Brightness.light,
      ),
      extensions: const [CalculatorPalette.light],
    );
  }

  static ThemeData buildDark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: CalculatorPalette.dark.scaffoldBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFF9F0A),
        brightness: Brightness.dark,
      ),
      extensions: const [CalculatorPalette.dark],
    );
  }
}
