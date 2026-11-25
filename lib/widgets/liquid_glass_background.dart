import 'package:material_ui/material_ui.dart';
import '../theme/app_theme.dart';

/// Ambient light backdrop that gives Liquid Glass surfaces subtle color refraction.
class LiquidGlassBackground extends StatelessWidget {
  const LiquidGlassBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<CalculatorPalette>()!;

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: palette.scaffoldBackground),
        Positioned(
          top: -90,
          right: -70,
          child: _AmbientOrb(
            size: 290,
            color: palette.ambientPrimaryOrb,
          ),
        ),
        Positioned(
          top: 150,
          left: -100,
          child: _AmbientOrb(
            size: 260,
            color: palette.ambientSecondaryOrb,
          ),
        ),
        Positioned(
          bottom: -60,
          right: -40,
          child: _AmbientOrb(
            size: 320,
            color: palette.ambientWarmOrb,
          ),
        ),
        child,
      ],
    );
  }
}

class _AmbientOrb extends StatelessWidget {
  const _AmbientOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}
