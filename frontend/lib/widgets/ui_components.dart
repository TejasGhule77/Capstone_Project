import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';
import 'organic_decorations.dart';

export 'organic_decorations.dart';
export 'agriintel_logo.dart';

/// Reusable section title with eyebrow label, serif title, and optional subtitle/trailing
class SectionHeader extends StatelessWidget {
  final String title;
  final String? eyebrow;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryForest.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(icon, size: 18, color: AppColors.primaryForest),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (eyebrow != null) ...[
                        Text(
                          eyebrow!.toUpperCase(),
                          style: AppTextStyles.eyebrow(),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        title,
                        style: AppTextStyles.serifTitle(
                          fontSize: 17.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: AppTextStyles.body(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Status Pill Badge with organic handcrafted styling
class StatusPill extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color textColor;
  final Color bgColor;
  final Color? borderColor;
  final double fontSize;
  final EdgeInsets padding;

  const StatusPill({
    super.key,
    required this.text,
    this.icon,
    required this.textColor,
    required this.bgColor,
    this.borderColor,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
  });

  factory StatusPill.verified({String text = "VERIFIED", double fontSize = 11}) {
    return StatusPill(
      text: text,
      icon: Icons.verified_rounded,
      textColor: AppColors.primaryForest,
      bgColor: AppColors.sprayGoodBg,
      borderColor: AppColors.sprayGoodBorder,
      fontSize: fontSize,
    );
  }

  factory StatusPill.demo({String text = "VERIFIED DATA", double fontSize = 11}) {
    return StatusPill(
      text: text,
      icon: Icons.shield_outlined,
      textColor: AppColors.demoBadgeText,
      bgColor: AppColors.demoBadgeBg,
      borderColor: AppColors.demoBadgeText.withValues(alpha: 0.3),
      fontSize: fontSize,
    );
  }

  factory StatusPill.spraySafe({required String text}) {
    return StatusPill(
      text: text,
      icon: Icons.check_circle_rounded,
      textColor: AppColors.sprayGood,
      bgColor: AppColors.sprayGoodBg,
      borderColor: AppColors.sprayGoodBorder,
    );
  }

  factory StatusPill.sprayCaution({required String text}) {
    return StatusPill(
      text: text,
      icon: Icons.warning_amber_rounded,
      textColor: AppColors.sprayCaution,
      bgColor: AppColors.sprayCautionBg,
      borderColor: AppColors.sprayCautionBorder,
    );
  }

  factory StatusPill.sprayStop({required String text}) {
    return StatusPill(
      text: text,
      icon: Icons.cancel_rounded,
      textColor: AppColors.sprayStop,
      bgColor: AppColors.sprayStopBg,
      borderColor: AppColors.sprayStopBorder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? textColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 3, color: textColor),
            const SizedBox(width: 4.5),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Eco-Premium App Card with optional washi tape decoration
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool hasWashiTape;
  final String? washiTapeText;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.hasWashiTape = false,
    this.washiTapeText,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.cardCream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor ?? AppColors.border,
          width: 1.2,
        ),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );

    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: cardContent,
      );
    }

    if (hasWashiTape) {
      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          cardContent,
          Positioned(
            top: -9,
            child: const WashiTape(width: 80, height: 18),
          ),
        ],
      );
    }

    return cardContent;
  }
}

/// Primary / Outline Styled App Button
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isOutline;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const AppButton({
    super.key,
    String? label,
    String? text,
    required this.onPressed,
    this.icon,
    bool isOutline = false,
    bool isPrimary = true,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  })  : label = label ?? text ?? '',
        isOutline = isOutline || !isPrimary;

  @override
  Widget build(BuildContext context) {
    if (isOutline) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? AppColors.primaryForest,
          side: BorderSide(color: backgroundColor ?? AppColors.primaryForest, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _buildContent(textColor ?? AppColors.primaryForest),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primaryForest,
        foregroundColor: textColor ?? AppColors.parchment,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 2,
        shadowColor: (backgroundColor ?? AppColors.primaryForest).withValues(alpha: 0.35),
      ),
      child: _buildContent(textColor ?? AppColors.parchment),
    );
  }

  Widget _buildContent(Color textCol) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(textCol),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: textCol),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      );
    }

    return Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14));
  }
}

/// Animated Circular Gauge Confidence Indicator
class ConfidenceScoreGauge extends StatelessWidget {
  final double confidence;
  final String label;
  final double size;

  const ConfidenceScoreGauge({
    super.key,
    required this.confidence,
    this.label = "AI Confidence",
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    final double normalized = confidence > 1.0 ? confidence / 100.0 : confidence;
    final int percentage = (normalized * 100).round();

    Color scoreColor;
    String ratingText;
    if (normalized >= 0.85) {
      scoreColor = AppColors.primaryForest;
      ratingText = "High Confidence";
    } else if (normalized >= 0.65) {
      scoreColor = AppColors.diwaliGold;
      ratingText = "Moderate";
    } else {
      scoreColor = AppColors.sprayStop;
      ratingText = "Low Confidence";
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: normalized,
                strokeWidth: 6,
                backgroundColor: scoreColor.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                strokeCap: StrokeCap.round,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$percentage%",
                    style: TextStyle(
                      fontSize: size * 0.24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: scoreColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                ratingText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Laser Scanner Frame Overlay with dynamic animated scan line
class AnimatedScannerFrame extends StatefulWidget {
  final Widget child;
  final bool isScanning;
  final String? statusText;

  const AnimatedScannerFrame({
    super.key,
    required this.child,
    this.isScanning = false,
    this.statusText,
  });

  @override
  State<AnimatedScannerFrame> createState() => _AnimatedScannerFrameState();
}

class _AnimatedScannerFrameState extends State<AnimatedScannerFrame>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    if (widget.isScanning) {
      _animController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedScannerFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning && !_animController.isAnimating) {
      _animController.repeat(reverse: true);
    } else if (!widget.isScanning && _animController.isAnimating) {
      _animController.stop();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          // Corner Focus Brackets
          Positioned.fill(
            child: CustomPaint(
              painter: _ScannerBracketPainter(
                color: widget.isScanning ? AppColors.diwaliGold : AppColors.fernGreen,
              ),
            ),
          ),
          // Animated Scanning Laser Line
          if (widget.isScanning)
            AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment(0, (_scanAnimation.value * 2) - 1.0),
                    child: Container(
                      height: 3.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.diwaliGold.withValues(alpha: 0.0),
                            AppColors.diwaliGold,
                            AppColors.diwaliGold.withValues(alpha: 0.0),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.diwaliGold.withValues(alpha: 0.7),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          // Scanning status banner
          if (widget.isScanning && widget.statusText != null)
            Positioned(
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.deepSectionDark.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.diwaliGold.withValues(alpha: 0.6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.diwaliGold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.statusText!,
                      style: const TextStyle(
                        color: AppColors.parchment,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScannerBracketPainter extends CustomPainter {
  final Color color;
  _ScannerBracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 22.0;
    const padding = 10.0;

    // Top-Left
    canvas.drawLine(const Offset(padding, padding + cornerLength), const Offset(padding, padding), paint);
    canvas.drawLine(const Offset(padding, padding), const Offset(padding + cornerLength, padding), paint);

    // Top-Right
    canvas.drawLine(Offset(size.width - padding - cornerLength, padding), Offset(size.width - padding, padding), paint);
    canvas.drawLine(Offset(size.width - padding, padding), Offset(size.width - padding, padding + cornerLength), paint);

    // Bottom-Left
    canvas.drawLine(Offset(padding, size.height - padding - cornerLength), Offset(padding, size.height - padding), paint);
    canvas.drawLine(Offset(padding, size.height - padding), Offset(padding + cornerLength, size.height - padding), paint);

    // Bottom-Right
    canvas.drawLine(Offset(size.width - padding - cornerLength, size.height - padding), Offset(size.width - padding, size.height - padding), paint);
    canvas.drawLine(Offset(size.width - padding, size.height - padding), Offset(size.width - padding, size.height - padding - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant _ScannerBracketPainter oldDelegate) => oldDelegate.color != color;
}

/// Precision Weather / Agricultural Metric Tile
class MetricTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? color;
  final Color? iconBg;

  const MetricTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.color,
    this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primaryForest;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: iconBg ?? AppColors.cardCream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: effectiveColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: effectiveColor),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Contextual Loading with gentle warm pulse
class ContextualLoading extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;

  const ContextualLoading({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryForest.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 32,
                height: 32,
                child: icon != null
                    ? Icon(icon, color: AppColors.primaryForest, size: 28)
                    : const CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryForest),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.serifTitle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shimmer Skeleton Loader for data fetching states
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFEADBBE).withValues(alpha: 0.4),
      highlightColor: const Color(0xFFFFFDF7),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFEADBBE),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Farmer-centric Empty State with handcrafted botanical touch
class FarmerEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const FarmerEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.primaryForest.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, size: 36, color: AppColors.fernGreen),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: AppTextStyles.serifTitle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              AppButton(
                label: actionLabel!,
                icon: Icons.add_rounded,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Friendly Error State
class FarmerErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const FarmerErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sprayStopBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sprayStopBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.sprayStop, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Unable to load data",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.sprayStop),
                ),
                Text(
                  message,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF5D4037)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.sprayStop),
            tooltip: "Retry",
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
