import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Decorative Botanical Fern Fronds for Corner Accents
class BotanicalFernCorner extends StatelessWidget {
  final Alignment alignment;
  final double size;
  final double opacity;
  final Color? color;

  const BotanicalFernCorner({
    super.key,
    this.alignment = Alignment.topRight,
    this.size = 140.0,
    this.opacity = 0.12,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isTop = alignment == Alignment.topLeft || alignment == Alignment.topRight;
    final isLeft = alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;

    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: Opacity(
          opacity: opacity,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(
              isLeft ? 1.0 : -1.0,
              isTop ? 1.0 : -1.0,
              1.0,
            ),
            child: CustomPaint(
              size: Size(size, size),
              painter: _BotanicalFrondPainter(
                color: color ?? AppColors.fernGreen,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BotanicalFrondPainter extends CustomPainter {
  final Color color;
  _BotanicalFrondPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final leafFill = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // Main curved stem frond
    final stem = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(size.width * 0.45, size.height * 0.1, size.width * 0.85, size.height * 0.75);
    canvas.drawPath(stem, paint);

    // Leaves branching along the stem
    const int leafPairs = 7;
    for (int i = 1; i <= leafPairs; i++) {
      final t = i / (leafPairs + 1);
      final stemX = math.pow(1 - t, 2) * 0 + 2 * (1 - t) * t * (size.width * 0.45) + math.pow(t, 2) * (size.width * 0.85);
      final stemY = math.pow(1 - t, 2) * 0 + 2 * (1 - t) * t * (size.height * 0.1) + math.pow(t, 2) * (size.height * 0.75);

      final leafLength = (size.width * 0.22) * (1.1 - (t * 0.4));

      // Right leaf
      final rightLeaf = Path()
        ..moveTo(stemX, stemY)
        ..quadraticBezierTo(
          stemX + leafLength * 0.8,
          stemY - leafLength * 0.3,
          stemX + leafLength,
          stemY + leafLength * 0.2,
        )
        ..quadraticBezierTo(
          stemX + leafLength * 0.3,
          stemY + leafLength * 0.4,
          stemX,
          stemY,
        );
      canvas.drawPath(rightLeaf, leafFill);
      canvas.drawPath(rightLeaf, paint..strokeWidth = 1.0);

      // Left leaf
      final leftLeaf = Path()
        ..moveTo(stemX, stemY)
        ..quadraticBezierTo(
          stemX - leafLength * 0.5,
          stemY + leafLength * 0.7,
          stemX - leafLength * 0.9,
          stemY + leafLength * 0.3,
        )
        ..quadraticBezierTo(
          stemX - leafLength * 0.4,
          stemY - leafLength * 0.1,
          stemX,
          stemY,
        );
      canvas.drawPath(leftLeaf, leafFill);
      canvas.drawPath(leftLeaf, paint..strokeWidth = 1.0);
    }
  }

  @override
  bool shouldRepaint(covariant _BotanicalFrondPainter oldDelegate) => oldDelegate.color != color;
}

/// Handcrafted Washi-Tape Strip for pinning cards
class WashiTape extends StatelessWidget {
  final double width;
  final double height;
  final double rotationAngle; // radians
  final double? angle;
  final Color? color;
  final Widget? child;

  const WashiTape({
    super.key,
    this.width = 72.0,
    this.height = 18.0,
    this.rotationAngle = -0.035, // ~ -2 degrees
    this.angle,
    this.color,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAngle = angle ?? rotationAngle;

    if (child != null) {
      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          child!,
          Positioned(
            top: -height / 2,
            child: _buildTape(effectiveAngle),
          ),
        ],
      );
    }

    return _buildTape(effectiveAngle);
  }

  Widget _buildTape(double rotAngle) {
    final tapeColor = color ?? AppColors.washiTape.withValues(alpha: 0.88);

    return Transform.rotate(
      angle: rotAngle,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: tapeColor,
          borderRadius: BorderRadius.circular(2),
          border: Border.symmetric(
            vertical: BorderSide(
              color: Colors.black.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 3,
              offset: const Offset(0, 1.5),
            ),
          ],
        ),
        child: CustomPaint(
          painter: _WashiTexturePainter(),
        ),
      ),
    );
  }
}

class _WashiTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 0.8;

    // Subtle fibrous horizontal grain lines
    for (double y = 3; y < size.height; y += 4) {
      canvas.drawLine(Offset(4, y), Offset(size.width - 4, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Round Wax / Seal Stamp Badge for Verification & AHP Rankings
class SealBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final double size;
  final Color color;
  final Color textColor;
  final bool isVerified;

  const SealBadge({
    super.key,
    String? text,
    String? label,
    this.icon,
    this.size = 56.0,
    this.color = AppColors.diwaliGold,
    this.textColor = Colors.white,
    this.isVerified = false,
  }) : text = label ?? text ?? "SEAL";

  factory SealBadge.verified({double size = 48.0}) {
    return SealBadge(
      text: "VERIFIED",
      icon: Icons.shield_rounded,
      size: size,
      color: AppColors.primaryForest,
      textColor: AppColors.parchment,
      isVerified: true,
    );
  }

  factory SealBadge.ahpRank(int rank, {double size = 44.0}) {
    Color sealColor = AppColors.diwaliGold;
    if (rank == 2) sealColor = const Color(0xFF90A4AE); // Silver
    if (rank == 3) sealColor = AppColors.terracotta; // Bronze

    return SealBadge(
      text: "#$rank",
      icon: rank == 1 ? Icons.workspace_premium_rounded : null,
      size: size,
      color: sealColor,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Fluted seal ring
          CustomPaint(
            size: Size(size, size),
            painter: _SealFlutePainter(color: Colors.white.withValues(alpha: 0.3)),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) Icon(icon, size: size * 0.32, color: textColor),
              Text(
                text,
                style: AppTextStyles.eyebrow(color: textColor).copyWith(
                  fontSize: size * 0.18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SealFlutePainter extends CustomPainter {
  final Color color;
  _SealFlutePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4.0;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _SealFlutePainter oldDelegate) => oldDelegate.color != color;
}

/// Soft Glowing Sun-Disc Gradient for Hero Sections
class SunDiscGlow extends StatelessWidget {
  final double radius;
  final Widget? child;
  final Color glowColor;

  const SunDiscGlow({
    super.key,
    this.radius = 160.0,
    this.child,
    this.glowColor = AppColors.diwaliGold,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.0, -0.6),
          radius: 0.9,
          colors: [
            glowColor.withValues(alpha: 0.16),
            glowColor.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
      ),
      child: child,
    );
  }
}

/// Dotted Handcrafted Sketch Divider
class DottedSketchDivider extends StatelessWidget {
  final Color color;
  final double height;
  final double dotRadius;
  final double spacing;

  const DottedSketchDivider({
    super.key,
    this.color = AppColors.border,
    this.height = 20.0,
    this.dotRadius = 1.5,
    this.spacing = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: CustomPaint(
          size: const Size(double.infinity, 2),
          painter: _DottedLinePainter(
            color: color,
            dotRadius: dotRadius,
            spacing: spacing,
          ),
        ),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  final Color color;
  final double dotRadius;
  final double spacing;

  _DottedLinePainter({
    required this.color,
    required this.dotRadius,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    double startX = 0;
    final y = size.height / 2;
    while (startX < size.width) {
      canvas.drawCircle(Offset(startX, y), dotRadius, paint);
      startX += spacing;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLinePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.dotRadius != dotRadius ||
      oldDelegate.spacing != spacing;
}

/// Warm Parchment Background Scaffold Wrapper with optional corner ferns
class ParchmentScaffoldWrapper extends StatelessWidget {
  final Widget child;
  final bool showFerns;
  final bool showFernTopLeft;
  final bool showFernBottomRight;

  const ParchmentScaffoldWrapper({
    super.key,
    required this.child,
    this.showFerns = true,
    this.showFernTopLeft = true,
    this.showFernBottomRight = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.parchment,
      child: Stack(
        children: [
          if (showFerns && showFernTopLeft)
            const BotanicalFernCorner(
              alignment: Alignment.topLeft,
              size: 160,
              opacity: 0.10,
            ),
          if (showFerns && showFernBottomRight)
            const BotanicalFernCorner(
              alignment: Alignment.bottomRight,
              size: 180,
              opacity: 0.10,
            ),
          child,
        ],
      ),
    );
  }
}
