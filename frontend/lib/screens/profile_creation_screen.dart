import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';
import '../theme/language_selector.dart';
import '../widgets/organic_decorations.dart';
import 'home_screen.dart';

class ProfileCreationScreen extends StatefulWidget {
  final String initialName;
  final String initialMobile;
  final String? initialEmail;
  final String password;

  const ProfileCreationScreen({
    super.key,
    required this.initialName,
    required this.initialMobile,
    this.initialEmail,
    required this.password,
  });

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  late TextEditingController _villageController;
  late TextEditingController _farmSizeController;
  String _selectedDistrict = "Pune";
  final List<String> _selectedCrops = ["Grapes", "Onion"];
  String _selectedIrrigation = "Drip";
  String _selectedSoil = "Black Clay (Regur)";
  bool _isLoading = false;

  final List<String> _districts = [
    "Pune",
    "Nashik",
    "Kolhapur",
    "Sangli",
    "Satara",
    "Solapur",
    "Ahmednagar",
    "Nagpur",
    "Chhatrapati Sambhajinagar",
    "Jalgaon",
  ];

  final List<Map<String, dynamic>> _availableCrops = [
    {"name": "Onion", "marathi": "कांदा", "hindi": "प्याज", "icon": Icons.circle_outlined, "color": Color(0xFFC8643C)},
    {"name": "Grapes", "marathi": "द्राक्षे", "hindi": "अंगूर", "icon": Icons.grain_rounded, "color": Color(0xFF6A1B9A)},
    {"name": "Sugarcane", "marathi": "ऊस", "hindi": "गन्ना", "icon": Icons.grass_rounded, "color": Color(0xFF2E7D32)},
    {"name": "Wheat", "marathi": "गहू", "hindi": "गेहूं", "icon": Icons.spa_rounded, "color": Color(0xFFE8A33D)},
  ];

  @override
  void initState() {
    super.initState();
    _villageController = TextEditingController();
    _farmSizeController = TextEditingController(text: "3.5");
  }

  @override
  void dispose() {
    _villageController.dispose();
    _farmSizeController.dispose();
    super.dispose();
  }

  void _saveProfileAndRegister() async {
    final lang = Provider.of<AppState>(context, listen: false).language;

    if (_selectedCrops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang == 'en' ? "Please select at least one crop" : "कृपया किमान एक पीक निवडा"),
          backgroundColor: AppColors.sprayStop,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final appState = Provider.of<AppState>(context, listen: false);

    final village = _villageController.text.trim().isNotEmpty
        ? _villageController.text.trim()
        : _selectedDistrict;
    final farmSize = double.tryParse(_farmSizeController.text.trim()) ?? 3.5;

    final payload = {
      "name": widget.initialName,
      "mobile": widget.initialMobile,
      "email": widget.initialEmail,
      "password": widget.password,
      "village": village,
      "district": _selectedDistrict,
      "farm_size_acres": farmSize,
      "selected_crops": _selectedCrops,
      "language": appState.language,
      "soil_type": _selectedSoil,
      "irrigation": _selectedIrrigation,
    };

    await appState.register(payload);

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
        ),
        (route) => false,
      );
    }
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
          AppStrings.get("step_2_title", lang),
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
                            "2",
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
                              AppStrings.get("step_2_title", lang),
                              style: AppTextStyles.serifTitle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              lang == 'en' ? "Step 2 of 2: Farm & Crops Profile" : "पायरी २/२: शेती व पीक तपशील",
                              style: AppTextStyles.eyebrow(color: AppColors.diwaliGold).copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Sectioned Card with Washi Tape
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
                            // District Dropdown
                            Text(
                              AppStrings.get("district", lang),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _districts.contains(_selectedDistrict) ? _selectedDistrict : _districts.first,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primaryForest),
                              ),
                              dropdownColor: AppColors.cardCream,
                              items: _districts.map((d) {
                                return DropdownMenuItem(
                                  value: d,
                                  child: Text("$d, Maharashtra", style: const TextStyle(color: AppColors.textPrimary)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedDistrict = val);
                              },
                            ),
                            const SizedBox(height: 16),

                            // Village / Taluka
                            Text(
                              AppStrings.get("village_taluka", lang),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _villageController,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.holiday_village_outlined, color: AppColors.primaryForest),
                                hintText: lang == 'en' ? "Enter your village / town" : "गावाचे किंवा तालुक्याचे नाव टाका",
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Total Farm Size
                            Text(
                              AppStrings.get("total_farm_size", lang),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _farmSizeController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.square_foot_rounded, color: AppColors.primaryForest),
                                suffixText: lang == 'en' ? "Acres" : "एकर",
                                suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryForest),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Soil & Irrigation Details
                            Text(
                              lang == 'en' ? "Soil Type & Irrigation" : "माती प्रकार व सिंचन व्यवस्था",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildDetailChip("Black Clay", Icons.terrain_rounded, _selectedSoil.contains("Black"), () {
                                  setState(() => _selectedSoil = "Black Clay (Regur)");
                                }),
                                _buildDetailChip("Red Loam", Icons.terrain_outlined, _selectedSoil.contains("Red"), () {
                                  setState(() => _selectedSoil = "Red Loam");
                                }),
                                _buildDetailChip("Drip", Icons.water_drop_outlined, _selectedIrrigation == "Drip", () {
                                  setState(() => _selectedIrrigation = "Drip");
                                }),
                                _buildDetailChip("Sprinkler", Icons.shower_outlined, _selectedIrrigation == "Sprinkler", () {
                                  setState(() => _selectedIrrigation = "Sprinkler");
                                }),
                                _buildDetailChip("Flood", Icons.waves_outlined, _selectedIrrigation == "Flood", () {
                                  setState(() => _selectedIrrigation = "Flood");
                                }),
                              ],
                            ),

                            const DottedSketchDivider(height: 28),

                            // Crop Selection Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppStrings.get("selected_crops_title", lang),
                                  style: AppTextStyles.serifTitle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "(${_selectedCrops.length} ${lang == 'en' ? 'selected' : 'निवडली'})",
                                  style: AppTextStyles.eyebrow(color: AppColors.primaryForest).copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _availableCrops.map((cropMap) {
                                final String name = cropMap['name'];
                                final bool isSelected = _selectedCrops.contains(name);
                                final String localized = AppStrings.cropName(name, lang);
                                final Color cropCol = cropMap['color'];

                                return FilterChip(
                                  avatar: Icon(
                                    cropMap['icon'],
                                    size: 18,
                                    color: isSelected ? AppColors.parchment : cropCol,
                                  ),
                                  label: Text("$localized ($name)"),
                                  selected: isSelected,
                                  selectedColor: AppColors.primaryForest,
                                  backgroundColor: AppColors.cardCream,
                                  checkmarkColor: AppColors.parchment,
                                  labelStyle: TextStyle(
                                    color: isSelected ? AppColors.parchment : AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: isSelected ? AppColors.primaryForest : AppColors.border,
                                    ),
                                  ),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedCrops.add(name);
                                      } else {
                                        if (_selectedCrops.length > 1) {
                                          _selectedCrops.remove(name);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(lang == 'en' ? "At least one crop must be selected" : "किमान एक पीक निवडणे आवश्यक आहे"),
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 28),

                            // Complete Setup Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _saveProfileAndRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryForest,
                                  foregroundColor: AppColors.parchment,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                                          const Icon(Icons.check_circle_outline_rounded, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            AppStrings.get("complete_setup", lang),
                                            style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold),
                                          ),
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

  Widget _buildDetailChip(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryForest : AppColors.sageBg.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryForest : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? AppColors.parchment : AppColors.primaryForest),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.parchment : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
