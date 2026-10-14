import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'organic_decorations.dart';

class PesticideInventoryCard extends StatelessWidget {
  final PesticideInventoryItem item;
  final String? activeCrop;
  final VoidCallback? onCompare;
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;
  final VoidCallback? onTap;

  const PesticideInventoryCard({
    super.key,
    required this.item,
    this.activeCrop,
    this.onCompare,
    this.onEdit,
    this.onArchive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = item.brandName ?? item.productName ?? "Pesticide Product";
    final isCropCompatible = activeCrop == null ||
        item.targetCrops.isEmpty ||
        item.targetCrops.any((c) => c.toLowerCase().contains(activeCrop!.toLowerCase()));

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Card(
          elevation: 0,
          color: AppColors.cardCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: item.isExpired
                  ? AppColors.sprayStop.withValues(alpha: 0.6)
                  : AppColors.border,
              width: item.isExpired ? 1.5 : 1.2,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Thumbnail + Title + Formulation
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildThumbnail(),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: AppTextStyles.serifTitle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (item.formulation != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryForest.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.primaryForest.withValues(alpha: 0.2)),
                                    ),
                                    child: Text(
                                      item.formulation!,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryForest,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (item.productName != null && item.productName != item.brandName)
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text(
                                  item.productName!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            if (item.manufacturer != null)
                              Text(
                                item.manufacturer!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Active Ingredients in Botanical Badge Container
                  if (item.activeIngredients.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.sageBg.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.fernGreen.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.biotech_outlined, size: 14, color: AppColors.primaryForest),
                              SizedBox(width: 4),
                              Text(
                                "Active Chemical Ingredients:",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryForest,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: item.activeIngredients.map((ai) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: AppColors.cardCream,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.fernGreen.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  "${ai.name} ${ai.concentration ?? ''}".trim(),
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryForest,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 10),

                  // Status Badges Row (Verification / Expiry / Registration)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      // Verification badge
                      if (item.isVerified)
                        _buildBadge("VERIFIED", AppColors.primaryForest, AppColors.sprayGoodBg, AppColors.sprayGoodBorder)
                      else
                        _buildBadge("OCR REVIEW REQUIRED", AppColors.diwaliGold, AppColors.goldLight, AppColors.diwaliGold.withValues(alpha: 0.4)),

                      // Expiry badge
                      if (item.isExpired)
                        _buildBadge("EXPIRED", AppColors.sprayStop, AppColors.sprayStopBg, AppColors.sprayStopBorder)
                      else if (item.isExpiringSoon)
                        _buildBadge("EXPIRING SOON", AppColors.sprayCaution, AppColors.sprayCautionBg, AppColors.sprayCautionBorder),

                      // Registration badge
                      if (item.registrationStatus == "VERIFIED")
                        _buildBadge("CIB&RC REGISTERED", const Color(0xFF1565C0), const Color(0xFFE3F2FD), const Color(0xFF90CAF9))
                      else if (item.registrationNumber != null && item.registrationNumber!.isNotEmpty)
                        _buildBadge("REG: ${item.registrationNumber}", AppColors.textSecondary, AppColors.parchment, AppColors.border)
                      else
                        _buildBadge("REGISTRATION UNKNOWN", AppColors.textMuted, AppColors.parchment, AppColors.border),

                      // Crop compatibility alert
                      if (!isCropCompatible && activeCrop != null)
                        _buildBadge("NOT TESTED ON $activeCrop", AppColors.terracotta, AppColors.terracottaLight, AppColors.terracotta.withValues(alpha: 0.4)),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Metadata row (Dose, PHI, Expiry date)
                  Row(
                    children: [
                      if (item.recommendedDose != null) ...[
                        const Icon(Icons.colorize_rounded, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          item.recommendedDose!,
                          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 14),
                      ],
                      if (item.phiDays != null) ...[
                        const Icon(Icons.timer_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          "PHI: ${item.phiDays}d",
                          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 14),
                      ],
                      if (item.expiryDate != null) ...[
                        const Icon(Icons.event_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          "Exp: ${item.expiryDate}",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: item.isExpired ? FontWeight.bold : FontWeight.w500,
                            color: item.isExpired ? AppColors.sprayStop : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const DottedSketchDivider(height: 20),

                  // Action Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Compare button
                      ElevatedButton.icon(
                        onPressed: onCompare,
                        icon: const Icon(Icons.compare_arrows_rounded, size: 18),
                        label: const Text("Compare"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryForest,
                          foregroundColor: AppColors.parchment,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        children: [
                          if (onEdit != null)
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textSecondary),
                              tooltip: "Edit Details",
                              onPressed: onEdit,
                            ),
                          if (onArchive != null)
                            IconButton(
                              icon: const Icon(Icons.archive_outlined, size: 20, color: AppColors.textMuted),
                              tooltip: "Archive Product",
                              onPressed: onArchive,
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnail() {
    if (item.frontImageUrl != null && item.frontImageUrl!.isNotEmpty) {
      final fullUrl = item.frontImageUrl!.startsWith("http")
          ? item.frontImageUrl!
          : "http://${ApiService.host}${item.frontImageUrl!}";
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          fullUrl,
          width: 58,
          height: 58,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _defaultThumbnail(),
        ),
      );
    }
    return _defaultThumbnail();
  }

  Widget _defaultThumbnail() {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.primaryForest.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Icon(
        Icons.science_outlined,
        color: AppColors.primaryForest,
        size: 28,
      ),
    );
  }

  Widget _buildBadge(String text, Color textColor, Color bgColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
