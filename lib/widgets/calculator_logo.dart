import 'package:material_ui/material_ui.dart';

/// Custom iOS Liquid Glass style emblem for "اله حاسبه بي الاصول".
class CalculatorLogo extends StatelessWidget {
  const CalculatorLogo({super.key, this.size = 34});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.26),
        border: Border.all(
          color: const Color(0x66FFFFFF),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9F0A).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/images/app_logo.png',
        fit: BoxFit.cover,
      ),
    );
  }
}
