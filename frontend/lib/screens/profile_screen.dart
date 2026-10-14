import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';
import '../theme/language_selector.dart';
import '../widgets/ui_components.dart';
import 'crop_selection_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  bool _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  late TextEditingController _villageController;
  late TextEditingController _farmSizeController;
  String _selectedDistrict = "Pune";
  String _selectedLanguage = "mr";

  final List<String> _districts = [
    "Pune",
    "Nashik",
    "Kolhapur",
    "Sangli",
    "Satara",
    "Solapur",
    "Ahmednagar"
  ];

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser;

    _nameController = TextEditingController(text: user?.name ?? "Farmer");
    _mobileController = TextEditingController(text: user?.mobile ?? "");
    _emailController = TextEditingController(text: user?.email ?? "");
    _villageController = TextEditingController(text: user?.village ?? "Pune");
    _farmSizeController = TextEditingController(text: (user?.farmSizeAcres ?? 3.0).toString());
    _selectedDistrict = user?.district ?? "Pune";
    _selectedLanguage = appState.language;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _villageController.dispose();
    _farmSizeController.dispose();
    super.dispose();
  }

  void _syncControllersWithUser() {
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser;
    if (user != null && !_isEditing) {
      _nameController.text = user.name;
      _mobileController.text = user.mobile;
      _emailController.text = user.email ?? "";
      _villageController.text = user.village;
      _farmSizeController.text = user.farmSizeAcres.toString();
      _selectedDistrict = user.district;
      _selectedLanguage = appState.language;
    }
  }

  void _saveProfile() async {
    setState(() => _isSaving = true);
    final appState = Provider.of<AppState>(context, listen: false);
    final current = appState.currentUser;
    final lang = appState.language;

    if (current != null) {
      final updated = current.copyWith(
        name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : current.name,
        mobile: _mobileController.text.trim().isNotEmpty ? _mobileController.text.trim() : current.mobile,
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : current.email,
        village: _villageController.text.trim().isNotEmpty ? _villageController.text.trim() : current.village,
        district: _selectedDistrict,
        farmSizeAcres: double.tryParse(_farmSizeController.text.trim()) ?? current.farmSizeAcres,
        language: _selectedLanguage,
      );

      await appState.updateProfile(updated);
      appState.setLanguage(_selectedLanguage);
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get("profile_updated", lang)),
          backgroundColor: AppColors.primaryForest,
        ),
      );
    }
  }

  void _handleLogout() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    final lang = appState.language;

    if (!_isEditing) {
      _syncControllersWithUser();
    }

    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        backgroundColor: AppColors.primaryForest,
        foregroundColor: AppColors.parchment,
        title: Text(
          AppStrings.get("profile_title", lang),
          style: AppTextStyles.serifTitle(fontSize: 18, color: AppColors.parchment),
        ),
        actions: [
          const LanguageSelectorButton(isDark: false),
          IconButton(
            icon: Icon(_isEditing ? Icons.check_circle_rounded : Icons.edit_rounded, color: AppColors.parchment),
            tooltip: _isEditing ? AppStrings.get("save", lang) : AppStrings.get("personal_details", lang),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Avatar & Name Card with Washi Tape
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
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [AppColors.primaryForest, AppColors.fernGreen],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryForest.withValues(alpha: 0.25),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: SizedBox(
                                      width: 78,
                                      height: 78,
                                      child: Image.asset(
                                        'assets/images/farmer_ecrop.jpg',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Center(
                                          child: Text(
                                            (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : "F",
                                            style: const TextStyle(color: AppColors.parchment, fontSize: 34, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.cardCream,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.verified_rounded, color: AppColors.fernGreen, size: 20),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              user?.name ?? "Farmer",
                              style: AppTextStyles.serifTitle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${user?.village ?? ''}, ${user?.district ?? ''} • ${user?.farmSizeAcres ?? 0} ${lang == 'en' ? 'Acres' : 'एकर'}",
                              style: AppTextStyles.body(
                                fontSize: 13.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: user?.verificationStatus == "VERIFIED" ? AppColors.sprayGoodBg : AppColors.demoBadgeBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: user?.verificationStatus == "VERIFIED" ? AppColors.sprayGoodBorder : AppColors.demoBadgeText.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                user?.verificationStatus == "VERIFIED"
                                    ? (lang == 'en' ? "VERIFIED FARMER" : "सत्यापित शेतकरी")
                                    : AppStrings.get("verified_demo", lang),
                                style: TextStyle(
                                  color: user?.verificationStatus == "VERIFIED" ? AppColors.primaryForest : AppColors.demoBadgeText,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
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

                  // Profile Form Fields Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardCream,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.border, width: 1.2),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: AppStrings.get("personal_details", lang),
                          eyebrow: "Account",
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 14),
                        // Name
                        _buildTextField(AppStrings.get("farmer_full_name", lang), _nameController, Icons.person_outline, enabled: _isEditing),
                        const SizedBox(height: 12),
                        // Mobile
                        _buildTextField(AppStrings.get("mobile_no", lang), _mobileController, Icons.phone_android, enabled: _isEditing),
                        const SizedBox(height: 12),
                        // Email
                        _buildTextField(AppStrings.get("email_addr", lang), _emailController, Icons.email_outlined, enabled: _isEditing),
                        const SizedBox(height: 18),

                        const DottedSketchDivider(height: 24),

                        SectionHeader(
                          title: AppStrings.get("farm_location_details", lang),
                          eyebrow: "Land & Soil",
                          icon: Icons.landscape_outlined,
                        ),
                        const SizedBox(height: 14),
                        // District Dropdown
                        Text(AppStrings.get("district", lang), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _districts.contains(_selectedDistrict) ? _selectedDistrict : _districts.first,
                          dropdownColor: AppColors.cardCream,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primaryForest),
                            filled: true,
                            fillColor: _isEditing ? AppColors.cardCream : AppColors.parchment,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(color: AppColors.textPrimary)))).toList(),
                          onChanged: _isEditing ? (val) => setState(() => _selectedDistrict = val!) : null,
                        ),
                        const SizedBox(height: 12),
                        // Village
                        _buildTextField(AppStrings.get("village_taluka", lang), _villageController, Icons.holiday_village_outlined, enabled: _isEditing),
                        const SizedBox(height: 12),
                        // Farm Size
                        _buildTextField(AppStrings.get("total_farm_size", lang), _farmSizeController, Icons.square_foot_rounded, enabled: _isEditing),
                        const SizedBox(height: 18),

                        const DottedSketchDivider(height: 24),

                        // Language Selection Option inside Form
                        Text(AppStrings.get("app_language", lang), style: AppTextStyles.serifTitle(fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(value: "mr", label: Text("मराठी", style: TextStyle(fontWeight: FontWeight.bold))),
                              ButtonSegment(value: "hi", label: Text("हिंदी", style: TextStyle(fontWeight: FontWeight.bold))),
                              ButtonSegment(value: "en", label: Text("English", style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            selected: {_selectedLanguage},
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return AppColors.primaryForest.withValues(alpha: 0.15);
                                }
                                return Colors.transparent;
                              }),
                              foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return AppColors.primaryForest;
                                }
                                return AppColors.textPrimary;
                              }),
                            ),
                            onSelectionChanged: (newSelection) {
                              final selected = newSelection.first;
                              setState(() => _selectedLanguage = selected);
                              appState.setLanguage(selected);
                            },
                          ),
                        ),
                        const SizedBox(height: 18),

                        const DottedSketchDivider(height: 24),

                        // Selected Crops Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppStrings.get("selected_crops_title", lang), style: AppTextStyles.serifTitle(fontSize: 15, fontWeight: FontWeight.bold)),
                            TextButton.icon(
                              icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primaryForest),
                              label: Text(AppStrings.get("manage_crops", lang), style: const TextStyle(color: AppColors.primaryForest, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const CropSelectionScreen()));
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (user?.selectedCrops ?? ["Grapes", "Onion"]).map((c) {
                            final localized = AppStrings.cropName(c, lang);
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.sageBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.fernGreen.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.eco_rounded, size: 16, color: AppColors.primaryForest),
                                  const SizedBox(width: 6),
                                  Text("$localized ($c)", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  if (_isEditing) ...[
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryForest,
                        foregroundColor: AppColors.parchment,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isSaving
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.parchment, strokeWidth: 2))
                          : Text(AppStrings.get("save_profile", lang), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Logout Button
                  OutlinedButton.icon(
                    icon: const Icon(Icons.logout_rounded, color: AppColors.sprayStop),
                    label: Text(AppStrings.get("sign_out_btn", lang), style: const TextStyle(color: AppColors.sprayStop, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.sprayStop, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _handleLogout,
                  ),

                  const SizedBox(height: 24),

                  // Brand Footer
                  Center(
                    child: Column(
                      children: [
                        const AgriIntelLogo(size: 34),
                        const SizedBox(height: 6),
                        Text(
                          "AgriIntel • Maharashtra Precision AI",
                          style: AppTextStyles.eyebrow(color: AppColors.textSecondary).copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primaryForest),
            fillColor: enabled ? AppColors.cardCream : AppColors.parchment,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
