import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'organic_decorations.dart';

class ComparisonCriteriaTable extends StatefulWidget {
  final List<ComparisonCriterion> criteria;

  const ComparisonCriteriaTable({
    super.key,
    required this.criteria,
  });

  @override
  State<ComparisonCriteriaTable> createState() => _ComparisonCriteriaTableState();
}

class _ComparisonCriteriaTableState extends State<ComparisonCriteriaTable> {
  final Set<int> _expandedIndices = {};

  @override
  Widget build(BuildContext context) {
    if (widget.criteria.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      color: AppColors.cardCream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Multi-Criteria Suitability Breakdown",
                    style: AppTextStyles.serifTitle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Tap row for details",
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Column Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.sageBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      "Criterion (Weight)",
                      style: AppTextStyles.eyebrow(color: AppColors.textPrimary).copyWith(fontSize: 11),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Farmer Product",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.eyebrow(color: AppColors.primaryForest).copyWith(fontSize: 11),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      "AgriIntel Pick",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.eyebrow(color: const Color(0xFF1565C0)).copyWith(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Criteria Rows
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.criteria.length,
              separatorBuilder: (_, __) => const DottedSketchDivider(height: 12),
              itemBuilder: (context, index) {
                final c = widget.criteria[index];
                final isExpanded = _expandedIndices.contains(index);
                final invScore = c.inventoryScore ?? 0.0;
                final recScore = c.recommendedScore ?? 0.0;

                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedIndices.remove(index);
                      } else {
                        _expandedIndices.add(index);
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Criterion title & weight
                            Expanded(
                              flex: 4,
                              child: Row(
                                children: [
                                  Icon(
                                    isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded,
                                    size: 20,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      "${c.criterion}\n(${(c.weight * 100).toInt()}%)",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Farmer Product Score
                            Expanded(
                              flex: 3,
                              child: _buildScoreBadge(invScore, AppColors.primaryForest),
                            ),

                            // AgriIntel Score
                            Expanded(
                              flex: 3,
                              child: _buildScoreBadge(recScore, const Color(0xFF1565C0)),
                            ),
                          ],
                        ),

                        // Expanded Explanation Drawer
                        if (isExpanded) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.sageBg.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailItem(
                                  "Farmer Product",
                                  c.inventoryReason,
                                  Icons.inventory_2_outlined,
                                  AppColors.primaryForest,
                                ),
                                const SizedBox(height: 8),
                                _buildDetailItem(
                                  "AgriIntel Recommendation",
                                  c.recommendedReason,
                                  Icons.recommend_outlined,
                                  const Color(0xFF1565C0),
                                ),
                                const DottedSketchDivider(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Source: ${c.source}",
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "Conf: ${(c.confidence * 100).toInt()}%",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBadge(double score, Color color) {
    Color bg = score >= 80 ? color.withValues(alpha: 0.12) : (score >= 50 ? AppColors.diwaliGold.withValues(alpha: 0.15) : AppColors.sprayStop.withValues(alpha: 0.12));
    Color textCol = score >= 80 ? color : (score >= 50 ? const Color(0xFF9A3412) : AppColors.sprayStop);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: textCol.withValues(alpha: 0.3)),
          ),
          child: Text(
            "${score.toInt()}/100",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textCol,
            ),
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100.0,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(textCol),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String title, String desc, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
