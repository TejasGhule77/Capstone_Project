import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable AgriIntel Brand Logo Widget
/// Preserves the exact aspect ratio, brand identity, and clear space
class AgriIntelLogo extends StatelessWidget {
  final double size;
  final bool onDark;
  final bool showTagline;
  final VoidCallback? onTap;

  const AgriIntelLogo({
    super.key,
    this.size = 48.0,
    this.onDark = false,
    this.showTagline = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget logoContent = Hero(
      tag: 'agriintel_brand_logo',
      child: Container(
        constraints: BoxConstraints(maxWidth: size * 2.2, maxHeight: size),
        child: Image.asset(
          'assets/images/agriintel_logo.png',
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // High fidelity fallback matching brand iconography
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: size * 0.75,
                  height: size * 0.75,
                  decoration: BoxDecoration(
                    color: onDark ? AppColors.parchment : AppColors.primaryForest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.eco_rounded,
                    color: onDark ? AppColors.primaryForest : AppColors.parchment,
                    size: size * 0.45,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "AgriIntel",
                  style: AppTextStyles.serifTitle(
                    fontSize: size * 0.4,
                    color: onDark ? AppColors.parchment : AppColors.primaryForest,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );

    if (onTap != null) {
      logoContent = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: logoContent,
      );
    }

    return logoContent;
  }
}
