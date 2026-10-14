import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';

class PesticideReviewScreen extends StatefulWidget {
  final PesticideOCRResult ocrResult;
  final List<String> imageIds;
  final String? frontImageUrl;

  const PesticideReviewScreen({
    super.key,
    required this.ocrResult,
    required this.imageIds,
    this.frontImageUrl,
  });

  @override
  State<PesticideReviewScreen> createState() => _PesticideReviewScreenState();
}

class _PesticideReviewScreenState extends State<PesticideReviewScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _brandCtrl;
  late TextEditingController _productCtrl;
  late TextEditingController _manufacturerCtrl;
  late TextEditingController _formulationCtrl;
  late TextEditingController _regNumCtrl;
  late TextEditingController _batchCtrl;
  late TextEditingController _expiryCtrl;
  late TextEditingController _doseCtrl;
  late TextEditingController _phiCtrl;
  late TextEditingController _quantityCtrl;

  final List<Map<String, String>> _activeIngredients = [];
  bool _showRawText = false;
  bool _isSaving = false;
  String? _duplicateWarning;

  @override
  void initState() {
    super.initState();
    final fields = widget.ocrResult.extractedFields;

    _brandCtrl = TextEditingController(text: fields['brand_name'] ?? '');
    _productCtrl = TextEditingController(text: fields['product_name'] ?? '');
    _manufacturerCtrl = TextEditingController(text: fields['manufacturer'] ?? '');
    _formulationCtrl = TextEditingController(text: fields['formulation'] ?? 'WP');
    _regNumCtrl = TextEditingController(text: fields['registration_number'] ?? '');
    _batchCtrl = TextEditingController(text: fields['batch_number'] ?? '');
    _expiryCtrl = TextEditingController(text: fields['expiry_date'] ?? '');
    _doseCtrl = TextEditingController(text: fields['recommended_dose'] ?? '');
    _phiCtrl = TextEditingController(text: fields['phi_days']?.toString() ?? '');
    _quantityCtrl = TextEditingController(text: '1.0');

    // Parse active ingredients
    final rawAIs = fields['active_ingredients'] as List<dynamic>? ?? [];
    for (var ai in rawAIs) {
      if (ai is Map<String, dynamic>) {
        _activeIngredients.add({
          "name": ai['name']?.toString() ?? '',
          "concentration": ai['concentration']?.toString() ?? '50%',
        });
      }
    }

    if (_activeIngredients.isEmpty) {
      _activeIngredients.add({"name": "", "concentration": "50%"});
    }

    _checkForDuplicates();
  }

  @override
  void dispose() {
    _brandCtrl.dispose();
    _productCtrl.dispose();
    _manufacturerCtrl.dispose();
    _formulationCtrl.dispose();
    _regNumCtrl.dispose();
    _batchCtrl.dispose();
    _expiryCtrl.dispose();
    _doseCtrl.dispose();
    _phiCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkForDuplicates() async {
    final res = await ApiService.checkDuplicatePesticide({
      "product_name": _productCtrl.text,
      "brand_name": _brandCtrl.text,
    });
    if (res != null && res['is_duplicate'] == true && mounted) {
      setState(() {
        _duplicateWarning = res['message'];
      });
    }
  }

  void _addIngredientRow() {
    setState(() {
      _activeIngredients.add({"name": "", "concentration": "50%"});
    });
  }

  void _removeIngredientRow(int index) {
    if (_activeIngredients.length > 1) {
      setState(() {
        _activeIngredients.removeAt(index);
      });
    }
  }

  Future<void> _confirmAndSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Filter valid active ingredients
    final validAIs = _activeIngredients
        .where((ai) => (ai["name"] ?? "").trim().isNotEmpty)
        .map((ai) {
      final name = ai["name"]!.trim();
      final conc = ai["concentration"] ?? "";
      double? val;
      final numMatch = RegExp(r'\d+(?:\.\d+)?').firstMatch(conc);
      if (numMatch != null) {
        val = double.tryParse(numMatch.group(0)!);
      }
      return {
        "name": name,
        "concentration": conc,
        "concentration_value": val ?? 50.0,
        "concentration_unit": "%",
        "role": "fungicide",
      };
    }).toList();

    if (validAIs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("At least one active ingredient is required to add to inventory."),
          backgroundColor: AppColors.terracotta,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final payload = {
      "product_name": _productCtrl.text.trim().isNotEmpty ? _productCtrl.text.trim() : _brandCtrl.text.trim(),
      "brand_name": _brandCtrl.text.trim(),
      "manufacturer": _manufacturerCtrl.text.trim().isNotEmpty ? _manufacturerCtrl.text.trim() : null,
      "formulation": _formulationCtrl.text.trim().toUpperCase(),
      "registration_number": _regNumCtrl.text.trim().isNotEmpty ? _regNumCtrl.text.trim() : null,
      "batch_number": _batchCtrl.text.trim().isNotEmpty ? _batchCtrl.text.trim() : null,
      "expiry_date": _expiryCtrl.text.trim().isNotEmpty ? _expiryCtrl.text.trim() : null,
      "quantity_value": double.tryParse(_quantityCtrl.text.trim()) ?? 1.0,
      "quantity_unit": "kg",
      "active_ingredients": validAIs,
      "target_crops": ["Grapes", "Onion"],
      "target_diseases": ["Downy Mildew"],
      "recommended_dose": _doseCtrl.text.trim().isNotEmpty ? _doseCtrl.text.trim() : "2.5 g/L",
      "phi_days": int.tryParse(_phiCtrl.text.trim()),
      "image_ids": widget.imageIds,
      "front_image_url": widget.frontImageUrl,
      "ocr_confidence": widget.ocrResult.ocrConfidence,
      "raw_ocr_text": widget.ocrResult.rawText,
      "verification_status": "VERIFIED_BY_FARMER",
    };

    final res = await ApiService.addPesticideToInventory(payload);

    setState(() => _isSaving = false);

    if (res != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Pesticide added successfully! Blockchain ID: ${res['blockchain_record_id'] ?? 'blk_canonical'}"),
          backgroundColor: AppColors.forestGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to save pesticide to inventory. Please try again."),
          backgroundColor: AppColors.terracotta,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final conf = widget.ocrResult.fieldConfidence;

    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        title: const Text("OCR Review & Confirm"),
        actions: [
          IconButton(
            icon: Icon(_showRawText ? Icons.article_rounded : Icons.article_outlined),
            tooltip: "Toggle Raw OCR Text",
            onPressed: () => setState(() => _showRawText = !_showRawText),
          ),
        ],
      ),
      body: ParchmentScaffoldWrapper(
        showFernTopLeft: false,
        showFernBottomRight: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notice banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardCream,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.fernGreen.withValues(alpha: 0.3)),
                    boxShadow: AppShadows.subtle,
                  ),
                  child: Row(
                    children: [
                      const SealBadge(
                        label: "OCR",
                        icon: Icons.check_circle_rounded,
                        color: AppColors.forestGreen,
                        size: 34,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("LABEL EXTRACTION REVIEW", style: AppTextStyles.eyebrow(color: AppColors.forestGreen)),
                            const SizedBox(height: 2),
                            Text(
                              "Please verify and correct the extracted label details below before saving to your inventory.",
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, height: 1.35),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 350.ms),

                // Duplicate warning if detected
                if (_duplicateWarning != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gold, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.gold, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _duplicateWarning!,
                            style: const TextStyle(fontSize: 12.5, color: AppColors.terracotta, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 350.ms),
                ],

                // Collapsible Raw OCR Text
                if (_showRawText) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cardCream,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderWarm),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Raw OCR Detected Text:",
                          style: AppTextStyles.eyebrow(color: AppColors.textMain),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.ocrResult.rawText,
                          style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.deepDarkGreen, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                // Product & Brand Names
                _buildFieldWithConfidence(
                  controller: _brandCtrl,
                  label: "Brand / Trade Name",
                  confKey: "brand_name",
                  fieldConf: conf["brand_name"],
                  isRequired: true,
                ),

                _buildFieldWithConfidence(
                  controller: _productCtrl,
                  label: "Full Product Name",
                  confKey: "product_name",
                  fieldConf: conf["product_name"],
                ),

                _buildFieldWithConfidence(
                  controller: _manufacturerCtrl,
                  label: "Manufacturer / Company",
                  confKey: "manufacturer",
                  fieldConf: conf["manufacturer"],
                ),

                const SizedBox(height: 16),

                // Active Ingredients Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Active Ingredients & Composition",
                        style: AppTextStyles.serifHeading3.copyWith(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addIngredientRow,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text("Add Chemical", style: TextStyle(fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(foregroundColor: AppColors.forestGreen),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _activeIngredients.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: TextFormField(
                              initialValue: _activeIngredients[index]["name"],
                              decoration: InputDecoration(
                                labelText: "Chemical Name (e.g. Mancozeb)",
                                filled: true,
                                fillColor: AppColors.cardCream,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.borderWarm),
                                ),
                              ),
                              onChanged: (val) => _activeIngredients[index]["name"] = val,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              initialValue: _activeIngredients[index]["concentration"],
                              decoration: InputDecoration(
                                labelText: "Conc. (%)",
                                filled: true,
                                fillColor: AppColors.cardCream,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.borderWarm),
                                ),
                              ),
                              onChanged: (val) => _activeIngredients[index]["concentration"] = val,
                            ),
                          ),
                          if (_activeIngredients.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: AppColors.terracotta),
                              onPressed: () => _removeIngredientRow(index),
                            ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Formulation & Registration
                Row(
                  children: [
                    Expanded(
                      child: _buildFieldWithConfidence(
                        controller: _formulationCtrl,
                        label: "Formulation (WP, EC, SC)",
                        confKey: "formulation",
                        fieldConf: conf["formulation"],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFieldWithConfidence(
                        controller: _regNumCtrl,
                        label: "CIB&RC Reg Number",
                        confKey: "registration_number",
                        fieldConf: conf["registration_number"],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Batch & Expiry
                Row(
                  children: [
                    Expanded(
                      child: _buildFieldWithConfidence(
                        controller: _batchCtrl,
                        label: "Batch Number",
                        confKey: "batch_number",
                        fieldConf: conf["batch_number"],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFieldWithConfidence(
                        controller: _expiryCtrl,
                        label: "Expiry Date (YYYY-MM-DD)",
                        confKey: "expiry_date",
                        fieldConf: conf["expiry_date"],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Dose & PHI
                Row(
                  children: [
                    Expanded(
                      child: _buildFieldWithConfidence(
                        controller: _doseCtrl,
                        label: "Recommended Dose",
                        confKey: "recommended_dose",
                        fieldConf: conf["recommended_dose"],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFieldWithConfidence(
                        controller: _phiCtrl,
                        label: "PHI (Waiting Days)",
                        confKey: "phi_days",
                        fieldConf: conf["phi_days"],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Quantity
                _buildFieldWithConfidence(
                  controller: _quantityCtrl,
                  label: "Quantity / Bottle Count (kg or L)",
                  confKey: "quantity_value",
                  fieldConf: conf["quantity_value"],
                ),

                const SizedBox(height: 28),

                // Submit Button
                AppButton(
                  text: _isSaving ? "Saving to Cryptographic Ledger..." : "Confirm & Add to Inventory",
                  icon: _isSaving ? null : Icons.check_circle_outline_rounded,
                  isLoading: _isSaving,
                  isPrimary: true,
                  onPressed: _isSaving ? null : _confirmAndSave,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldWithConfidence({
    required TextEditingController controller,
    required String label,
    required String confKey,
    OCRFieldConfidence? fieldConf,
    bool isRequired = false,
  }) {
    final confVal = fieldConf?.confidence ?? 0.85;
    final level = fieldConf?.level ?? (confVal > 0.8 ? "HIGH" : "LOW");
    final isLow = level == "LOW" || confVal < 0.6;

    Color confBadgeColor = AppColors.fernGreen;
    Color confBadgeBg = AppColors.fernGreen.withValues(alpha: 0.12);
    if (isLow) {
      confBadgeColor = AppColors.terracotta;
      confBadgeBg = AppColors.terracotta.withValues(alpha: 0.12);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "$label ${isRequired ? '*' : ''}",
                  style: AppTextStyles.eyebrow(color: AppColors.textMain).copyWith(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: confBadgeBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: confBadgeColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  "$level (${(confVal * 100).toInt()}%)",
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: confBadgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: isRequired
                ? (val) => (val == null || val.trim().isEmpty) ? "Field is required" : null
                : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.cardCream,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isLow ? AppColors.terracotta.withValues(alpha: 0.6) : AppColors.borderWarm,
                  width: isLow ? 1.4 : 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.forestGreen, width: 1.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
