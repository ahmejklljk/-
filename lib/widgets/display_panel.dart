import 'dart:ui';
import 'package:material_ui/material_ui.dart';
import '../theme/app_theme.dart';

/// Frosted Liquid Glass display panel modeled after the iOS 26 Calculator.
class DisplayPanel extends StatefulWidget {
  const DisplayPanel({
    super.key,
    required this.expression,
    required this.liveResult,
    required this.errorMessage,
    required this.onCopy,
  });

  final String expression;
  final String liveResult;
  final String? errorMessage;
  final VoidCallback onCopy;

  @override
  State<DisplayPanel> createState() => _DisplayPanelState();
}

class _DisplayPanelState extends State<DisplayPanel> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant DisplayPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expression != widget.expression) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  double _computeFontSize(int length, double availableHeight) {
    final maxAllowed = (availableHeight * 0.48).clamp(32.0, 68.0);
    if (length <= 8) return maxAllowed;
    if (length <= 13) return (maxAllowed * 0.78).clamp(26.0, 50.0);
    if (length <= 19) return (maxAllowed * 0.64).clamp(22.0, 40.0);
    return (maxAllowed * 0.54).clamp(20.0, 32.0);
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<CalculatorPalette>()!;
    final hasError = widget.errorMessage != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final exprFontSize =
            _computeFontSize(widget.expression.length, constraints.maxHeight);

        return GestureDetector(
          onLongPress: widget.onCopy,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
                decoration: BoxDecoration(
                  color: palette.displayBackground,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: palette.subtleBorder, width: 1.1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: (constraints.maxWidth - 46)
                                .clamp(0.0, double.infinity),
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              widget.expression,
                              maxLines: 1,
                              style: TextStyle(
                                color: palette.digitKeyForeground,
                                fontSize: exprFontSize,
                                fontWeight: FontWeight.w300,
                                letterSpacing: -1.0,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      child: hasError
                          ? Align(
                              key: ValueKey('err-${widget.errorMessage}'),
                              alignment: Alignment.centerRight,
                              child: Text(
                                widget.errorMessage!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: palette.errorText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : widget.liveResult.isNotEmpty
                              ? Align(
                                  key: ValueKey('res-${widget.liveResult}'),
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '= ${widget.liveResult}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: palette.secondaryText,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w300,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox(
                                  key: ValueKey('empty'),
                                  height: 30,
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
