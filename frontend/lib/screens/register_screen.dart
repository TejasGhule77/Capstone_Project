import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';
import '../theme/language_selector.dart';
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

  void _proceedToProfile() {
    final lang = Provider.of<AppState>(context, listen: false).language;

    if (_nameController.text.trim().isEmpty || _mobileController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang == 'en' ? "Please fill in Name and Mobile Number" : "कृपया नाव आणि मोबाईल नंबर टाका"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_passwordController.text.trim().length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang == 'en' ? "Password must be at least 4 characters" : "पासवर्ड किमान ४ अक्षरांचा असावा"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileCreationScreen(
          initialName: _nameController.text.trim(),
          initialMobile: _mobileController.text.trim(),
          initialEmail: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
          password: _passwordController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final lang = appState.language;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get("register_title", lang)),
        actions: const [
          LanguageSelectorButton(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.get("step_1_title", lang),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.surfaceDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                lang == 'en'
                    ? "Enter your basic credentials to initiate your AgriIntel profile"
                    : "अ‍ॅप सुरू करण्यासाठी आपली वैयक्तिक माहिती प्रविष्ट करा",
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              // Full Name
              Text(AppStrings.get("full_name", lang), style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  hintText: AppStrings.get("full_name_hint", lang),
                ),
              ),
              const SizedBox(height: 16),
              // Mobile
              Text(AppStrings.get("mobile_no", lang), style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.phone_android_rounded),
                  hintText: AppStrings.get("login_mobile_hint", lang),
                ),
              ),
              const SizedBox(height: 16),
              // Email
              Text(AppStrings.get("email_addr", lang), style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined),
                  hintText: "farmer@example.com",
                ),
              ),
              const SizedBox(height: 16),
              // Password
              Text(AppStrings.get("password", lang), style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  hintText: AppStrings.get("password_hint", lang),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _proceedToProfile,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.get("next_step", lang)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
