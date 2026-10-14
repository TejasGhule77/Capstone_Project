import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';
import '../theme/language_selector.dart';
import '../widgets/ui_components.dart';

class AdvisoryScreen extends StatelessWidget {
  const AdvisoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final advisories = appState.advisories;
    final ahpRankings = appState.ahpRankings;
    final activeCrop = appState.activeCrop;
    final lang = appState.language;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.parchment,
        appBar: AppBar(
          backgroundColor: AppColors.primaryForest,
          foregroundColor: AppColors.parchment,
          title: Text(
            AppStrings.get("advisory_screen_title", lang),
            style: AppTextStyles.serifTitle(fontSize: 18, color: AppColors.parchment),
          ),
          actions: const [
            LanguageSelectorButton(isDark: false),
          ],
          bottom: TabBar(
            indicatorColor: AppColors.diwaliGold,
            indicatorWeight: 3,
            labelColor: AppColors.parchment,
            unselectedLabelColor: AppColors.parchment.withValues(alpha: 0.72),
            labelStyle: AppTextStyles.serifTitle(fontSize: 13, fontWeight: FontWeight.bold),
            tabs: [
              Tab(
                icon: const Icon(Icons.notifications_active_outlined),
                text: AppStrings.get("tab_active_advisories", lang),
              ),
              Tab(
                icon: const Icon(Icons.analytics_outlined),
                text: AppStrings.get("tab_ahp_matrix", lang),
              ),
            ],
          ),
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
              child: TabBarView(
                children: [
                  // Tab 1: Stage-wise crop advisories
                  _buildAdvisoryTab(context, advisories, activeCrop, lang),

                  // Tab 2: AHP Multi-criteria crop rankings
                  _buildAHPTab(context, ahpRankings, lang),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvisoryTab(BuildContext context, List<AdvisoryItemModel> advisories, String activeCrop, String lang) {
    final localizedCrop = AppStrings.cropName(activeCrop, lang);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "${lang == 'en' ? 'Advisories for' : 'कृषी सल्ला:'} $localizedCrop ($activeCrop)",
                  style: AppTextStyles.serifTitle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.goldLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.diwaliGold.withValues(alpha: 0.4)),
                ),
                child: Text(
                  AppStrings.get("verified_demo", lang),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF5D3B00)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            lang == 'en'
                ? "Curated by AgriIntel Expert Agronomy Engine with real-time weather gatekeeper checks."
                : "हवामान अनुकूलतेनुसार कृषी तज्ज्ञ व संशोधन केंद्राद्वारे प्रमाणित मार्गदर्शन.",
            style: AppTextStyles.body(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          if (advisories.isEmpty)
            FarmerEmptyState(
              icon: Icons.eco_outlined,
              title: lang == 'en' ? "No Critical Advisories" : "सध्या कोणताही गंभीर सल्ला नाही",
              description: lang == 'en'
                  ? "Your selected crop condition is stable. Continue normal irrigation and field scouting."
                  : "निवडलेल्या पिकाची स्थिती उत्तम आहे. नियमित देखभाल चालू ठेवा.",
            )
          else
            ...advisories.map((adv) {
              Color alertColor = AppColors.primaryForest;
              String alertLabel = AppStrings.get("routine_alert", lang);
              IconData alertIcon = Icons.info_outline_rounded;

              if (adv.alertType == "URGENT" || adv.alertType == "CRITICAL") {
                alertColor = AppColors.sprayStop;
                alertLabel = AppStrings.get("urgent_alert", lang);
                alertIcon = Icons.warning_amber_rounded;
              } else if (adv.alertType == "WARNING") {
                alertColor = AppColors.sprayCaution;
                alertLabel = lang == 'en' ? "WARNING" : "सावधगिरी";
                alertIcon = Icons.report_problem_outlined;
              }

              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    color: AppColors.cardCream,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: alertColor.withValues(alpha: 0.35), width: 1.4),
                    ),
                    elevation: 0,
                    shadowColor: AppShadows.card.first.color,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: alertColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(alertIcon, size: 14, color: alertColor),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          "$alertLabel • ${adv.stage}",
                                          style: TextStyle(color: alertColor, fontSize: 11, fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.sprayGoodBg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.sprayGoodBorder),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle_outline, size: 12, color: AppColors.primaryForest),
                                    const SizedBox(width: 4),
                                    Text(
                                      adv.weatherGatekeeperStatus,
                                      style: const TextStyle(fontSize: 11, color: AppColors.primaryForest, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            adv.title,
                            style: AppTextStyles.serifTitle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            adv.summary,
                            style: AppTextStyles.body(
                              fontSize: 13.5,
                              height: 1.4,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            AppStrings.get("action_points", lang),
                            style: AppTextStyles.serifTitle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...adv.actionPoints.map(
                            (p) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryForest.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check_rounded, size: 12, color: AppColors.primaryForest),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      p,
                                      style: const TextStyle(fontSize: 13, height: 1.3, color: AppColors.textPrimary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const DottedSketchDivider(height: 20),
                          Row(
                            children: [
                              const Icon(Icons.lock_clock_outlined, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Blockchain Ledger Proof: ${adv.blockchainProof.substring(0, adv.blockchainProof.length > 25 ? 25 : adv.blockchainProof.length)}...",
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'monospace'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    top: -8,
                    child: WashiTape(width: 72, height: 16),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildAHPTab(BuildContext context, List<AHPCropRank> rankings, String lang) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  AppStrings.get("tab_ahp_matrix", lang),
                  style: AppTextStyles.serifTitle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.sageBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text("CR < 0.10 (Consistent)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryForest)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            lang == 'en'
                ? "Analytical Hierarchy Process (AHP) multi-criteria ranking for highest yield and market viability."
                : "बाजारभाव, उत्पादन व हवामान निकषांनुसार सर्वाधिक फायदेशीर पिकांची वैज्ञानिक क्रमवारी.",
            style: AppTextStyles.body(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          ...rankings.map((crop) {
            final localized = AppStrings.cropName(crop.cropName, lang);
            final isTop = crop.rank == 1;

            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              color: AppColors.cardCream,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isTop ? AppColors.primaryForest : AppColors.border,
                  width: isTop ? 1.8 : 1.0,
                ),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              SealBadge.ahpRank(crop.rank, size: 36),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "$localized (${crop.cropName})",
                                  style: AppTextStyles.serifTitle(fontSize: 16.5, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.sprayInfoBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.sprayInfoBorder),
                          ),
                          child: Text(
                            "Score: ${crop.compositeScore.toStringAsFixed(3)}",
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0277BD)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.goldLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.diwaliGold.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang == 'en' ? "Expected Yield" : "अपेक्षित उत्पादन",
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${crop.expectedYield} T/Ac",
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 28, color: AppColors.border),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang == 'en' ? "Est. Net Profit" : "अंदाजे नफा",
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "₹${crop.projectedProfit.toStringAsFixed(0)}",
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryForest),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      crop.justification,
                      style: AppTextStyles.body(fontSize: 13, height: 1.4, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
