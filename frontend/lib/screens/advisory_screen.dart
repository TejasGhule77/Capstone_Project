import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';
import '../theme/language_selector.dart';

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
        appBar: AppBar(
          title: Text(AppStrings.get("advisory_screen_title", lang)),
          actions: const [
            LanguageSelectorButton(),
          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: const Icon(Icons.notifications_active_outlined), text: AppStrings.get("tab_active_advisories", lang)),
              Tab(icon: const Icon(Icons.analytics_outlined), text: AppStrings.get("tab_ahp_matrix", lang)),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              // Tab 1: Stage-wise crop advisories
              _buildAdvisoryTab(context, advisories, activeCrop, lang),

              // Tab 2: AHP Multi-criteria crop rankings
              _buildAHPTab(context, ahpRankings, lang),
            ],
          ),
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
              Text(
                "${lang == 'en' ? 'Advisories for' : 'कृषी सल्ला:'} $localizedCrop ($activeCrop)",
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.surfaceDark),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.demoBadgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  AppStrings.get("verified_demo", lang),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.demoBadgeText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            lang == 'en'
                ? "Curated by AgriIntel Expert Agronomy Engine with real-time weather gatekeeper checks."
                : "हवामान अनुकूलतेनुसार कृषी तज्ज्ञ व संशोधन केंद्राद्वारे प्रमाणित मार्गदर्शन.",
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          if (advisories.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(lang == 'en' ? "No critical advisories at this stage for selected crop." : "निवडलेल्या पिकासाठी सध्या कोणताही गंभीर इशारा नाही."),
                ),
              ),
            )
          else
            ...advisories.map((adv) {
              Color alertColor = Colors.blue;
              String alertLabel = AppStrings.get("routine_alert", lang);
              if (adv.alertType == "URGENT" || adv.alertType == "CRITICAL") {
                alertColor = Colors.red;
                alertLabel = AppStrings.get("urgent_alert", lang);
              } else if (adv.alertType == "WARNING") {
                alertColor = Colors.orange;
                alertLabel = lang == 'en' ? "WARNING" : "सावधगिरी";
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: alertColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "$alertLabel • ${adv.stage}",
                              style: TextStyle(color: alertColor, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              adv.weatherGatekeeperStatus,
                              style: const TextStyle(fontSize: 11, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        adv.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.surfaceDark),
                      ),
                      const SizedBox(height: 6),
                      Text(adv.summary, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.get("action_points", lang),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      ...adv.actionPoints.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.arrow_right_rounded, size: 18, color: AppTheme.primaryGreen),
                              Expanded(child: Text(p, style: const TextStyle(fontSize: 12.5))),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 18),
                      Row(
                        children: [
                          const Icon(Icons.lock_clock_outlined, size: 14, color: Colors.black45),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "Blockchain Ledger Proof: ${adv.blockchainProof.substring(0, adv.blockchainProof.length > 25 ? 25 : adv.blockchainProof.length)}...",
                              style: const TextStyle(fontSize: 11, color: Colors.black45, fontFamily: 'monospace'),
                            ),
                          ),
                        ],
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

  Widget _buildAHPTab(BuildContext context, List<AHPCropRank> rankings, String lang) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.get("tab_ahp_matrix", lang),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.surfaceDark),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text("CR < 0.10", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            lang == 'en'
                ? "Analytical Hierarchy Process (AHP) multi-criteria ranking for highest yield and market viability."
                : "बाजारभाव, उत्पादन व हवामान निकषांनुसार सर्वाधिक फायदेशीर पिकांची वैज्ञानिक क्रमवारी.",
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          ...rankings.map((crop) {
            final localized = AppStrings.cropName(crop.cropName, lang);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: AppTheme.primaryGreen,
                              child: Text(
                                "${crop.rank}",
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "$localized (${crop.cropName})",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            "Score: ${crop.compositeScore.toStringAsFixed(3)}",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${lang == 'en' ? 'Expected Yield' : 'अपेक्षित उत्पादन'}: ${crop.expectedYield} T/Ac",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "${lang == 'en' ? 'Est. Profit' : 'अंदाजे नफा'}: ₹${crop.projectedProfit.toStringAsFixed(0)}",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryGreen),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      crop.justification,
                      style: const TextStyle(fontSize: 12.5, color: Colors.black87),
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
