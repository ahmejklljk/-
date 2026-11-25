import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'screens/calculator_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key, this.initialDarkMode});

  final bool? initialDarkMode;

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialDarkMode ?? true;
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final overlayStyle =
        _isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: MaterialApp(
        title: 'اله حاسبه بي الاصول',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.buildLight(),
        darkTheme: AppTheme.buildDark(),
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: CalculatorScreen(
          isDarkMode: _isDarkMode,
          onToggleTheme: _toggleTheme,
        ),
      ),
    );
  }
}
