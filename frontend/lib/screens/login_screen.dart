import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';
import '../theme/language_selector.dart';
import '../widgets/agriintel_logo.dart';
import '../widgets/organic_decorations.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _inlineError;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final lang = Provider.of<AppState>(context, listen: false).language;
    final mobile = _mobileController.text.trim();
    final password = _passwordController.text.trim();

    if (mobile.isEmpty || password.isEmpty) {
      setState(() {
        _inlineError = lang == 'en'
            ? "Please enter mobile number/email and password"
            : "कृपया मोबाईल नंबर/ईमेल आणि पासवर्ड टाका";
      });
      return;
    }

    setState(() {
      _inlineError = null;
      _isLoading = true;
    });

    final appState = Provider.of<AppState>(context, listen: false);
    await appState.login(mobile, password);

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final lang = appState.language;

    return Scaffold(
      backgroundColor: AppColors.parchment,
      body: Stack(
        children: [
          // Background Sun-disc Glow
          const Positioned.fill(
            child: SunDiscGlow(
              radius: 220,
              glowColor: AppColors.diwaliGold,
            ),
          ),

          // Botanical corner ferns
          const BotanicalFernCorner(
            alignment: Alignment.topLeft,
            size: 200,
            opacity: 0.12,
            color: AppColors.primaryForest,
          ),
          const BotanicalFernCorner(
            alignment: Alignment.bottomRight,
            size: 220,
            opacity: 0.12,
            color: AppColors.fernGreen,
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Bar with Logo & Language Switcher
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const AgriIntelLogo(size: 42),
                          const LanguageSelectorButton(isDark: true),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Welcome Hero Header
                      Center(
                        child: Column(
                          children: [
                            Text(
                              "DECISION INTELLIGENCE",
                              style: AppTextStyles.eyebrow(color: AppColors.diwaliGold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              lang == 'en' ? "Welcome to AgriIntel" : "AgriIntel मध्ये आपले स्वागत आहे",
                              style: AppTextStyles.serifTitle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryForest,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              lang == 'en'
                                  ? "Precision AI Advisory & Decision Intelligence for Maharashtra Farmers"
                                  : "महाराष्ट्रातील शेतकऱ्यांसाठी प्रगत एआय कृषी सल्ला व फवारणी यंत्रणा",
                              style: AppTextStyles.body(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Handcrafted Form Card with Washi Tape
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: AppColors.cardCream,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: AppColors.border, width: 1.2),
                              boxShadow: AppShadows.card,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                Text(
                                  AppStrings.get("login_title", lang),
                                  style: AppTextStyles.serifTitle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppStrings.get("login_sub", lang),
                                  style: AppTextStyles.body(
                                    fontSize: 12.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Inline Error Banner
                                if (_inlineError != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                    decoration: BoxDecoration(
                                      color: AppColors.sprayStopBg,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.sprayStopBorder),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline_rounded, size: 18, color: AppColors.sprayStop),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _inlineError!,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.sprayStop,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // Mobile Number Field
                                Text(
                                  AppStrings.get("mobile_no", lang),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _mobileController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.phone_android_rounded, color: AppColors.primaryForest),
                                    hintText: AppStrings.get("login_mobile_hint", lang),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Password Field
                                Text(
                                  AppStrings.get("password", lang),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryForest),
                                    hintText: AppStrings.get("password_hint", lang),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        color: AppColors.textSecondary,
                                      ),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Sign In Button (Primary CTA)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryForest,
                                      foregroundColor: AppColors.parchment,
                                      padding: const EdgeInsets.symmetric(vertical: 15),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      elevation: 2,
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(color: AppColors.parchment, strokeWidth: 2.2),
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                AppStrings.get("btn_sign_in", lang),
                                                style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(Icons.arrow_forward_rounded, size: 18),
                                            ],
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Quick 1-Tap Demo Login Button
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.bolt_rounded, color: AppColors.diwaliGold, size: 20),
                                    label: Text(
                                      AppStrings.get("quick_demo_btn", lang),
                                      style: const TextStyle(
                                        color: AppColors.primaryForest,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: AppColors.goldLight,
                                      side: BorderSide(color: AppColors.diwaliGold.withValues(alpha: 0.6), width: 1.5),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    onPressed: () {
                                      _mobileController.text = "9876543210";
                                      _passwordController.text = "demo_password";
                                      _handleLogin();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Washi tape accent on top edge
                          const Positioned(
                            top: -10,
                            child: WashiTape(width: 86, height: 18, rotationAngle: -0.03),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Switch to Register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.get("new_user_question", lang),
                            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => const RegisterScreen(),
                                  transitionsBuilder: (_, animation, __, child) =>
                                      SlideTransition(
                                    position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                                        .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                                    child: child,
                                  ),
                                  transitionDuration: const Duration(milliseconds: 350),
                                ),
                              );
                            },
                            child: Text(
                              AppStrings.get("register_now", lang),
                              style: const TextStyle(
                                color: AppColors.primaryForest,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
