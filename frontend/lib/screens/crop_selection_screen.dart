import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';
import '../theme/language_selector.dart';

class CropSelectionScreen extends StatefulWidget {
  const CropSelectionScreen({super.key});

  @override
  State<CropSelectionScreen> createState() => _CropSelectionScreenState();
}

class _CropSelectionScreenState extends State<CropSelectionScreen> {
  late List<String> _selected;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _coreCrops = [
    {
      "name": "Onion",
      "marathi": "कांदा",
      "hindi": "प्याज",
      "sci": "Allium cepa",
      "duration": "120 Days",
      "season": "Rabi / Kharif",
      "icon": Icons.circle_outlined,
      "desc_en": "Short duration cash crop, high domestic liquidity in Nashik/Pune markets.",
      "desc_mr": "कमी कालावधीचे नगदी पीक, नाशिक व पुणे बाजारपेठेत उत्तम मागणी.",
      "desc_hi": "कम अवधि की नकदी फसल, नासिक और पुणे मंडियों में उच्च मांग।",
    },
    {
      "name": "Grapes",
      "marathi": "द्राक्षे",
      "hindi": "अंगूर",
      "sci": "Vitis vinifera",
      "duration": "150 Days",
      "season": "Perennial (Oct Pruning)",
      "icon": Icons.grain_rounded,
      "desc_en": "High export value horticulture crop with precision spraying requirements.",
      "desc_mr": "उच्च निर्यात मूल्य असलेले फळपीक, अचूक फवारणी व निगा आवश्यक.",
      "desc_hi": "उच्च निर्यात मूल्य वाली बागवानी फसल, सटीक छिड़काव आवश्यक।",
    },
    {
      "name": "Sugarcane",
      "marathi": "ऊस",
      "hindi": "गन्ना",
      "sci": "Saccharum officinarum",
      "duration": "365 Days",
      "season": "Eksali / Suru",
      "icon": Icons.grass_rounded,
      "desc_en": "Heavy biomass cash crop with canal and drip irrigation support.",
      "desc_mr": "भरपूर उत्पादन देणारे हमखास नगदी पीक, ठिबक व कालवा सिंचन उपयुक्त.",
      "desc_hi": "भरपूर उत्पादन देने वाली प्रमुख नकदी फसल, ड्रिप सिंचाई उपयुक्त।",
    },
    {
      "name": "Wheat",
      "marathi": "गहू",
      "hindi": "गेहूं",
      "sci": "Triticum aestivum",
      "duration": "110 Days",
      "season": "Rabi",
      "icon": Icons.spa_rounded,
      "desc_en": "Dependable winter cereal with low input costs and high food security.",
      "desc_mr": "कमी खर्चात हमखास उत्पादन देणारे रब्बी अन्नधान्य पीक.",
      "desc_hi": "कम लागत में विश्वसनीय रबी खाद्यान्न फसल।",
    },
  ];

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _selected = List<String>.from(appState.selectedCrops);
  }

  void _saveCrops() async {
    final lang = Provider.of<AppState>(context, listen: false).language;

    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang == 'en' ? "You must select at least one crop" : "किमान एक पीक निवडणे आवश्यक आहे")),
      );
      return;
    }

    setState(() => _isSaving = true);
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.updateSelectedCrops(_selected);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang == 'en' ? "Selected crops updated in profile successfully!" : "पिकांची निवड यशस्वीरीत्या जतन केली!"),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final lang = appState.language;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get("selected_crops_title", lang)),
        actions: const [
          LanguageSelectorButton(),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          lang == 'en' ? "4 Core Supported Crops" : "४ मुख्य प्रमाणित पिके",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.surfaceDark,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.demoBadgeBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.demoBadgeText.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            AppStrings.get("verified_demo", lang),
                            style: const TextStyle(
                              color: AppTheme.demoBadgeText,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lang == 'en'
                          ? "Select all crops currently cultivated on your farm to receive targeted stage advisories and spray safety indices."
                          : "तुमच्या शेतात घेत असलेली पिके निवडा, जेणेकरून अचूक कृषी सल्ला व फवारणी वेळ मिळेल.",
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    ..._coreCrops.map((crop) {
                      final name = crop["name"] as String;
                      final localName = lang == 'hi' ? crop["hindi"] : (lang == 'mr' ? crop["marathi"] : name);
                      final sci = crop["sci"] as String;
                      final duration = crop["duration"] as String;
                      final season = crop["season"] as String;
                      final icon = crop["icon"] as IconData;
                      final desc = lang == 'hi' ? crop["desc_hi"] : (lang == 'mr' ? crop["desc_mr"] : crop["desc_en"]);
                      final isSelected = _selected.contains(name);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                if (_selected.length > 1) {
                                  _selected.remove(name);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(lang == 'en' ? "At least one crop must remain selected" : "किमान एक पीक निवडणे आवश्यक आहे")),
                                  );
                                }
                              } else {
                                _selected.add(name);
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  activeColor: AppTheme.primaryGreen,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        _selected.add(name);
                                      } else {
                                        if (_selected.length > 1) {
                                          _selected.remove(name);
                                        }
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(icon, color: AppTheme.primaryGreen, size: 22),
                                          const SizedBox(width: 8),
                                          Text(
                                            "$localName ($name)",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: AppTheme.surfaceDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        sci,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        desc,
                                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          _buildBadge(Icons.calendar_today_outlined, duration),
                                          const SizedBox(width: 8),
                                          _buildBadge(Icons.wb_sunny_outlined, season),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  )
                ],
              ),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveCrops,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text("${AppStrings.get("save", lang)} (${_selected.length})"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.primaryGreen),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
