import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import '../services/api_service.dart';
import '../services/image_picker_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';
import 'pesticide_review_screen.dart';

class AddPesticideScreen extends StatefulWidget {
  const AddPesticideScreen({super.key});

  @override
  State<AddPesticideScreen> createState() => _AddPesticideScreenState();
}

class _AddPesticideScreenState extends State<AddPesticideScreen> {
  // Up to 4 panels: front, back, composition, instruction
  final Map<String, Uint8List?> _imageBytes = {
    "front": null,
    "back": null,
    "composition": null,
    "instruction": null,
  };

  final Map<String, String?> _imageNames = {
    "front": null,
    "back": null,
    "composition": null,
    "instruction": null,
  };

  bool _isProcessing = false;
  String _statusMessage = "";

  final List<Map<String, String>> _samplePresets = [
    {
      "name": "Ridomil Gold 68 WG",
      "chemical": "Metalaxyl-M 4% + Mancozeb 64%",
      "crop": "Grapes, Onion",
      "reg": "CIR-45892/2020",
      "filename": "ridomil_gold_label.jpg",
    },
    {
      "name": "Dithane M-45 75 WP",
      "chemical": "Mancozeb 75% WP",
      "crop": "Onion, Grapes",
      "reg": "CIR-12044/2019",
      "filename": "dithane_m45_label.jpg",
    },
    {
      "name": "Acrobat 50 WP",
      "chemical": "Dimethomorph 50% WP",
      "crop": "Grapes",
      "reg": "CIR-77891/2021",
      "filename": "acrobat_label.jpg",
    },
    {
      "name": "Bavistin 50 WP",
      "chemical": "Carbendazim 50% WP",
      "crop": "Sugarcane, Wheat",
      "reg": "CIR-33214/2018",
      "filename": "bavistin_label.jpg",
    },
  ];

  Future<void> _pickImage(String type, ImageSource source) async {
    try {
      final picked = await ImagePickerService.pickLeafImage(source: source);
      if (picked != null) {
        if (picked.sizeBytes > 10 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Selected image exceeds 10 MB limit.")),
            );
          }
          return;
        }
        setState(() {
          _imageBytes[type] = picked.bytes;
          _imageNames[type] = picked.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not select image: $e")),
        );
      }
    }
  }

  void _useSamplePreset(Map<String, String> preset) {
    // Generate simulated test image bytes for testing OCR workflow
    final dummyBytes = Uint8List.fromList([
      0xff, 0xd8, 0xff, 0xe0, 0x00, 0x10, 0x4a, 0x46, 0x49, 0x46, 0x00, 0x01,
      0x01, 0x01, 0x00, 0x60, 0x00, 0x60, 0x00, 0x00, 0xff, 0xdb, 0x00, 0x43,
      0x00, 0x08, 0x06, 0x06, 0x07, 0x06, 0x05, 0x08, 0x07, 0x07, 0x07, 0x09,
      0x09, 0x08, 0x0a, 0x0c, 0x14, 0x0d, 0x0c, 0x0b, 0x0b, 0x0c, 0x19, 0x12,
      0x13, 0x0f, 0x14, 0x1d, 0x1a, 0x1f, 0x1e, 0x1d, 0x1a, 0x1c, 0x1c, 0x20,
      0xff, 0xc0, 0x00, 0x0b, 0x08, 0x00, 0x20, 0x00, 0x20, 0x01, 0x01, 0x11,
      0x00, 0xff, 0xda, 0x00, 0x08, 0x01, 0x01, 0x00, 0x00, 0x3f, 0x00, 0xff, 0xd9
    ]);

    setState(() {
      _imageBytes["front"] = dummyBytes;
      _imageNames["front"] = preset["filename"];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.forestGreen,
        content: Text("Loaded sample '${preset['name']}'. Ready for OCR.", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _startOCRProcess() async {
    final selectedTypes = _imageBytes.entries.where((e) => e.value != null).toList();
    if (selectedTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.terracotta,
          content: const Text("Please take or upload at least one pesticide bottle/label image."),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = "Uploading image(s) securely...";
    });

    List<String> uploadedImageIds = [];
    String? frontUrl;

    for (var entry in selectedTypes) {
      final bytes = entry.value!;
      final filename = _imageNames[entry.key] ?? "${entry.key}_label.jpg";
      final uploadRes = await ApiService.uploadPesticideImage(
        bytes,
        filename,
        imageType: entry.key,
      );
      if (uploadRes != null) {
        uploadedImageIds.add(uploadRes.imageId);
        if (entry.key == "front" || frontUrl == null) {
          frontUrl = uploadRes.imageUrl;
        }
      }
    }

    if (uploadedImageIds.isEmpty) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.terracotta,
            content: const Text("Failed to upload image. Please check your connection and try again."),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return;
    }

    setState(() => _statusMessage = "Running OCR & analyzing active ingredients...");

    final ocrRes = await ApiService.extractPesticideOCR(uploadedImageIds);

    setState(() => _isProcessing = false);

    if (ocrRes != null && mounted) {
      // Navigate to Review Screen
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => PesticideReviewScreen(
            ocrResult: ocrRes,
            imageIds: uploadedImageIds,
            frontImageUrl: frontUrl,
          ),
        ),
      );

      if (result == true && mounted) {
        Navigator.pop(context, true);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.terracotta,
          content: const Text("We could not read the pesticide label. Please upload a clearer image or enter details manually."),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _imageBytes.values.any((b) => b != null);

    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        title: const Text("Scan Pesticide Bottle"),
      ),
      body: ParchmentScaffoldWrapper(
        showFernTopLeft: false,
        showFernBottomRight: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instructions banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardCream,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.fernGreen.withValues(alpha: 0.3)),
                  boxShadow: AppShadows.subtle,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.fernGreen.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.info_outline_rounded, color: AppColors.fernGreen, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("LABEL SCANNING TIPS", style: AppTextStyles.eyebrow(color: AppColors.fernGreen)),
                          const SizedBox(height: 2),
                          Text(
                            "Capture sharp, clear photos of your pesticide container label. Ensure active ingredients, concentration (%), formulation, and registration number are visible.",
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms),

              const SizedBox(height: 18),

              const SectionHeader(
                title: "Label Photos (Up to 4 Panels)",
                subtitle: "Capture front, composition, back and dosage labels",
                icon: Icons.photo_camera_rounded,
              ),
              const SizedBox(height: 10),

              // Grid of 4 image slots
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.15,
                children: [
                  _buildImageSlot("front", "Front Brand Label", Icons.camera_alt_outlined),
                  _buildImageSlot("composition", "Composition Panel", Icons.science_outlined),
                  _buildImageSlot("back", "Back Warning Label", Icons.flip_to_back_outlined),
                  _buildImageSlot("instruction", "Dosage Instructions", Icons.menu_book_outlined),
                ],
              ).animate().fadeIn(delay: 100.ms, duration: 350.ms),

              const SizedBox(height: 22),

              // Quick Demo Test Presets
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Quick Test Bottle Presets",
                    style: AppTextStyles.serifHeading3.copyWith(fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "1-Tap OCR Demo",
                      style: AppTextStyles.eyebrow(color: AppColors.gold).copyWith(fontSize: 9.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _samplePresets.map((preset) {
                  return ActionChip(
                    avatar: const Icon(Icons.flash_on_rounded, size: 16, color: AppColors.gold),
                    label: Text(
                      preset["name"]!,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMain),
                    ),
                    backgroundColor: AppColors.cardCream,
                    side: const BorderSide(color: AppColors.borderWarm),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onPressed: () => _useSamplePreset(preset),
                  );
                }).toList(),
              ).animate().fadeIn(delay: 150.ms, duration: 350.ms),

              const SizedBox(height: 28),

              // Extract Button or Loading Indicator with Shimmer
              if (_isProcessing)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardCream,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.fernGreen.withValues(alpha: 0.3)),
                    boxShadow: AppShadows.card,
                  ),
                  child: Column(
                    children: [
                      Shimmer.fromColors(
                        baseColor: AppColors.forestGreen,
                        highlightColor: AppColors.gold,
                        child: const Icon(Icons.document_scanner_rounded, size: 40),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.forestGreen,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const LinearProgressIndicator(
                        backgroundColor: AppColors.parchment,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.forestGreen),
                      ),
                    ],
                  ),
                )
              else
                AppButton(
                  text: "Extract Composition with OCR",
                  icon: Icons.document_scanner_rounded,
                  isPrimary: true,
                  onPressed: hasImage ? _startOCRProcess : null,
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSlot(String type, String title, IconData icon) {
    final bytes = _imageBytes[type];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardCream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: bytes != null ? AppColors.forestGreen : AppColors.borderWarm,
          width: bytes != null ? 2.0 : 1.2,
        ),
        boxShadow: AppShadows.subtle,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _showImageSourceDialog(type),
        child: bytes != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(
                      bytes,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholderSlot(title, icon),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.black.withValues(alpha: 0.6),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.close, size: 14, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _imageBytes[type] = null;
                            _imageNames[type] = null;
                          });
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppColors.deepDarkGreen.withValues(alpha: 0.8),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              )
            : _buildPlaceholderSlot(title, icon),
      ),
    );
  }

  Widget _buildPlaceholderSlot(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.forestGreen.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: AppColors.forestGreen),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            "+ Tap to add",
            style: TextStyle(
              fontSize: 10,
              color: AppColors.fernGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog(String type) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderWarm,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Select Image Source",
                style: AppTextStyles.serifHeading3.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.forestGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: AppColors.forestGreen),
                ),
                title: const Text("Take Photo with Camera", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(type, ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library, color: AppColors.gold),
                ),
                title: const Text("Upload from Gallery", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(type, ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
