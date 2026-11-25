import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Circular or pill-shaped Liquid Glass calculator button inspired by iOS 26.
class CalculatorButton extends StatefulWidget {
  const CalculatorButton({
    super.key,
    this.label,
    this.icon,
    required this.onTap,
    this.onLongPress,
    required this.glassTopColor,
    required this.glassBottomColor,
    required this.foregroundColor,
    required this.specularTopColor,
    required this.specularBottomColor,
    this.shadowColor,
    this.fontSize = 28,
    this.fontWeight = FontWeight.w400,
    this.isCircular = true,
    this.borderRadius = 999,
    this.semanticLabel,
  }) : assert(label != null || icon != null);

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Color glassTopColor;
  final Color glassBottomColor;
  final Color foregroundColor;
  final Color specularTopColor;
  final Color specularBottomColor;
  final Color? shadowColor;
  final double fontSize;
  final FontWeight fontWeight;
  final bool isCircular;
  final double borderRadius;
  final String? semanticLabel;

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed != value) {
      setState(() => _isPressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTop = _isPressed
        ? Color.alphaBlend(
            Colors.white.withValues(alpha: 0.22),
            widget.glassTopColor,
          )
        : widget.glassTopColor;
    final effectiveBottom = _isPressed
        ? Color.alphaBlend(
            Colors.white.withValues(alpha: 0.14),
            widget.glassBottomColor,
          )
        : widget.glassBottomColor;

    final content = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onLongPress: widget.onLongPress == null
          ? null
          : () {
              _setPressed(false);
              HapticFeedback.mediumImpact();
              widget.onLongPress!();
            },
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutBack,
        child: Container(
          decoration: BoxDecoration(
            shape: widget.isCircular ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.isCircular
                ? null
                : BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              if (widget.shadowColor != null)
                BoxShadow(
                  color: widget.shadowColor!,
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: _LiquidGlassShell(
            isCircular: widget.isCircular,
            borderRadius: widget.borderRadius,
            topColor: effectiveTop,
            bottomColor: effectiveBottom,
            specularTop: widget.specularTopColor,
            specularBottom: widget.specularBottomColor,
            child: Center(
              child: widget.icon != null
                  ? Icon(
                      widget.icon,
                      color: widget.foregroundColor,
                      size: widget.fontSize,
                    )
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          widget.label!,
                          maxLines: 1,
                          style: TextStyle(
                            color: widget.foregroundColor,
                            fontSize: widget.fontSize,
                            fontWeight: widget.fontWeight,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      label: widget.semanticLabel ?? widget.label,
      child: widget.isCircular
          ? Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: content,
              ),
            )
          : content,
    );
  }
}

class _LiquidGlassShell extends StatelessWidget {
  const _LiquidGlassShell({
    required this.isCircular,
    required this.borderRadius,
    required this.topColor,
    required this.bottomColor,
    required this.specularTop,
    required this.specularBottom,
    required this.child,
  });

  final bool isCircular;
  final double borderRadius;
  final Color topColor;
  final Color bottomColor;
  final Color specularTop;
  final Color specularBottom;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final inner = BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: CustomPaint(
        painter: _SpecularRimPainter(
          isCircular: isCircular,
          borderRadius: borderRadius,
          topColor: specularTop,
          bottomColor: specularBottom,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCircular ? null : radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [topColor, bottomColor],
            ),
          ),
          child: child,
        ),
      ),
    );

    return isCircular
        ? ClipOval(child: inner)
        : ClipRRect(borderRadius: radius, child: inner);
  }
}

class _SpecularRimPainter extends CustomPainter {
  const _SpecularRimPainter({
    required this.isCircular,
    required this.borderRadius,
    required this.topColor,
    required this.bottomColor,
  });

  final bool isCircular;
  final double borderRadius;
  final Color topColor;
  final Color bottomColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final insetRect = rect.deflate(0.7);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          topColor,
          topColor.withValues(alpha: topColor.a * 0.25),
          bottomColor,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(rect);

    if (isCircular) {
      canvas.drawOval(insetRect, paint);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(insetRect, Radius.circular(borderRadius)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpecularRimPainter oldDelegate) {
    return oldDelegate.topColor != topColor ||
        oldDelegate.bottomColor != bottomColor ||
        oldDelegate.isCircular != isCircular ||
        oldDelegate.borderRadius != borderRadius;
  }
}
