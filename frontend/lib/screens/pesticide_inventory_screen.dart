import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';
import '../widgets/pesticide_inventory_card.dart';
import '../widgets/ui_components.dart';
import 'add_pesticide_screen.dart';
import 'pesticide_comparison_screen.dart';

class PesticideInventoryScreen extends StatefulWidget {
  const PesticideInventoryScreen({super.key});

  @override
  State<PesticideInventoryScreen> createState() => _PesticideInventoryScreenState();
}

class _PesticideInventoryScreenState extends State<PesticideInventoryScreen> {
  List<PesticideInventoryItem> _items = [];
  bool _isLoading = true;
  String _selectedFilter = "ALL"; // ALL, AVAILABLE, EXPIRED
  String? _selectedCrop;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    setState(() => _isLoading = true);
    final items = await ApiService.getPesticideInventory(
      cropId: _selectedCrop,
      includeExpired: true,
    );
    if (mounted) {
      setState(() {
        _items = items;
        _isLoading = false;
      });
    }
  }

  List<PesticideInventoryItem> get _filteredItems {
    if (_selectedFilter == "AVAILABLE") {
      return _items.where((it) => it.inventoryStatus != "EXPIRED").toList();
    } else if (_selectedFilter == "EXPIRED") {
      return _items.where((it) => it.inventoryStatus == "EXPIRED").toList();
    }
    return _items;
  }

  Future<void> _archiveItem(PesticideInventoryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardCream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderWarm),
        ),
        title: Text(
          "Archive Pesticide",
          style: AppTextStyles.serifHeading3.copyWith(color: AppColors.textMain),
        ),
        content: Text(
          "Are you sure you want to archive '${item.brandName ?? item.productName}'? Historical records and blockchain integrity will be preserved.",
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Cancel", style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracotta,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Archive", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final ok = await ApiService.archivePesticide(item.id);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.forestGreen,
            content: Text(
              "Archived '${item.brandName ?? item.productName}'",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        _loadInventory();
      }
    }
  }

  void _showBlockchainProof(PesticideInventoryItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardCream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.borderWarm, width: 1.5),
        ),
        title: Row(
          children: [
            const SealBadge(
              label: "PROOF",
              icon: Icons.shield_rounded,
              color: AppColors.forestGreen,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("CRYPTO INTEGRITY", style: AppTextStyles.eyebrow()),
                  Text("Blockchain Record", style: AppTextStyles.serifHeading3.copyWith(fontSize: 17)),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "This pesticide inventory record is immutably anchored in AgriIntel's cryptographic SHA-256 ledger.",
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.parchment,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderWarm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Product: ${item.brandName ?? item.productName}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textMain)),
                  const SizedBox(height: 6),
                  Text("Record ID: ${item.blockchainRecordId ?? 'blk_canonical'}", style: const TextStyle(fontSize: 11, color: AppColors.fernGreen, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.fernGreen),
                      const SizedBox(width: 4),
                      Text("Verification: ${item.verificationStatus}", style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close", style: TextStyle(color: AppColors.forestGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    final activeCrop = appState.activeCrop;
    final lang = appState.language;

    final availableCount = _items.where((i) => i.inventoryStatus != 'EXPIRED').length;
    final expiredCount = _items.where((i) => i.inventoryStatus == 'EXPIRED').length;

    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        title: Text(lang == 'en' ? "Chemical Locker" : "कीटकनाशक साठा"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Refresh Inventory",
            onPressed: _loadInventory,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddPesticideScreen()),
          );
          if (added == true) {
            _loadInventory();
          }
        },
        backgroundColor: AppColors.forestGreen,
        icon: const Icon(Icons.add_a_photo_rounded, color: Colors.white),
        label: Text(
          lang == 'en' ? "Scan Label OCR" : "औषध बाटली स्कॅन",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
      body: ParchmentScaffoldWrapper(
        showFernTopLeft: false,
        showFernBottomRight: true,
        child: RefreshIndicator(
          color: AppColors.forestGreen,
          backgroundColor: AppColors.cardCream,
          onRefresh: _loadInventory,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Digital Chemical Locker Header
                WashiTape(
                  angle: -0.015,
                  child: Container(
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
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                          ),
                          child: const Icon(Icons.inventory_2_rounded, color: AppColors.gold, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "FARMER DIGITAL LOCKER",
                                style: AppTextStyles.eyebrow(color: AppColors.gold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user?.name ?? "Farmer Chemical Vault",
                                style: AppTextStyles.serifHeading3.copyWith(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user?.farms.isNotEmpty == true
                                    ? "${user!.farms.first.farmName} • ${user.farms.first.village}"
                                    : "Primary Plot • Maharashtra",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                ),
                                child: Text(
                                  "${lang == 'en' ? 'Active Target Crop' : 'सध्याचे पीक'}: ${AppStrings.cropName(activeCrop, lang)} ($activeCrop)",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0),

                const SizedBox(height: 16),

                // Summary Metric Cards (Total, Available, Expired)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: AppColors.cardCream,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderWarm),
                          boxShadow: AppShadows.subtle,
                        ),
                        child: Column(
                          children: [
                            Text(
                              "${_items.length}",
                              style: AppTextStyles.serifHeading3.copyWith(color: AppColors.textMain, fontSize: 20),
                            ),
                            const SizedBox(height: 2),
                            Text("Total Locker", style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: AppColors.cardCream,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.fernGreen.withValues(alpha: 0.4)),
                          boxShadow: AppShadows.subtle,
                        ),
                        child: Column(
                          children: [
                            Text(
                              "$availableCount",
                              style: AppTextStyles.serifHeading3.copyWith(color: AppColors.fernGreen, fontSize: 20),
                            ),
                            const SizedBox(height: 2),
                            Text("Available", style: AppTextStyles.caption.copyWith(color: AppColors.fernGreen, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: AppColors.cardCream,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: expiredCount > 0 ? AppColors.terracotta.withValues(alpha: 0.5) : AppColors.borderWarm,
                          ),
                          boxShadow: AppShadows.subtle,
                        ),
                        child: Column(
                          children: [
                            Text(
                              "$expiredCount",
                              style: AppTextStyles.serifHeading3.copyWith(
                                color: expiredCount > 0 ? AppColors.terracotta : AppColors.textMuted,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Expired",
                              style: AppTextStyles.caption.copyWith(
                                color: expiredCount > 0 ? AppColors.terracotta : AppColors.textMuted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms, duration: 350.ms),

                const SizedBox(height: 16),

                // Filter Tabs Row
                Row(
                  children: [
                    _buildFilterChip("ALL", "All (${_items.length})"),
                    const SizedBox(width: 8),
                    _buildFilterChip("AVAILABLE", "Available ($availableCount)"),
                    const SizedBox(width: 8),
                    _buildFilterChip("EXPIRED", "Expired ($expiredCount)"),
                  ],
                ).animate().fadeIn(delay: 150.ms, duration: 350.ms),

                const SizedBox(height: 16),

                // Product List or Empty State
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: ContextualLoading(title: "Loading Chemical Locker...", subtitle: "Syncing with verified inventory"),
                  )
                else if (_filteredItems.isEmpty)
                  _buildEmptyState()
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14.0),
                        child: PesticideInventoryCard(
                          item: item,
                          activeCrop: activeCrop,
                          onTap: () => _showBlockchainProof(item),
                          onCompare: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PesticideComparisonScreen(
                                  initialInventoryItem: item,
                                  crop: activeCrop,
                                  disease: item.targetDiseases.isNotEmpty ? item.targetDiseases.first : "Downy Mildew",
                                ),
                              ),
                            );
                          },
                          onArchive: () => _archiveItem(item),
                        ),
                      ).animate().fadeIn(delay: (150 + index * 50).ms, duration: 350.ms).slideY(begin: 0.05, end: 0);
                    },
                  ),

                const SizedBox(height: 80), // Padding for FAB
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = key),
      selectedColor: AppColors.forestGreen,
      backgroundColor: AppColors.cardCream,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: isSelected ? Colors.white : AppColors.textMain,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.forestGreen : AppColors.borderWarm,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.cardCream,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderWarm),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.forestGreen.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderWarm),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 52,
              color: AppColors.forestGreen,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "No Pesticides in Inventory",
            style: AppTextStyles.serifHeading3.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            "Scan or upload your pesticide bottles and packets. AgriIntel extracts composition via OCR and verifies spray suitability against ICAR standards.",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          AppButton(
            text: "Scan Pesticide Bottle",
            icon: Icons.add_a_photo_outlined,
            isPrimary: true,
            onPressed: () async {
              final added = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const AddPesticideScreen()),
              );
              if (added == true) _loadInventory();
            },
          ),
        ],
      ),
    );
  }
}
