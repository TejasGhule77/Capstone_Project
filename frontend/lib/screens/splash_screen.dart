import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/agriintel_logo.dart';
import '../widgets/organic_decorations.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainAnimController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late AnimationController _fernSwayController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _mainAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _mainAnimController,
      curve: Curves.easeOutBack,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _mainAnimController,
      curve: Curves.easeInOut,
    );

    _fernSwayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();

    _mainAnimController.forward();
    _navigateNext();
  }

  void _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _mainAnimController.dispose();
    _fernSwayController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parchment,
      body: Stack(
        children: [
          // Background Sun-disc radial glow
          const Positioned.fill(
            child: SunDiscGlow(
              radius: 260,
              glowColor: AppColors.diwaliGold,
            ),
          ),

          // Swaying Botanical Ferns in corners
          AnimatedBuilder(
            animation: _fernSwayController,
            builder: (context, child) {
              final angle = math.sin(_fernSwayController.value * math.pi * 2) * 0.05;
              return Stack(
                children: [
                  Transform.rotate(
                    angle: angle,
                    alignment: Alignment.topLeft,
                    child: const BotanicalFernCorner(
                      alignment: Alignment.topLeft,
                      size: 220,
                      opacity: 0.16,
                      color: AppColors.primaryForest,
                    ),
                  ),
                  Transform.rotate(
                    angle: -angle,
                    alignment: Alignment.bottomRight,
                    child: const BotanicalFernCorner(
                      alignment: Alignment.bottomRight,
                      size: 240,
                      opacity: 0.16,
                      color: AppColors.fernGreen,
                    ),
                  ),
                ],
              );
            },
          ),

          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Circular Progress Ring enclosing AgriIntel Logo
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer ambient glow ring
                              Container(
                                width: 148,
                                height: 148,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.cardCream,
                                  boxShadow: AppShadows.elevated,
                                  border: Border.all(color: AppColors.border, width: 1.5),
                                ),
                              ),
                              // Circular Progress Track
                              SizedBox(
                                width: 140,
                                height: 140,
                                child: CircularProgressIndicator(
                                  value: _progressController.value,
                                  strokeWidth: 3.5,
                                  backgroundColor: AppColors.sageBg,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryForest),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              // Centered Official Logo
                              const AgriIntelLogo(
                                size: 92,
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      // Brand Heading
                      Text(
                        "AgriIntel",
                        style: AppTextStyles.serifTitle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryForest,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Subtitle
                      Text(
                        "Precision Agriculture AI Decision Engine",
                        style: AppTextStyles.body(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Progress Indicator with percentage
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          final pct = (_progressController.value * 100).toInt();
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.cardCream,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.border),
                              boxShadow: AppShadows.card,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.eco_rounded,
                                  color: AppColors.fernGreen,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Cultivating Smarter Farms… $pct%",
                                  style: AppTextStyles.eyebrow(color: AppColors.primaryForest).copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Tagline
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Smarter Farming • Healthier Tomorrow",
                style: AppTextStyles.eyebrow(color: AppColors.textSecondary).copyWith(
                  fontSize: 11,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
