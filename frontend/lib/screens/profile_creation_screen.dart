import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';
import '../theme/language_selector.dart';
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
  bool _isLoading = false;

  final List<String> _districts = [
    "Pune",
    "Nashik",
    "Kolhapur",
    "Sangli",
    "Satara",
    "Solapur",
    "Ahmednagar"
  ];

  final List<Map<String, dynamic>> _availableCrops = [
    {"name": "Onion", "marathi": "कांदा", "hindi": "प्याज", "icon": Icons.circle_outlined},
    {"name": "Grapes", "marathi": "द्राक्षे", "hindi": "अंगूर", "icon": Icons.grain_rounded},
    {"name": "Sugarcane", "marathi": "ऊस", "hindi": "गन्ना", "icon": Icons.grass_rounded},
    {"name": "Wheat", "marathi": "गहू", "hindi": "गेहूं", "icon": Icons.spa_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _villageController = TextEditingController();
    _farmSizeController = TextEditingController();
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
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final appState = Provider.of<AppState>(context, listen: false);

    final village = _villageController.text.trim().isNotEmpty
        ? _villageController.text.trim()
        : _selectedDistrict;
    final farmSize = double.tryParse(_farmSizeController.text.trim()) ?? 3.0;

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
    };

    await appState.register(payload);

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final lang = appState.language;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get("step_2_title", lang)),
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
                AppStrings.get("farm_location_details", lang),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.surfaceDark),
              ),
              const SizedBox(height: 6),
              Text(
                lang == 'en'
                    ? "This allows AgriIntel to tailor micro-climate weather gatekeeper alerts for your fields."
                    : "या माहितीमुळे ॲग्रीइंटेल आपल्या शेतासाठी योग्य हवामान व फवारणी सल्ला देईल.",
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              // District
              Text(AppStrings.get("district", lang), style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedDistrict,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                items: _districts
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedDistrict = val);
                },
              ),
              const SizedBox(height: 16),
              // Village
              Text(AppStrings.get("village_taluka", lang), style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _villageController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.holiday_village_outlined),
                  hintText: "e.g. Junnar / Baramati",
                ),
              ),
              const SizedBox(height: 16),
              // Farm Size
              Text(AppStrings.get("total_farm_size", lang), style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _farmSizeController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.square_foot_rounded),
                  hintText: "e.g. 4.5",
                ),
              ),
              const SizedBox(height: 24),
              // Crop Selection Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.get("selected_crops_title", lang),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.demoBadgeBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(lang == 'en' ? "4 Crops" : "४ मुख्य पिके", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.demoBadgeText)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableCrops.map((crop) {
                  final name = crop["name"] as String;
                  final localCrop = lang == 'hi' ? crop["hindi"] : (lang == 'mr' ? crop["marathi"] : name);
                  final icon = crop["icon"] as IconData;
                  final isSelected = _selectedCrops.contains(name);

                  return FilterChip(
                    avatar: Icon(
                      icon,
                      color: isSelected ? Colors.white : AppTheme.primaryGreen,
                      size: 20,
                    ),
                    label: Text(
                      "$localCrop ($name)",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppTheme.surfaceDark,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryGreen,
                    backgroundColor: Colors.white,
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCrops.add(name);
                        } else {
                          if (_selectedCrops.length > 1) {
                            _selectedCrops.remove(name);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(lang == 'en' ? "At least one crop must remain selected" : "किमान एक पीक निवडणे आवश्यक आहे")),
                            );
                          }
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfileAndRegister,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(AppStrings.get("complete_setup", lang)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
