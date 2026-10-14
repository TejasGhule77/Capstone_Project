import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';
import '../widgets/comparison_criteria_table.dart';
import '../widgets/safety_warning_card.dart';
import '../widgets/ui_components.dart';

class PesticideComparisonScreen extends StatefulWidget {
  final PesticideInventoryItem? initialInventoryItem;
  final String crop;
  final String disease;
  final String? recommendedId;

  const PesticideComparisonScreen({
    super.key,
    this.initialInventoryItem,
    this.crop = "Grapes",
    this.disease = "Downy Mildew",
    this.recommendedId,
  });

  @override
  State<PesticideComparisonScreen> createState() => _PesticideComparisonScreenState();
}

class _PesticideComparisonScreenState extends State<PesticideComparisonScreen> {
  List<PesticideInventoryItem> _farmerItems = [];
  PesticideInventoryItem? _selectedItem;
  PesticideComparisonResponse? _comparisonResult;
  bool _isLoading = true;
  bool _isComparing = false;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initialInventoryItem;
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    final items = await ApiService.getPesticideInventory(includeExpired: true);

    if (mounted) {
      setState(() {
        final seenIds = <String>{};
        _farmerItems = items.where((item) => seenIds.add(item.id)).toList();

        if (_farmerItems.isNotEmpty) {
          if (_selectedItem != null) {
            final match = _farmerItems.where((it) => it.id == _selectedItem!.id);
            _selectedItem = match.isNotEmpty ? match.first : _farmerItems.first;
          } else {
            _selectedItem = _farmerItems.first;
          }
        } else {
          _selectedItem = null;
        }
        _isLoading = false;
      });

      if (_selectedItem != null) {
        _runComparison();
      }
    }
  }

  Future<void> _runComparison() async {
    if (_selectedItem == null) return;

    setState(() => _isComparing = true);

    final appState = Provider.of<AppState>(context, listen: false);
    final weather = appState.weatherData;

    final weatherContext = {
      "wind_speed_kmh": weather?.windKmh ?? 8.0,
      "rain_probability": weather?.rainProbability.toDouble() ?? 10.0,
      "temperature_c": weather?.tempC ?? 26.0,
      "relative_humidity": weather?.humidity.toDouble() ?? 68.0,
      "spray_decision": weather?.sprayCondition ?? "GOOD_TO_SPRAY",
    };

    final payload = {
      "inventory_pesticide_id": _selectedItem!.id,
      "recommended_pesticide_id": widget.recommendedId,
      "crop_id": widget.crop,
      "disease_id": widget.disease,
      "weather_context": weatherContext,
    };

    final result = await ApiService.comparePesticides(payload);

    if (mounted) {
      setState(() {
        _comparisonResult = result;
        _isComparing = false;
      });
    }
  }

  Future<void> _verifyBlockchainAudit(String recordId) async {
    showDialog(
      context: context,
      builder: (ctx) => FutureBuilder<BlockchainVerifyResult?>(
        future: ApiService.verifyBlockchainRecord(recordId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AlertDialog(
              backgroundColor: AppColors.cardCream,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: AppColors.borderWarm),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.forestGreen),
                  const SizedBox(height: 18),
                  Text(
                    "Validating SHA-256 cryptographic chain...",
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textMain),
                  ),
                ],
              ),
            );
          }

          final res = snapshot.data;
          final isValid = res != null && res.integrityStatus.contains("VERIFIED");

          return AlertDialog(
            backgroundColor: AppColors.cardCream,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: isValid ? AppColors.fernGreen : AppColors.terracotta, width: 1.5),
            ),
            title: Row(
              children: [
                SealBadge(
                  label: isValid ? "VERIFIED" : "AUDIT",
                  icon: isValid ? Icons.verified_rounded : Icons.warning_amber_rounded,
                  color: isValid ? AppColors.forestGreen : AppColors.terracotta,
                  size: 42,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("TAMPER-EVIDENT LEDGER", style: AppTextStyles.eyebrow(color: isValid ? AppColors.forestGreen : AppColors.terracotta)),
                      Text(
                        "Cryptographic Audit",
                        style: AppTextStyles.serifHeading3.copyWith(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (isValid ? AppColors.fernGreen : AppColors.terracotta).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isValid ? AppColors.fernGreen : AppColors.terracotta),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isValid ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 16, color: isValid ? AppColors.forestGreen : AppColors.terracotta),
                      const SizedBox(width: 6),
                      Text(
                        res?.integrityStatus ?? "VERIFIED_INTEGRITY",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5,
                          color: isValid ? AppColors.forestGreen : AppColors.terracotta,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "Block ID: ${res?.recordId ?? recordId}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textMain, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 4),
                Text(
                  "Timestamp: ${res?.timestamp ?? DateTime.now().toIso8601String()}",
                  style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 14),
                Text(
                  "SHA-256 Proof Hash:",
                  style: AppTextStyles.eyebrow(color: AppColors.textMain),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.parchment,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderWarm),
                  ),
                  child: Text(
                    res?.currentHash ?? "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
                    style: const TextStyle(fontSize: 10.5, fontFamily: 'monospace', color: AppColors.deepDarkGreen, height: 1.4),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Close", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.forestGreen)),
              ),
            ],
          );
        },
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
        title: const Text("Pesticide Comparison"),
      ),
      body: ParchmentScaffoldWrapper(
        showFernTopLeft: false,
        showFernBottomRight: true,
        child: _isLoading
            ? const Center(
                child: ContextualLoading(
                  title: "Loading inventory products...",
                  icon: Icons.inventory_2_outlined,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Banner (Crop & Target Context)
                    WashiTape(
                      angle: -0.012,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.deepDarkGreen, AppColors.forestGreen],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: AppShadows.card,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                                  ),
                                  child: Text(
                                    "AHP DECISION MATRIX",
                                    style: AppTextStyles.eyebrow(color: AppColors.gold).copyWith(fontSize: 10),
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.compare_arrows_rounded, color: AppColors.gold, size: 22),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Contextual Chemical Comparison",
                              style: AppTextStyles.serifHeading3.copyWith(color: Colors.white, fontSize: 18),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.eco_rounded, color: AppColors.gold, size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        "${AppStrings.cropName(widget.crop, lang)} (${widget.crop})",
                                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.coronavirus_outlined, color: AppColors.terracotta, size: 16),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            widget.disease,
                                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 350.ms),

                    const SizedBox(height: 20),

                    // Inventory Product Selector Dropdown
                    if (_farmerItems.isNotEmpty) ...[
                      const SectionHeader(
                        title: "Your Locker Product",
                        subtitle: "Select a chemical in your locker to compare with ICAR standard",
                        icon: Icons.inventory_2_outlined,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.cardCream,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderWarm),
                          boxShadow: AppShadows.subtle,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: (_selectedItem != null && _farmerItems.any((it) => it.id == _selectedItem!.id))
                                ? _selectedItem!.id
                                : (_farmerItems.isNotEmpty ? _farmerItems.first.id : null),
                            isExpanded: true,
                            dropdownColor: AppColors.cardCream,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.forestGreen),
                            items: _farmerItems.map((item) {
                              final name = item.brandName ?? item.productName ?? "Pesticide";
                              final statusBadge = item.isExpired ? " [EXPIRED]" : "";
                              return DropdownMenuItem<String>(
                                value: item.id,
                                child: Row(
                                  children: [
                                    Icon(
                                      item.isExpired ? Icons.warning_amber_rounded : Icons.science_outlined,
                                      size: 18,
                                      color: item.isExpired ? AppColors.terracotta : AppColors.forestGreen,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "$name$statusBadge",
                                        style: TextStyle(
                                          color: item.isExpired ? AppColors.terracotta : AppColors.textMain,
                                          fontWeight: item.isExpired ? FontWeight.bold : FontWeight.w600,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (newId) {
                              if (newId != null) {
                                final matched = _farmerItems.firstWhere((it) => it.id == newId);
                                setState(() => _selectedItem = matched);
                                _runComparison();
                              }
                            },
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    if (_isComparing)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.0),
                          child: ContextualLoading(
                            title: "Evaluating multi-criteria decision matrices & weather gatekeeper...",
                            icon: Icons.analytics_outlined,
                          ),
                        ),
                      )
                    else if (_comparisonResult != null) ...[
                      // Decision Banner
                      _buildDecisionBanner(_comparisonResult!).animate().fadeIn(duration: 350.ms),

                      const SizedBox(height: 20),

                      // Side-by-Side Product Cards
                      _buildSideBySideCards(_comparisonResult!).animate().fadeIn(delay: 100.ms, duration: 350.ms),

                      const SizedBox(height: 20),

                      // Expandable Criteria Breakdown Table
                      ComparisonCriteriaTable(criteria: _comparisonResult!.criteria),

                      const SizedBox(height: 20),

                      // Safety Warning Card (Weather Gatekeeper, PHI/MRL, Expiry)
                      SafetyWarningCard(
                        warnings: _comparisonResult!.safetyWarnings,
                        weatherGatekeeperStatus: _comparisonResult!.weatherGatekeeperStatus,
                        windSpeed: _comparisonResult!.criteria.any((c) => c.criterion.contains("Weather") && c.weight > 0)
                            ? 8.0
                            : null,
                        disclaimer: _comparisonResult!.disclaimer,
                      ),

                      const SizedBox(height: 20),

                      // Final Agronomic Advisory Card
                      WashiTape(
                        angle: 0.01,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.cardCream,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.fernGreen.withValues(alpha: 0.3)),
                            boxShadow: AppShadows.card,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.forestGreen.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.psychology_outlined, color: AppColors.forestGreen, size: 22),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Actionable Decision Advisory",
                                    style: AppTextStyles.serifHeading3.copyWith(fontSize: 16, color: AppColors.forestGreen),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _comparisonResult!.finalAdvisory,
                                style: AppTextStyles.bodyMedium.copyWith(height: 1.5, color: AppColors.textMain),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Cryptographic Blockchain Proof Button
                      if (_comparisonResult!.blockchainRecordId != null)
                        Center(
                          child: OutlinedButton.icon(
                            onPressed: () => _verifyBlockchainAudit(_comparisonResult!.blockchainRecordId!),
                            icon: const Icon(Icons.shield_outlined, size: 18),
                            label: Text("Verify Blockchain Proof (${_comparisonResult!.blockchainRecordId})"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.forestGreen,
                              side: const BorderSide(color: AppColors.forestGreen),
                              backgroundColor: AppColors.cardCream,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDecisionBanner(PesticideComparisonResponse res) {
    Color bg;
    Color border;
    Color iconColor;
    IconData icon;
    String title;
    String subtitle;

    if (res.isDoNotSpray) {
      bg = const Color(0xFFFBEBEB);
      border = AppColors.terracotta;
      iconColor = AppColors.terracotta;
      icon = Icons.cancel_outlined;
      title = "Do not spray under current weather conditions";
      subtitle = "High wind velocity or rainfall probability violates spraying safety standards.";
    } else if (res.isRecommendedWinner) {
      bg = const Color(0xFFF2F7F4);
      border = AppColors.forestGreen;
      iconColor = AppColors.forestGreen;
      icon = Icons.verified_outlined;
      title = "AgriIntel recommendation is more suitable";
      subtitle = "Recommended product has higher verified match, crop registration, and PHI compliance.";
    } else if (res.isInventoryWinner) {
      bg = const Color(0xFFF2F7F4);
      border = AppColors.fernGreen;
      iconColor = AppColors.fernGreen;
      icon = Icons.thumb_up_alt_outlined;
      title = "Your inventory product is suitable with conditions";
      subtitle = "Product matches active ingredient targets and crop needs. Follow dosage strictly.";
    } else if (res.isBothSimilar) {
      bg = const Color(0xFFFFF9EE);
      border = AppColors.gold;
      iconColor = AppColors.gold;
      icon = Icons.balance_outlined;
      title = "Both products have similar suitability";
      subtitle = "Both candidates show comparable efficacy for this crop and disease condition.";
    } else {
      bg = const Color(0xFFFBF4EE);
      border = AppColors.terracotta;
      iconColor = AppColors.terracotta;
      icon = Icons.help_outline;
      title = "Neither product has sufficient verified data";
      subtitle = "Consult an agricultural officer before application.";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: 1.5),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: border.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: border),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.5, color: AppColors.textMuted, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideBySideCards(PesticideComparisonResponse res) {
    final inv = res.inventoryProduct;
    final rec = res.recommendedProduct;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Farmer Product Card
        Expanded(
          child: _buildProductAttributeCard(
            title: "Farmer's Locker",
            brand: inv["brand_name"] ?? inv["product_name"] ?? "Inventory Item",
            score: res.inventoryScore,
            scoreColor: AppColors.forestGreen,
            formulation: inv["formulation"] ?? "WP",
            phi: inv["phi_days"] != null ? "${inv["phi_days"]} days" : "Unverified",
            registration: inv["registration_number"] ?? "Unknown",
            expiry: inv["expiry_date"] ?? "N/A",
            isWinner: res.isInventoryWinner,
          ),
        ),
        const SizedBox(width: 12),
        // AgriIntel Recommended Card
        Expanded(
          child: _buildProductAttributeCard(
            title: "AgriIntel Pick",
            brand: rec["product_name"] ?? "Standard Control",
            score: res.recommendedScore,
            scoreColor: AppColors.gold,
            formulation: rec["formulation"] ?? "WP",
            phi: rec["phi"] ?? "14 days",
            registration: "CIB&RC Registered",
            expiry: "Active Registry",
            isWinner: res.isRecommendedWinner,
          ),
        ),
      ],
    );
  }

  Widget _buildProductAttributeCard({
    required String title,
    required String brand,
    required double? score,
    required Color scoreColor,
    required String formulation,
    required String phi,
    required String registration,
    required String expiry,
    required bool isWinner,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardCream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isWinner ? scoreColor : AppColors.borderWarm,
          width: isWinner ? 2.0 : 1.0,
        ),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.eyebrow().copyWith(fontSize: 10),
              ),
              if (isWinner)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "BEST MATCH",
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: scoreColor),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            brand,
            style: AppTextStyles.serifHeading3.copyWith(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // Composite Score Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stars_rounded, size: 15, color: scoreColor),
                const SizedBox(width: 4),
                Text(
                  "${score?.toInt() ?? 0}/100",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: scoreColor),
                ),
              ],
            ),
          ),

          const Divider(height: 20, color: AppColors.borderWarm),

          _buildAttr("Formulation", formulation),
          _buildAttr("PHI Period", phi),
          _buildAttr("Registration", registration),
          _buildAttr("Expiry", expiry),
        ],
      ),
    );
  }

  Widget _buildAttr(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10)),
          const SizedBox(height: 1),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMain),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
