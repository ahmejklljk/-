import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import '../logic/calculator_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/calculator_button.dart';
import '../widgets/calculator_logo.dart';
import '../widgets/display_panel.dart';
import '../widgets/history_sheet.dart';
import '../widgets/liquid_glass_background.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    this.controller,
  });

  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final CalculatorController? controller;

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  late final CalculatorController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? CalculatorController();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _copyToClipboard() {
    final textToCopy = _controller.liveResult.isNotEmpty
        ? _controller.liveResult
        : _controller.displayExpression;
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Copied "$textToCopy"'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1400),
        ),
      );
  }

  void _openHistorySheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HistorySheet(
        history: _controller.history,
        onSelectResult: (item) =>
            _controller.useHistoryItem(item, useResult: true),
        onSelectExpression: (item) =>
            _controller.useHistoryItem(item, useResult: false),
        onClearHistory: _controller.clearHistory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<CalculatorPalette>()!;

    return Scaffold(
      backgroundColor: palette.scaffoldBackground,
      body: LiquidGlassBackground(
        child: SafeArea(
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              return OrientationBuilder(
                builder: (context, orientation) {
                  if (orientation == Orientation.landscape) {
                    return _buildLandscapeLayout(palette);
                  }
                  return _buildPortraitLayout(palette);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(CalculatorPalette palette) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Column(
        children: [
          _buildTopBar(palette),
          const SizedBox(height: 10),
          Expanded(
            flex: _controller.isScientific ? 26 : 33,
            child: DisplayPanel(
              expression: _controller.displayExpression,
              liveResult: _controller.liveResult,
              errorMessage: _controller.errorMessage,
              onCopy: _copyToClipboard,
            ),
          ),
          const SizedBox(height: 10),
          _buildQuickActionStrip(palette),
          const SizedBox(height: 10),
          Expanded(
            flex: _controller.isScientific ? 64 : 58,
            child: _buildKeypadSection(palette),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(CalculatorPalette palette) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Expanded(
            flex: 42,
            child: Column(
              children: [
                _buildTopBar(palette),
                const SizedBox(height: 8),
                Expanded(
                  child: DisplayPanel(
                    expression: _controller.displayExpression,
                    liveResult: _controller.liveResult,
                    errorMessage: _controller.errorMessage,
                    onCopy: _copyToClipboard,
                  ),
                ),
                const SizedBox(height: 8),
                _buildQuickActionStrip(palette),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 58,
            child: _buildKeypadSection(palette),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(CalculatorPalette palette) {
    return Row(
      children: [
        const CalculatorLogo(size: 34),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            'اله حاسبه بي الاصول',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: palette.digitKeyForeground,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _GlassHeaderChip(
          label: 'SCI',
          isActive: _controller.isScientific,
          palette: palette,
          onTap: _controller.toggleScientificMode,
        ),
        const SizedBox(width: 6),
        _GlassHeaderIconButton(
          icon: widget.isDarkMode
              ? Icons.light_mode_rounded
              : Icons.dark_mode_rounded,
          tooltip: widget.isDarkMode ? 'Light theme' : 'Dark theme',
          palette: palette,
          onTap: widget.onToggleTheme,
        ),
        const SizedBox(width: 6),
        _GlassHeaderIconButton(
          icon: Icons.history_rounded,
          tooltip: 'History',
          palette: palette,
          onTap: _openHistorySheet,
        ),
      ],
    );
  }

  Widget _buildQuickActionStrip(CalculatorPalette palette) {
    return Row(
      children: [
        _GlassMiniChip(
          label: '( )',
          palette: palette,
          onTap: _controller.inputParenthesis,
        ),
        const SizedBox(width: 8),
        _GlassMiniChip(
          label: 'x²',
          palette: palette,
          onTap: _controller.inputSquare,
        ),
        const SizedBox(width: 8),
        _GlassMiniChip(
          label: '√',
          palette: palette,
          onTap: () => _controller.inputFunction('√('),
        ),
        const SizedBox(width: 8),
        _GlassMiniChip(
          label: 'π',
          palette: palette,
          onTap: () => _controller.inputConstant('π'),
        ),
        const Spacer(),
        _GlassMiniChip(
          label: _controller.isDegrees ? 'DEG' : 'RAD',
          palette: palette,
          onTap: _controller.toggleAngleUnit,
        ),
        const SizedBox(width: 6),
        _GlassHeaderIconButton(
          icon: Icons.content_copy_rounded,
          tooltip: 'Copy',
          palette: palette,
          size: 32,
          iconSize: 16,
          onTap: _copyToClipboard,
        ),
      ],
    );
  }

  Widget _buildKeypadSection(CalculatorPalette palette) {
    return Column(
      children: [
        if (_controller.isScientific) ...[
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  child: _buildScientificRow(
                    palette,
                    [
                      _KeySpec(
                        label: 'sin',
                        onTap: () => _controller.inputFunction('sin('),
                      ),
                      _KeySpec(
                        label: 'cos',
                        onTap: () => _controller.inputFunction('cos('),
                      ),
                      _KeySpec(
                        label: 'tan',
                        onTap: () => _controller.inputFunction('tan('),
                      ),
                      _KeySpec(
                        label: 'ln',
                        onTap: () => _controller.inputFunction('ln('),
                      ),
                      _KeySpec(
                        label: 'log',
                        onTap: () => _controller.inputFunction('log('),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _buildScientificRow(
                    palette,
                    [
                      _KeySpec(
                        label: '√',
                        onTap: () => _controller.inputFunction('√('),
                      ),
                      _KeySpec(
                        label: '^',
                        onTap: () => _controller.inputOperator('^'),
                      ),
                      _KeySpec(
                        label: 'π',
                        onTap: () => _controller.inputConstant('π'),
                      ),
                      _KeySpec(
                        label: 'e',
                        onTap: () => _controller.inputConstant('e'),
                      ),
                      _KeySpec(
                        label: '!',
                        onTap: _controller.inputFactorial,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        Expanded(
          flex: 5,
          child: Column(
            children: [
              Expanded(
                child: _buildMainRow([
                  _buildFunctionKey(
                    palette: palette,
                    label: 'AC',
                    fontSize: 23,
                    onTap: _controller.clear,
                  ),
                  _buildFunctionKey(
                    palette: palette,
                    label: '+/-',
                    fontSize: 23,
                    onTap: _controller.toggleSign,
                  ),
                  _buildFunctionKey(
                    palette: palette,
                    label: '%',
                    fontSize: 25,
                    onTap: _controller.inputPercent,
                  ),
                  _buildOperatorKey(
                    palette: palette,
                    label: '÷',
                    onTap: () => _controller.inputOperator('÷'),
                  ),
                ]),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _buildMainRow([
                  _buildDigitKey(palette, '7'),
                  _buildDigitKey(palette, '8'),
                  _buildDigitKey(palette, '9'),
                  _buildOperatorKey(
                    palette: palette,
                    label: '×',
                    onTap: () => _controller.inputOperator('×'),
                  ),
                ]),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _buildMainRow([
                  _buildDigitKey(palette, '4'),
                  _buildDigitKey(palette, '5'),
                  _buildDigitKey(palette, '6'),
                  _buildOperatorKey(
                    palette: palette,
                    label: '-',
                    fontSize: 34,
                    onTap: () => _controller.inputOperator('-'),
                  ),
                ]),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _buildMainRow([
                  _buildDigitKey(palette, '1'),
                  _buildDigitKey(palette, '2'),
                  _buildDigitKey(palette, '3'),
                  _buildOperatorKey(
                    palette: palette,
                    label: '+',
                    onTap: () => _controller.inputOperator('+'),
                  ),
                ]),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _buildMainRow([
                  _buildFunctionKey(
                    palette: palette,
                    icon: Icons.backspace_outlined,
                    semanticLabel: 'Backspace',
                    fontSize: 23,
                    onTap: _controller.backspace,
                    onLongPress: _controller.clear,
                  ),
                  _buildDigitKey(palette, '0'),
                  _buildDigitKey(palette, '.'),
                  CalculatorButton(
                    label: '=',
                    onTap: _controller.evaluate,
                    glassTopColor: palette.equalsGlassTop,
                    glassBottomColor: palette.equalsGlassBottom,
                    foregroundColor: palette.equalsKeyForeground,
                    specularTopColor: palette.specularRimTop,
                    specularBottomColor: palette.specularRimBottom,
                    shadowColor: const Color(0x45FF8C00),
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                ]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScientificRow(
    CalculatorPalette palette,
    List<_KeySpec> keys,
  ) {
    return Row(
      children: [
        for (var i = 0; i < keys.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: CalculatorButton(
              label: keys[i].label,
              onTap: keys[i].onTap,
              glassTopColor: palette.digitGlassTop,
              glassBottomColor: palette.digitGlassBottom,
              foregroundColor: palette.digitKeyForeground,
              specularTopColor: palette.specularRimTop,
              specularBottomColor: palette.specularRimBottom,
              shadowColor: palette.glassShadow,
              isCircular: false,
              borderRadius: 18,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMainRow(List<Widget> children) {
    return Row(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: children[i]),
        ],
      ],
    );
  }

  Widget _buildDigitKey(CalculatorPalette palette, String label) {
    return CalculatorButton(
      label: label,
      onTap: label == '.'
          ? _controller.inputDecimal
          : () => _controller.inputDigit(label),
      glassTopColor: palette.digitGlassTop,
      glassBottomColor: palette.digitGlassBottom,
      foregroundColor: palette.digitKeyForeground,
      specularTopColor: palette.specularRimTop,
      specularBottomColor: palette.specularRimBottom,
      shadowColor: palette.glassShadow,
      fontSize: label == '.' ? 32 : 30,
      fontWeight: FontWeight.w400,
    );
  }

  Widget _buildFunctionKey({
    required CalculatorPalette palette,
    String? label,
    IconData? icon,
    String? semanticLabel,
    required double fontSize,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    return CalculatorButton(
      label: label,
      icon: icon,
      semanticLabel: semanticLabel,
      onTap: onTap,
      onLongPress: onLongPress,
      glassTopColor: palette.functionGlassTop,
      glassBottomColor: palette.functionGlassBottom,
      foregroundColor: palette.functionKeyForeground,
      specularTopColor: palette.specularRimTop,
      specularBottomColor: palette.specularRimBottom,
      shadowColor: palette.glassShadow,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
    );
  }

  Widget _buildOperatorKey({
    required CalculatorPalette palette,
    required String label,
    double fontSize = 31,
    required VoidCallback onTap,
  }) {
    return CalculatorButton(
      label: label,
      onTap: onTap,
      glassTopColor: palette.operatorGlassTop,
      glassBottomColor: palette.operatorGlassBottom,
      foregroundColor: palette.operatorKeyForeground,
      specularTopColor: palette.specularRimTop,
      specularBottomColor: palette.specularRimBottom,
      shadowColor: const Color(0x3DFF8C00),
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
    );
  }
}

class _KeySpec {
  const _KeySpec({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;
}

class _GlassHeaderIconButton extends StatelessWidget {
  const _GlassHeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.palette,
    required this.onTap,
    this.size = 36,
    this.iconSize = 18,
  });

  final IconData icon;
  final String tooltip;
  final CalculatorPalette palette;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: palette.chipBackground,
            shape: CircleBorder(
              side: BorderSide(color: palette.subtleBorder, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                width: size,
                height: size,
                child: Icon(
                  icon,
                  size: iconSize,
                  color: palette.digitKeyForeground,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassHeaderChip extends StatelessWidget {
  const _GlassHeaderChip({
    required this.label,
    required this.isActive,
    required this.palette,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final CalculatorPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color:
              isActive ? palette.chipActiveBackground : palette.chipBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: palette.subtleBorder, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? palette.chipActiveForeground
                      : palette.digitKeyForeground,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassMiniChip extends StatelessWidget {
  const _GlassMiniChip({
    required this.label,
    required this.palette,
    required this.onTap,
  });

  final String label;
  final CalculatorPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: palette.chipBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: palette.subtleBorder, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  color: palette.digitKeyForeground,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
