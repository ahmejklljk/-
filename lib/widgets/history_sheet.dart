import 'dart:ui';
import 'package:material_ui/material_ui.dart';
import '../logic/calculator_controller.dart';
import '../theme/app_theme.dart';

/// Frosted Liquid Glass modal sheet displaying past calculations.
class HistorySheet extends StatelessWidget {
  const HistorySheet({
    super.key,
    required this.history,
    required this.onSelectResult,
    required this.onSelectExpression,
    required this.onClearHistory,
  });

  final List<CalculationHistoryItem> history;
  final ValueChanged<CalculationHistoryItem> onSelectResult;
  final ValueChanged<CalculationHistoryItem> onSelectExpression;
  final VoidCallback onClearHistory;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<CalculatorPalette>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(32),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xCC14171F)
                      : const Color(0xDCF6F8FC),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  border: Border.all(color: palette.subtleBorder, width: 1),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: palette.secondaryText.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.history_rounded,
                            color: palette.operatorGlassTop,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'History',
                            style: TextStyle(
                              color: palette.digitKeyForeground,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          if (history.isNotEmpty)
                            TextButton.icon(
                              onPressed: () {
                                onClearHistory();
                                Navigator.of(context).pop();
                              },
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: palette.errorText,
                              ),
                              label: Text(
                                'Clear',
                                style: TextStyle(color: palette.errorText),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: palette.subtleBorder),
                    Expanded(
                      child: history.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calculate_outlined,
                                    size: 48,
                                    color: palette.secondaryText.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No calculations yet',
                                    style: TextStyle(
                                      color: palette.secondaryText,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              itemCount: history.length,
                              separatorBuilder: (_, _) => Divider(
                                height: 16,
                                color: palette.subtleBorder,
                              ),
                              itemBuilder: (context, index) {
                                final item = history[index];
                                return InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    onSelectResult(item);
                                    Navigator.of(context).pop();
                                  },
                                  onLongPress: () {
                                    onSelectExpression(item);
                                    Navigator.of(context).pop();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          item.expression,
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            color: palette.secondaryText,
                                            fontSize: 15,
                                            fontFeatures: const [
                                              FontFeature.tabularFigures(),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '= ${item.result}',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            color: palette.digitKeyForeground,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w500,
                                            fontFeatures: const [
                                              FontFeature.tabularFigures(),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
