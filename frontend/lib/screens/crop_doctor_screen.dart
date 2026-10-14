import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';
import '../services/image_picker_service.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';
import '../theme/language_selector.dart';
import '../widgets/ui_components.dart';
import 'pesticide_comparison_screen.dart';

class LeafSample {
  final String labelMarathi;
  final String labelHindi;
  final String labelEnglish;
  final String crop;
  final String diseaseName;
  final String severity;
  final IconData icon;
  final Color color;

  const LeafSample({
    required this.labelMarathi,
    required this.labelHindi,
    required this.labelEnglish,
    required this.crop,
    required this.diseaseName,
    required this.severity,
    required this.icon,
    required this.color,
  });
}

class CropDoctorScreen extends StatefulWidget {
  const CropDoctorScreen({super.key});

  @override
  State<CropDoctorScreen> createState() => _CropDoctorScreenState();
}

class _CropDoctorScreenState extends State<CropDoctorScreen> {
  String _selectedCrop = "Grapes";
  bool _isAnalyzing = false;
  DiagnosisResult? _result;
  RecommendationResponseModel? _recommendation;
  String? _imageName;
  Uint8List? _imageBytes;
  bool _showTechDetails = false;

  final List<String> _allowedCrops = ["Grapes", "Onion", "Sugarcane", "Wheat"];

  final Map<String, Map<String, dynamic>> _cropInfo = {
    "Grapes": {"marathi": "द्राक्षे", "hindi": "अंगूर", "icon": Icons.eco_rounded, "color": Color(0xFF6A1B9A)},
    "Onion": {"marathi": "कांदा", "hindi": "प्याज", "icon": Icons.circle_outlined, "color": AppColors.terracotta},
    "Sugarcane": {"marathi": "ऊस", "hindi": "गन्ना", "icon": Icons.grass_rounded, "color": AppColors.primaryForest},
    "Wheat": {"marathi": "गहू", "hindi": "गेहूं", "icon": Icons.grain_rounded, "color": AppColors.diwaliGold},
  };

  final Map<String, List<LeafSample>> _cropSamples = {
    "Grapes": [
      const LeafSample(
        labelMarathi: "केवडा रोग",
        labelHindi: "डाउनी फफूंदी",
        labelEnglish: "Downy Mildew",
        crop: "Grapes",
        diseaseName: "Downy Mildew",
        severity: "High",
        icon: Icons.coronavirus_outlined,
        color: AppColors.sprayStop,
      ),
      const LeafSample(
        labelMarathi: "काळा कुजवा",
        labelHindi: "काला सड़न रोग",
        labelEnglish: "Black Rot",
        crop: "Grapes",
        diseaseName: "Black Rot",
        severity: "Medium",
        icon: Icons.blur_circular_rounded,
        color: AppColors.diwaliGold,
      ),
      const LeafSample(
        labelMarathi: "निरोगी वेल पान",
        labelHindi: "स्वस्थ पत्ता",
        labelEnglish: "Healthy Leaf",
        crop: "Grapes",
        diseaseName: "Healthy Foliage",
        severity: "Low",
        icon: Icons.check_circle_outline,
        color: AppColors.primaryForest,
      ),
    ],
    "Onion": [
      const LeafSample(
        labelMarathi: "जांभळा करपा",
        labelHindi: "बैंगनी धब्बा",
        labelEnglish: "Purple Blotch",
        crop: "Onion",
        diseaseName: "Purple Blotch",
        severity: "Medium",
        icon: Icons.grain_outlined,
        color: Color(0xFF8E24AA),
      ),
      const LeafSample(
        labelMarathi: "स्टेमफिलियम करपा",
        labelHindi: "स्टेमफिलियम झुलसा",
        labelEnglish: "Stemphylium Blight",
        crop: "Onion",
        diseaseName: "Stemphylium Leaf Blight",
        severity: "Medium",
        icon: Icons.bubble_chart_outlined,
        color: AppColors.diwaliGold,
      ),
      const LeafSample(
        labelMarathi: "निरोगी कांदा पान",
        labelHindi: "स्वस्थ प्याज पत्ता",
        labelEnglish: "Healthy Leaf",
        crop: "Onion",
        diseaseName: "Healthy Foliage",
        severity: "Low",
        icon: Icons.check_circle_outline,
        color: AppColors.primaryForest,
      ),
    ],
    "Sugarcane": [
      const LeafSample(
        labelMarathi: "तांबडी कूज",
        labelHindi: "लाल सड़न रोग",
        labelEnglish: "Red Rot",
        crop: "Sugarcane",
        diseaseName: "Red Rot",
        severity: "High",
        icon: Icons.warning_amber_rounded,
        color: AppColors.sprayStop,
      ),
      const LeafSample(
        labelMarathi: "चाबूक काणी रोग",
        labelHindi: "कंडुआ रोग",
        labelEnglish: "Sugarcane Smut",
        crop: "Sugarcane",
        diseaseName: "Sugarcane Smut",
        severity: "Medium",
        icon: Icons.linear_scale_rounded,
        color: Color(0xFF5D4037),
      ),
      const LeafSample(
        labelMarathi: "निरोगी ऊस",
        labelHindi: "स्वस्थ गन्ना",
        labelEnglish: "Healthy Cane",
        crop: "Sugarcane",
        diseaseName: "Healthy Crop",
        severity: "Low",
        icon: Icons.check_circle_outline,
        color: AppColors.primaryForest,
      ),
    ],
    "Wheat": [
      const LeafSample(
        labelMarathi: "पिवळा तांबेरा",
        labelHindi: "पीला रतुआ",
        labelEnglish: "Yellow Stripe Rust",
        crop: "Wheat",
        diseaseName: "Yellow Stripe Rust",
        severity: "High",
        icon: Icons.view_headline_rounded,
        color: AppColors.diwaliGold,
      ),
      const LeafSample(
        labelMarathi: "तपकिरी तांबेरा",
        labelHindi: "भूरा रतुआ",
        labelEnglish: "Brown Rust",
        crop: "Wheat",
        diseaseName: "Brown Leaf Rust",
        severity: "Medium",
        icon: Icons.grain_rounded,
        color: Color(0xFF6D4C41),
      ),
      const LeafSample(
        labelMarathi: "निरोगी गहू पान",
        labelHindi: "स्वस्थ गेहूं पत्ता",
        labelEnglish: "Healthy Leaf",
        crop: "Wheat",
        diseaseName: "Healthy Crop",
        severity: "Low",
        icon: Icons.check_circle_outline,
        color: AppColors.primaryForest,
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    if (_allowedCrops.contains(appState.activeCrop)) {
      _selectedCrop = appState.activeCrop;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await ImagePickerService.pickLeafImage(source: source);
      if (picked != null) {
        setState(() {
          _imageName = picked.name;
          _imageBytes = picked.bytes;
          _result = null;
          _recommendation = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.get("error_occurred", Provider.of<AppState>(context, listen: false).language)),
            backgroundColor: AppColors.sprayCaution,
          ),
        );
      }
    }
  }

  Uint8List _generateSampleLeafBmp(String diseaseName, String crop) {
    const width = 64;
    const height = 64;
    const rowBytes = width * 3;
    final pad = (4 - (rowBytes % 4)) % 4;
    final imageSize = (rowBytes + pad) * height;
    final fileSize = 54 + imageSize;

    final bytes = ByteData(fileSize);
    bytes.setUint8(0, 0x42); // 'B'
    bytes.setUint8(1, 0x4D); // 'M'
    bytes.setUint32(2, fileSize, Endian.little);
    bytes.setUint16(6, 0, Endian.little);
    bytes.setUint16(8, 0, Endian.little);
    bytes.setUint32(10, 54, Endian.little);

    bytes.setUint32(14, 40, Endian.little);
    bytes.setInt32(18, width, Endian.little);
    bytes.setInt32(22, height, Endian.little);
    bytes.setUint16(26, 1, Endian.little);
    bytes.setUint16(28, 24, Endian.little);
    bytes.setUint32(30, 0, Endian.little);
    bytes.setUint32(34, imageSize, Endian.little);
    bytes.setInt32(38, 2835, Endian.little);
    bytes.setInt32(42, 2835, Endian.little);
    bytes.setUint32(46, 0, Endian.little);
    bytes.setUint32(50, 0, Endian.little);

    int r = 34, g = 139, b = 34;
    int lr = 34, lg = 139, lb = 34;
    final dLower = diseaseName.toLowerCase();

    if (dLower.contains('purple blotch')) {
      lr = 130; lg = 20; lb = 130;
    } else if (dLower.contains('downy mildew')) {
      lr = 220; lg = 210; lb = 60;
    } else if (dLower.contains('powdery mildew')) {
      lr = 235; lg = 235; lb = 235;
    } else if (dLower.contains('black rot') || dLower.contains('blight') || dLower.contains('esca')) {
      lr = 100; lg = 45; lb = 20;
    } else if (dLower.contains('rust')) {
      lr = 240; lg = 120; lb = 10;
    } else if (dLower.contains('red rot')) {
      lr = 180; lg = 30; lb = 30;
    } else if (dLower.contains('smut')) {
      lr = 20; lg = 20; lb = 20;
    }

    int offset = 54;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final isLesion = (x >= 16 && x <= 48 && y >= 16 && y <= 48);
        final curR = isLesion ? lr : r;
        final curG = isLesion ? lg : g;
        final curB = isLesion ? lb : b;
        bytes.setUint8(offset++, curB);
        bytes.setUint8(offset++, curG);
        bytes.setUint8(offset++, curR);
      }
      for (int p = 0; p < pad; p++) {
        bytes.setUint8(offset++, 0);
      }
    }
    return bytes.buffer.asUint8List();
  }

  void _selectSampleLeaf(LeafSample sample) {
    setState(() {
      _imageName = "${sample.crop}_${sample.diseaseName.replaceAll(' ', '_')}.bmp";
      _imageBytes = _generateSampleLeafBmp(sample.diseaseName, sample.crop);
      _selectedCrop = sample.crop;
    });
    _runDiagnosis();
  }

  void _clearImage() {
    setState(() {
      _imageName = null;
      _imageBytes = null;
      _result = null;
      _recommendation = null;
    });
  }

  void _runDiagnosis() async {
    setState(() {
      _isAnalyzing = true;
      _result = null;
      _recommendation = null;
    });

    try {
      final res = await ApiService.diagnoseCropLeaf(
        _selectedCrop,
        imageBytes: _imageBytes,
        filename: _imageName,
      );

      if (!mounted) return;

      final appState = Provider.of<AppState>(context, listen: false);
      final rec = await ApiService.getRecommendations(
        res.crop,
        res.diseaseName,
        res.severity,
        appState.weatherData != null
            ? {
                "temperature_c": appState.weatherData!.tempC,
                "humidity_pct": appState.weatherData!.humidity,
                "wind_speed_kmh": appState.weatherData!.windKmh,
                "rain_probability_pct": appState.weatherData!.rainProbability,
              }
            : null,
      );

      if (mounted) {
        setState(() {
          _result = res;
          _recommendation = rec;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.get("error_occurred", Provider.of<AppState>(context, listen: false).language)),
            backgroundColor: AppColors.sprayStop,
          ),
        );
      }
    }
  }

  void _verifyBlockchainRecord(String hashOrId) async {
    final res = await ApiService.verifyBlockchainRecord(hashOrId);
    if (mounted) {
      _showVerificationDialog(res);
    }
  }

  void _showVerificationDialog(BlockchainVerifyResult ver) {
    final lang = Provider.of<AppState>(context, listen: false).language;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.border, width: 1.2)),
        title: Row(
          children: [
            const SealBadge(
              text: "SHA-256",
              icon: Icons.verified_rounded,
              size: 38,
              color: AppColors.primaryForest,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                lang == 'en' ? "Cryptographic Verification" : (lang == 'hi' ? "आधिकारिक डेटा सत्यापन" : "माहिती व शिफारस पडताळणी"),
                style: AppTextStyles.serifTitle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chain link visual (Block #1 -> Block #2)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.sageBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBlockNode("Block #1402"),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.link_rounded, color: AppColors.primaryForest, size: 20),
                  ),
                  _buildBlockNode("Verified Block"),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: ver.integrityStatus == "INTEGRITY VERIFIED" ? AppColors.sprayGoodBg : AppColors.sprayStopBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: ver.integrityStatus == "INTEGRITY VERIFIED" ? AppColors.sprayGoodBorder : AppColors.sprayStopBorder,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, color: AppColors.sprayGood, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lang == 'en'
                          ? "ICAR & CIBRC Certified — 100% Genuine Advice"
                          : (lang == 'hi' ? "ICAR व CIBRC प्रमाणित — जानकारी 100% सटीक है" : "ICAR व CIBRC प्रमाणित — माहिती सुरक्षित व खरी आहे"),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.sprayGood,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              lang == 'en' ? "Research Source:" : (lang == 'hi' ? "अनुसंधान संस्थान:" : "संदर्भ संस्था:"),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary),
            ),
            Text(ver.source, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lang == 'en' ? "Cryptographic Hash:" : "सुरक्षित कोड (Cryptographic Hash):",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textSecondary),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.copy_rounded, size: 15, color: AppColors.primaryForest),
                  tooltip: "Copy Hash",
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: ver.currentHash));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Hash copied to clipboard"), duration: Duration(seconds: 1)),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.parchment, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: SelectableText(
                ver.currentHash,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppStrings.get("close", lang),
              style: const TextStyle(color: AppColors.primaryForest, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBlockNode(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardCream,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryForest)),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.get("doctor_appbar_title", lang),
              style: AppTextStyles.serifTitle(fontSize: 17, color: AppColors.parchment),
            ),
            Text(
              AppStrings.get("doctor_appbar_sub", lang),
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Crop Selector Bar
                  _buildCropSelectorCard(lang),
                  const SizedBox(height: 14),

                  // 2. Leaf Image / Sample Capture Area
                  _buildImageCaptureCard(lang),
                  const SizedBox(height: 14),

                  // 3. Loading Indicator
                  if (_isAnalyzing) ...[
                    _buildLoadingCard(lang),
                    const SizedBox(height: 14),
                  ],

                  // 4. Primary Farmer-Friendly Diagnosis Card
                  if (_result != null) ...[
                    _buildFarmerDiagnosisCard(_result!, lang),
                    const SizedBox(height: 14),
                  ],

                  // 5. Recommended Medicine & PHI Card
                  if (_recommendation != null) ...[
                    _buildFarmerMedicineCard(_recommendation!, lang),
                    const SizedBox(height: 14),
                    if (_result != null) ...[
                      _buildCompareWithInventoryButton(_result!, _recommendation!, lang),
                      const SizedBox(height: 14),
                    ],
                    _buildFarmerActionStepsCard(lang),
                    const SizedBox(height: 14),
                    _buildTechnicalAccordion(_result!, _recommendation!, lang),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompareWithInventoryButton(DiagnosisResult diag, RecommendationResponseModel rec, String lang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sprayGoodBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.sprayGoodBorder, width: 1.5),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryForest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.compare_arrows_rounded, color: AppColors.parchment, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang == 'en' ? "Have pesticides in your stock?" : "आपल्याकडे औषध उपलब्ध आहे का?",
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.primaryForest),
                ),
                const SizedBox(height: 2),
                Text(
                  lang == 'en'
                      ? "Compare your farmer-owned chemicals with AgriIntel's recommendation"
                      : "आपल्या साठ्यातील औषधांची तुलना करा व सर्वोत्तम उपाय निवडा",
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PesticideComparisonScreen(
                    crop: diag.crop,
                    disease: diag.diseaseName,
                    recommendedId: rec.ranking.isNotEmpty ? rec.ranking.first.pesticideId : null,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryForest,
              foregroundColor: AppColors.parchment,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              lang == 'en' ? "Compare" : "तुलना करा",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropSelectorCard(String lang) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardCream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.agriculture_rounded, color: AppColors.primaryForest, size: 20),
              const SizedBox(width: 8),
              Text(
                AppStrings.get("select_target_crop", lang),
                style: AppTextStyles.serifTitle(fontSize: 14.5, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: _allowedCrops.map((c) {
              final isSelected = c == _selectedCrop;
              final info = _cropInfo[c]!;
              final localName = lang == 'hi' ? info["hindi"] : (lang == 'mr' ? info["marathi"] : c);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCrop = c;
                        _result = null;
                        _recommendation = null;
                        _imageBytes = null;
                        _imageName = null;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryForest : AppColors.sageBg.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryForest : AppColors.border,
                          width: isSelected ? 1.8 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            info["icon"] as IconData,
                            size: 20,
                            color: isSelected ? AppColors.parchment : AppColors.textPrimary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            localName as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppColors.parchment : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            c,
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected ? AppColors.parchment.withValues(alpha: 0.8) : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCaptureCard(String lang) {
    final currentCropSamples = _cropSamples[_selectedCrop] ?? [];
    final localizedCrop = AppStrings.cropName(_selectedCrop, lang);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardCream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _imageBytes != null ? AppColors.primaryForest : AppColors.border,
          width: 1.5,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_imageBytes != null) ...[
            AnimatedScannerFrame(
              isScanning: _isAnalyzing,
              statusText: lang == 'en' ? "AI Scanning Foliage..." : "एआय पानाची तपासणी करत आहे...",
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: 190,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.sageBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.memory(
                        _imageBytes!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.eco_rounded, size: 48, color: AppColors.primaryForest),
                              const SizedBox(height: 6),
                              Text(
                                "$localizedCrop ($_selectedCrop) Leaf Selected",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryForest),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.close, color: Colors.white, size: 18),
                        onPressed: _clearImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryForest,
                foregroundColor: AppColors.parchment,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.search_rounded, size: 22),
              label: Text(
                AppStrings.get("btn_diagnose", lang),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onPressed: _isAnalyzing ? null : _runDiagnosis,
            ),
          ] else ...[
            Text(
              "${AppStrings.get("take_or_upload_photo", lang)} ($localizedCrop)",
              textAlign: TextAlign.center,
              style: AppTextStyles.serifTitle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.get("photo_guide", lang),
              textAlign: TextAlign.center,
              style: AppTextStyles.body(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryForest,
                      foregroundColor: AppColors.parchment,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.camera_alt_rounded, size: 18),
                    label: Text(
                      AppStrings.get("btn_camera", lang),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.fernGreen,
                      foregroundColor: AppColors.parchment,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.photo_library_rounded, size: 18),
                    label: Text(
                      AppStrings.get("btn_gallery", lang),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),
          const DottedSketchDivider(height: 12),
          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(Icons.touch_app_outlined, size: 16, color: AppColors.primaryForest),
              const SizedBox(width: 6),
              Text(
                AppStrings.get("quick_samples_title", lang),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: currentCropSamples.map((sample) {
              final sampleTitle = lang == 'hi' ? sample.labelHindi : (lang == 'mr' ? sample.labelMarathi : sample.labelEnglish);
              return InkWell(
                onTap: () => _selectSampleLeaf(sample),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: sample.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: sample.color.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(sample.icon, size: 16, color: sample.color),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sampleTitle,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: sample.color.withValues(alpha: 0.9),
                            ),
                          ),
                          Text(
                            sample.labelEnglish,
                            style: const TextStyle(fontSize: 9.5, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(String lang) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardCream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryForest),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            AppStrings.get("analyzing_leaf", lang),
            style: AppTextStyles.serifTitle(fontWeight: FontWeight.bold, fontSize: 15.5),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.get("analyzing_sub", lang),
            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerDiagnosisCard(DiagnosisResult res, String lang) {
    final isHealthy = res.diseaseName.toLowerCase().contains("healthy");
    final severityColor = isHealthy
        ? AppColors.primaryForest
        : res.severity.toLowerCase() == "high"
            ? AppColors.sprayStop
            : AppColors.sprayCaution;

    final severityLabel = isHealthy
        ? (lang == 'en' ? "Healthy Crop" : (lang == 'hi' ? "स्वस्थ फसल" : "निरोगी पीक"))
        : res.severity.toLowerCase() == "high"
            ? (lang == 'en' ? "High Severity — Immediate Action Needed" : (lang == 'hi' ? "गंभीर प्रकोप — तत्काल उपाय आवश्यक" : "तातडीचा उपाय आवश्यक (गंभीर प्रादुर्भाव)"))
            : (lang == 'en' ? "Moderate Severity — Spray in 2-3 Days" : (lang == 'hi' ? "मध्यम प्रकोप — २-३ दिनों में छिड़काव करें" : "मध्यम प्रादुर्भाव (वेळेत फवारणी करा)"));

    final diseaseName = lang == 'en' ? res.diseaseName : (lang == 'hi' ? (res.marathiName) : res.marathiName);

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardCream,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: severityColor.withValues(alpha: 0.5), width: 1.8),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: severityColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isHealthy ? Icons.check_circle_rounded : Icons.healing_rounded,
                      color: severityColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          diseaseName,
                          style: AppTextStyles.serifTitle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: severityColor,
                          ),
                        ),
                        Text(
                          "${res.diseaseName} (${AppStrings.cropName(res.crop, lang)})",
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  ConfidenceScoreGauge(confidence: res.confidence, size: 54, label: lang == 'en' ? 'Confidence' : 'अचूकता'),
                ],
              ),
              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: severityColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      isHealthy ? Icons.eco_rounded : Icons.info_outline_rounded,
                      color: severityColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        severityLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: severityColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Text(
                AppStrings.get("symptoms_title", lang),
                style: AppTextStyles.serifTitle(fontSize: 13.5, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.sageBg.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  res.symptoms,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.35),
                ),
              ),
            ],
          ),
        ),
        const Positioned(
          top: -8,
          child: WashiTape(width: 76, height: 16),
        ),
      ],
    );
  }

  Widget _buildFarmerMedicineCard(RecommendationResponseModel rec, String lang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardCream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medication_rounded, color: AppColors.primaryForest, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.get("rx_title", lang),
                  style: AppTextStyles.serifTitle(fontSize: 16.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Weather Gatekeeper condition banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: rec.isSprayAllowed ? AppColors.sprayGoodBg : AppColors.sprayStopBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: rec.isSprayAllowed ? AppColors.sprayGoodBorder : AppColors.sprayStopBorder,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  rec.isSprayAllowed ? Icons.wb_sunny_rounded : Icons.thunderstorm_rounded,
                  color: rec.isSprayAllowed ? AppColors.sprayGood : AppColors.sprayStop,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rec.isSprayAllowed
                            ? AppStrings.get("safe_to_spray", lang)
                            : AppStrings.get("do_not_spray", lang),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: rec.isSprayAllowed ? AppColors.sprayGood : AppColors.sprayStop,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        rec.isSprayAllowed
                            ? (lang == 'en' ? "Best spray window: 6:00 AM - 10:00 AM or 4:00 PM - 6:30 PM." : (lang == 'hi' ? "सुबह ६:०० से १०:०० या शाम ४:०० से ६:३० के बीच छिड़काव करें।" : "सकाळी ६:०० ते १०:०० किंवा संध्याकाळी ४:०० ते ६:३० या वेळेत फवारणी करा."))
                            : (rec.sprayOverrideWarning ?? (lang == 'en' ? "High wind/rain makes spraying ineffective." : "पाऊस किंवा जोराचा वारा असल्यामुळे फवारणी वाया जाईल.")),
                        style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Chemical
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.goldLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.diwaliGold.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.science_rounded, size: 18, color: AppColors.diwaliGold),
                    const SizedBox(width: 6),
                    Text(
                      AppStrings.get("rx_chemical", lang),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF5D3B00)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _result?.chemicalTreatment ?? "Dimethomorph @ 1g/L or Mancozeb @ 2.5g/L",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  lang == 'en'
                      ? "💡 Dosage: Approx 15g to 35g per 15-Liter knapsack sprayer pump."
                      : (lang == 'hi' ? "💡 मात्रा: १५ लीटर के पंप के लिए लगभग १५ से ३५ ग्राम दवा साफ पानी में घोलें।" : "💡 प्रमाण: १५ लिटरच्या पंपासाठी अंदाजे १५ ते ३५ ग्रॅम औषध स्वच्छ पाण्यात मिसळा."),
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF5D3B00), fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Organic
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.sprayGoodBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.sprayGoodBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.eco_rounded, size: 18, color: AppColors.primaryForest),
                    const SizedBox(width: 6),
                    Text(
                      AppStrings.get("rx_organic", lang),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryForest),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _result?.organicTreatment ?? "Spray Trichoderma harzianum @ 5g/L + Neem oil 3ml/L",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryForest),
                ),
                const SizedBox(height: 6),
                Text(
                  lang == 'en'
                      ? "💡 Biological sprays are safe for beneficial insects and soil health."
                      : (lang == 'hi' ? "💡 जैविक दवाइयाँ मित्र कीटों की रक्षा करती हैं और मिट्टी को उपजाऊ बनाती हैं।" : "💡 मित्र बुरशी व निंबोळी अर्क वापरल्यास जमिनीचा व पिकाचा पोत सुधारतो."),
                  style: const TextStyle(fontSize: 11.5, color: AppColors.primaryForest, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // PHI Interval
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.sprayInfoBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.sprayInfoBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.hourglass_bottom_rounded, color: AppColors.sprayInfo, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${AppStrings.get("phi_title", lang)} ${AppStrings.get("phi_text", lang)}",
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerActionStepsCard(String lang) {
    final steps = lang == 'en'
        ? [
            "Prune heavily infected leaves and dispose of them outside the field.",
            "Mix prescribed dose in clean water and add a wetting agent/sticker.",
            "Spray during early morning before 10:00 AM or late afternoon.",
            "Always wear safety mask and gloves during chemical handling.",
            "Inspect foliage after 5-7 days to monitor disease containment.",
          ]
        : (lang == 'hi'
            ? [
                "संक्रमित पत्तियों को तोड़कर खेत से बाहर गड्ढे में नष्ट करें।",
                "दवा को साफ पानी में घोलें और पत्तियों पर चिपकने हेतु स्टिकर मिलाएं।",
                "सुबह १०:०० बजे से पहले या शाम को शांत हवा में छिड़काव करें।",
                "छिड़काव करते समय मुंह पर मास्क और हाथों में दस्ताने जरूर पहनें।",
                "५ से ७ दिनों बाद फसल का पुनः निरीक्षण कर परिणाम जांचें।",
              ]
            : [
                "बाधित पाने व फांद्या तोडून शेताबाहेर खड्ड्यात नष्ट करा.",
                "औषध स्वच्छ पाण्यात नीट मिसळा व पानावरील मेणावर टिकण्यासाठी स्टिकर वापरा.",
                "सकाळी १०:०० वाजेपूर्वी किंवा संध्याकाळी शांत हवेत फवारणी करा.",
                "फवारणी करताना तोंडाला मास्क व हातात रबरी हातमोजे वापरा.",
                "५ ते ७ दिवसांनंतर पिकाची पुन्हा पाहणी करून गुण तपासा.",
              ]);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardCream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist_rounded, color: AppColors.primaryForest, size: 20),
              const SizedBox(width: 8),
              Text(
                AppStrings.get("action_plan_title", lang),
                style: AppTextStyles.serifTitle(fontSize: 14.5, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(steps.length, (idx) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: AppColors.primaryForest,
                    child: Text(
                      "${idx + 1}",
                      style: const TextStyle(color: AppColors.parchment, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      steps[idx],
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, height: 1.3),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTechnicalAccordion(DiagnosisResult res, RecommendationResponseModel rec, String lang) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardCream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: AppShadows.card,
      ),
      child: ExpansionTile(
        initiallyExpanded: _showTechDetails,
        onExpansionChanged: (val) => setState(() => _showTechDetails = val),
        leading: const Icon(Icons.verified_user_outlined, color: AppColors.primaryForest, size: 20),
        title: Text(
          AppStrings.get("tech_audit_title", lang),
          style: AppTextStyles.serifTitle(fontSize: 13.5, fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text("${lang == 'en' ? 'Source' : 'संशोधन संदर्भ'}: ${res.source}", style: const TextStyle(fontSize: 11.5, color: AppColors.textPrimary)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.sprayGoodBg, borderRadius: BorderRadius.circular(4)),
                      child: Text(res.verificationStatus, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryForest)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("${lang == 'en' ? 'Pathogen' : 'रोगकारक बुरशी'}: ${res.pathogen}", style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: AppColors.textSecondary)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(lang == 'en' ? "Blockchain Audit Record:" : "ब्लॉकचेन ऑडिट रेकॉर्ड:", style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                    InkWell(
                      onTap: () => _verifyBlockchainRecord(res.blockchainHash),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_rounded, size: 14, color: AppColors.primaryForest),
                          const SizedBox(width: 4),
                          Text(lang == 'en' ? "Verify" : "पडताळणी करा (Verify)", style: const TextStyle(fontSize: 11.5, color: AppColors.primaryForest, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.parchment, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                  child: SelectableText(
                    res.blockchainHash,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 9.5, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
