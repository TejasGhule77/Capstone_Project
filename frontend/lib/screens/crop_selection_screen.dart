import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';
import '../theme/language_selector.dart';
import '../widgets/organic_decorations.dart';

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
      "number": "01",
      "name": "Onion",
      "marathi": "कांदा",
      "hindi": "प्याज",
      "sci": "Allium cepa",
      "duration": "120 Days",
      "season": "Rabi / Kharif",
      "icon": Icons.circle_outlined,
      "color": AppColors.terracotta,
      "desc_en": "Short duration cash crop, high domestic liquidity in Nashik/Pune markets.",
      "desc_mr": "कमी कालावधीचे नगदी पीक, नाशिक व पुणे बाजारपेठेत उत्तम मागणी.",
      "desc_hi": "कम अवधि की नकदी फसल, नासिक और पुणे मंडियों में उच्च मांग।",
    },
    {
      "number": "02",
      "name": "Grapes",
      "marathi": "द्राक्षे",
      "hindi": "अंगूर",
      "sci": "Vitis vinifera",
      "duration": "150 Days",
      "season": "Perennial (Oct Pruning)",
      "icon": Icons.grain_rounded,
      "color": Color(0xFF6A1B9A),
      "desc_en": "High export value horticulture crop with precision spraying requirements.",
      "desc_mr": "उच्च निर्यात मूल्य असलेले फळपीक, अचूक फवारणी व निगा आवश्यक.",
      "desc_hi": "उच्च निर्यात मूल्य वाली बागवानी फसल, सटीक छिड़काव आवश्यक।",
    },
    {
      "number": "03",
      "name": "Sugarcane",
      "marathi": "ऊस",
      "hindi": "गन्ना",
      "sci": "Saccharum officinarum",
      "duration": "365 Days",
      "season": "Eksali / Suru",
      "icon": Icons.grass_rounded,
      "color": AppColors.primaryForest,
      "desc_en": "Heavy biomass cash crop with canal and drip irrigation support.",
      "desc_mr": "भरपूर उत्पादन देणारे हमखास नगदी पीक, ठिबक व कालवा सिंचन उपयुक्त.",
      "desc_hi": "भरपूर उत्पादन देने वाली प्रमुख नकदी फसल, ड्रिप सिंचाई उपयुक्त।",
    },
    {
      "number": "04",
      "name": "Wheat",
      "marathi": "गहू",
      "hindi": "गेहूं",
      "sci": "Triticum aestivum",
      "duration": "110 Days",
      "season": "Rabi",
      "icon": Icons.spa_rounded,
      "color": AppColors.diwaliGold,
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
        SnackBar(
          content: Text(lang == 'en' ? "You must select at least one crop" : "किमान एक पीक निवडणे आवश्यक आहे"),
          backgroundColor: AppColors.sprayStop,
        ),
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
          backgroundColor: AppColors.primaryForest,
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
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        backgroundColor: AppColors.primaryForest,
        foregroundColor: AppColors.parchment,
        title: Text(
          AppStrings.get("selected_crops_title", lang),
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
                              style: AppTextStyles.serifTitle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.goldLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.diwaliGold.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                AppStrings.get("verified_demo", lang),
                                style: const TextStyle(
                                  color: Color(0xFF5D3B00),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
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
                          style: AppTextStyles.body(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 18),
                        ..._coreCrops.map((crop) {
                          final num = crop["number"] as String;
                          final name = crop["name"] as String;
                          final localName = lang == 'hi' ? crop["hindi"] : (lang == 'mr' ? crop["marathi"] : name);
                          final sci = crop["sci"] as String;
                          final duration = crop["duration"] as String;
                          final season = crop["season"] as String;
                          final icon = crop["icon"] as IconData;
                          final desc = lang == 'hi' ? crop["desc_hi"] : (lang == 'mr' ? crop["desc_mr"] : crop["desc_en"]);
                          final isSelected = _selected.contains(name);
                          final cropCol = crop["color"] as Color;

                          return Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.topCenter,
                            children: [
                              Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                color: isSelected ? AppColors.cardCream : AppColors.cardCream.withValues(alpha: 0.7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected ? AppColors.primaryForest : AppColors.border,
                                    width: isSelected ? 2.0 : 1.2,
                                  ),
                                ),
                                elevation: isSelected ? 3 : 0,
                                shadowColor: AppColors.primaryForest.withValues(alpha: 0.12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        if (_selected.length > 1) {
                                          _selected.remove(name);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(lang == 'en' ? "At least one crop must remain selected" : "किमान एक पीक निवडणे आवश्यक आहे"),
                                              backgroundColor: AppColors.sprayStop,
                                            ),
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
                                        // Numbered seal badge
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: isSelected ? AppColors.primaryForest : AppColors.sageBg,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected ? AppColors.primaryForest : AppColors.border,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              num,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected ? AppColors.parchment : AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.all(6),
                                                        decoration: BoxDecoration(
                                                          color: cropCol.withValues(alpha: 0.12),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Icon(icon, color: cropCol, size: 18),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        "$localName ($name)",
                                                        style: AppTextStyles.serifTitle(
                                                          fontSize: 16.5,
                                                          fontWeight: FontWeight.bold,
                                                          color: isSelected ? AppColors.primaryForest : AppColors.textPrimary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  // Check Seal
                                                  if (isSelected)
                                                    Container(
                                                      padding: const EdgeInsets.all(4),
                                                      decoration: const BoxDecoration(
                                                        color: AppColors.primaryForest,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(Icons.check_rounded, color: AppColors.parchment, size: 16),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                sci,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontStyle: FontStyle.italic,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                desc,
                                                style: AppTextStyles.body(
                                                  fontSize: 12.5,
                                                  color: AppColors.textPrimary,
                                                  height: 1.35,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
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
                              ),
                              if (isSelected)
                                const Positioned(
                                  top: -6,
                                  right: 24,
                                  child: WashiTape(width: 58, height: 14, rotationAngle: 0.04),
                                ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardCream,
                    border: const Border(top: BorderSide(color: AppColors.border, width: 1.2)),
                    boxShadow: AppShadows.card,
                  ),
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveCrops,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryForest,
                      foregroundColor: AppColors.parchment,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: AppColors.parchment, strokeWidth: 2),
                          )
                        : Text(
                            "${AppStrings.get("save", lang)} (${_selected.length})",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: AppColors.sageBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primaryForest),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
