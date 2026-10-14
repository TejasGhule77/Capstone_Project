import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';
import '../theme/language_selector.dart';
import '../widgets/organic_decorations.dart';
import 'profile_creation_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _proceedToProfile() {
    final lang = Provider.of<AppState>(context, listen: false).language;

    if (_nameController.text.trim().isEmpty || _mobileController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang == 'en' ? "Please fill in Name and Mobile Number" : "कृपया नाव आणि मोबाईल नंबर टाका"),
          backgroundColor: AppColors.sprayStop,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_passwordController.text.trim().length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang == 'en' ? "Password must be at least 4 characters" : "पासवर्ड किमान ४ अक्षरांचा असावा"),
          backgroundColor: AppColors.sprayStop,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ProfileCreationScreen(
          initialName: _nameController.text.trim(),
          initialMobile: _mobileController.text.trim(),
          initialEmail: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
          password: _passwordController.text.trim(),
        ),
        transitionsBuilder: (_, animation, __, child) =>
            SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final lang = appState.language;

    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        backgroundColor: AppColors.primaryForest,
        foregroundColor: AppColors.parchment,
        title: Text(
          AppStrings.get("register_title", lang),
          style: AppTextStyles.serifTitle(fontSize: 18, color: AppColors.parchment),
        ),
        actions: const [
          LanguageSelectorButton(isDark: false),
        ],
      ),
      body: Stack(
        children: [
          const BotanicalFernCorner(
            alignment: Alignment.topLeft,
            size: 180,
            opacity: 0.10,
          ),
          const BotanicalFernCorner(
            alignment: Alignment.bottomRight,
            size: 200,
            opacity: 0.10,
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Step Progress Header
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.primaryForest,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryForest.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "1",
                            style: TextStyle(color: AppColors.parchment, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.get("step_1_title", lang),
                              style: AppTextStyles.serifTitle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              lang == 'en' ? "Step 1 of 2: Account Setup" : "पायरी १/२: खाते माहिती",
                              style: AppTextStyles.eyebrow(color: AppColors.diwaliGold).copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Form Card with Washi Tape
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
                            const SizedBox(height: 4),
                            // Full Name
                            Text(
                              AppStrings.get("full_name", lang),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primaryForest),
                                hintText: AppStrings.get("full_name_hint", lang),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Mobile
                            Text(
                              AppStrings.get("mobile_no", lang),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textPrimary),
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

                            // Email
                            Text(
                              AppStrings.get("email_addr", lang),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.email_outlined, color: AppColors.primaryForest),
                                hintText: "farmer@example.com",
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Password
                            Text(
                              AppStrings.get("password", lang),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textPrimary),
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
                            const SizedBox(height: 26),

                            // Next Step Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _proceedToProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryForest,
                                  foregroundColor: AppColors.parchment,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      AppStrings.get("next_step", lang),
                                      style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward_rounded, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Positioned(
                        top: -9,
                        child: WashiTape(width: 80, height: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
