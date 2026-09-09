import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';
import '../theme/language_selector.dart';
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
          backgroundColor: AppTheme.primaryGreen,
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
      appBar: AppBar(
        title: Text(AppStrings.get("profile_title", lang)),
        actions: [
          const LanguageSelectorButton(),
          IconButton(
            icon: Icon(_isEditing ? Icons.check_rounded : Icons.edit_rounded),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar & Name Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppTheme.primaryGreen,
                        child: Text(
                          (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : "F",
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.name ?? "Farmer",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.surfaceDark),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${user?.village ?? ''}, ${user?.district ?? ''} • ${user?.farmSizeAcres ?? 0} ${lang == 'en' ? 'Acres' : 'एकर'}",
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: user?.verificationStatus == "VERIFIED" ? Colors.green.shade50 : AppTheme.demoBadgeBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: user?.verificationStatus == "VERIFIED" ? Colors.green.shade300 : AppTheme.demoBadgeText.withValues(alpha: 0.3)
                          ),
                        ),
                        child: Text(
                          user?.verificationStatus == "VERIFIED" 
                              ? (lang == 'en' ? "VERIFIED FARMER" : "सत्यापित शेतकरी")
                              : AppStrings.get("verified_demo", lang),
                          style: TextStyle(
                            color: user?.verificationStatus == "VERIFIED" ? Colors.green.shade800 : AppTheme.demoBadgeText,
                            fontSize: 11,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Profile Form Fields
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.get("personal_details", lang),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                      const SizedBox(height: 16),

                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.get("farm_location_details", lang),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 14),
                      // District Dropdown
                      Text(AppStrings.get("district", lang), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _districts.contains(_selectedDistrict) ? _selectedDistrict : _districts.first,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                        onChanged: _isEditing ? (val) => setState(() => _selectedDistrict = val!) : null,
                      ),
                      const SizedBox(height: 12),
                      // Village
                      _buildTextField(AppStrings.get("village_taluka", lang), _villageController, Icons.holiday_village_outlined, enabled: _isEditing),
                      const SizedBox(height: 12),
                      // Farm Size
                      _buildTextField(AppStrings.get("total_farm_size", lang), _farmSizeController, Icons.square_foot_rounded, enabled: _isEditing),
                      const SizedBox(height: 16),

                      const Divider(),
                      const SizedBox(height: 8),

                      // Language Selection Option inside Form
                      Text(AppStrings.get("app_language", lang), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: "mr", label: Text("मराठी")),
                          ButtonSegment(value: "hi", label: Text("हिंदी")),
                          ButtonSegment(value: "en", label: Text("English")),
                        ],
                        selected: {_selectedLanguage},
                        onSelectionChanged: (newSelection) {
                          final selected = newSelection.first;
                          setState(() => _selectedLanguage = selected);
                          appState.setLanguage(selected);
                        },
                      ),
                      const SizedBox(height: 16),

                      const Divider(),
                      const SizedBox(height: 8),
                      // Selected Crops Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppStrings.get("selected_crops_title", lang), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          TextButton.icon(
                            icon: const Icon(Icons.edit, size: 16),
                            label: Text(AppStrings.get("manage_crops", lang)),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const CropSelectionScreen()));
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: (user?.selectedCrops ?? ["Grapes", "Onion"]).map((c) {
                          final localized = AppStrings.cropName(c, lang);
                          return Chip(
                            avatar: const Icon(Icons.eco, size: 16, color: AppTheme.primaryGreen),
                            label: Text("$localized ($c)", style: const TextStyle(fontWeight: FontWeight.bold)),
                            backgroundColor: Colors.green.shade50,
                            side: BorderSide(color: Colors.green.shade200),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (_isEditing) ...[
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  child: _isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(AppStrings.get("save_profile", lang)),
                ),
                const SizedBox(height: 12),
              ],

              // Logout Button
              OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded, color: Colors.red),
                label: Text(AppStrings.get("sign_out_btn", lang), style: const TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
                onPressed: _handleLogout,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            fillColor: enabled ? Colors.white : Colors.grey.shade100,
          ),
        ),
      ],
    );
  }
}
