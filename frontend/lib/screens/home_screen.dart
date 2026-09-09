import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';
import '../theme/language_selector.dart';
import 'crop_selection_screen.dart';
import 'weather_screen.dart';
import 'crop_doctor_screen.dart';
import 'advisory_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    final weather = appState.weatherData;
    final lang = appState.language;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.eco_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              AppStrings.get("app_title", lang),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        actions: [
          const LanguageSelectorButton(),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: AppStrings.get("refresh", lang),
            onPressed: () => appState.refreshAllData(),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: AppStrings.get("nav_profile", lang),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => appState.refreshAllData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Farmer & Farm Header Card
              _buildFarmerHeader(user, lang),
              const SizedBox(height: 14),

              // 2. Crop Selector Bar
              _buildCropSelectorBar(appState, lang),
              const SizedBox(height: 14),

              // 3. Weather Gatekeeper Card
              _buildWeatherGatekeeperCard(context, weather, appState.activeCrop, lang),
              const SizedBox(height: 14),

              // 4. Quick Action Grid
              _buildQuickActionGrid(context, lang),
              const SizedBox(height: 14),

              // 5. Crop Doctor Diagnostic Card
              _buildCropDoctorCard(context, appState.activeCrop, lang),
              const SizedBox(height: 14),

              // 6. Active Crop Advisories Preview
              _buildAdvisoryPreview(context, appState, lang),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (index) {
          setState(() => _currentTabIndex = index);
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CropDoctorScreen()));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdvisoryScreen()));
          } else if (index == 4) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          }
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_rounded), label: AppStrings.get("nav_home", lang)),
          NavigationDestination(icon: const Icon(Icons.cloud_outlined), label: AppStrings.get("nav_weather", lang)),
          NavigationDestination(icon: const Icon(Icons.health_and_safety_outlined), label: AppStrings.get("nav_crop_doctor", lang)),
          NavigationDestination(icon: const Icon(Icons.article_outlined), label: AppStrings.get("nav_advisory", lang)),
          NavigationDestination(icon: const Icon(Icons.person_outline), label: AppStrings.get("nav_profile", lang)),
        ],
      ),
    );
  }

  Widget _buildFarmerHeader(dynamic user, String lang) {
    final name = user?.name ?? "Farmer";
    final village = user?.village ?? "Pune";
    final district = user?.district ?? "Pune";
    final acres = user?.farmSizeAcres ?? 3.0;

    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryGreen.withValues(alpha: 0.08),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppTheme.primaryGreen,
              child: Text(
                name.isNotEmpty ? name[0] : "F",
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${AppStrings.get("hello_farmer", lang)}, $name 🙏",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.surfaceDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppTheme.secondaryAmber),
                      const SizedBox(width: 4),
                      Text(
                        "$village, $district",
                        style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "$acres ${lang == 'en' ? 'Acres' : 'एकर'}",
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropSelectorBar(AppState appState, String lang) {
    final selected = appState.selectedCrops;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.get("select_active_crop", lang),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            TextButton.icon(
              icon: const Icon(Icons.edit_note_rounded, size: 18),
              label: Text(AppStrings.get("manage_crops", lang)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CropSelectionScreen()),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: selected.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) {
              final crop = selected[i];
              final isActive = crop == appState.activeCrop;
              final localizedCropName = AppStrings.cropName(crop, lang);

              return ChoiceChip(
                avatar: Icon(
                  _getCropIcon(crop),
                  size: 18,
                  color: isActive ? Colors.white : AppTheme.primaryGreen,
                ),
                label: Text("$localizedCropName ($crop)"),
                selected: isActive,
                selectedColor: AppTheme.primaryGreen,
                labelStyle: TextStyle(
                  color: isActive ? Colors.white : AppTheme.surfaceDark,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) => appState.setActiveCrop(crop),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherGatekeeperCard(BuildContext context, dynamic weather, String activeCrop, String lang) {
    final status = weather?.sprayCondition ?? "GOOD TO SPRAY";
    final temp = weather?.tempC ?? 28.5;
    final humidity = weather?.humidity ?? 62;
    final wind = weather?.windKmh ?? 8.4;
    final rainProb = weather?.rainProbability ?? 10;
    final reason = weather?.sprayReason ?? "Optimal spray conditions.";
    final localizedCrop = AppStrings.cropName(activeCrop, lang);

    Color statusColor = AppTheme.sprayGood;
    IconData statusIcon = Icons.check_circle_rounded;
    String statusText = AppStrings.get("safe_to_spray", lang);
    if (status == "DO NOT SPRAY") {
      statusColor = AppTheme.sprayStop;
      statusIcon = Icons.cancel_rounded;
      statusText = AppStrings.get("do_not_spray", lang);
    } else if (status == "CAUTION") {
      statusColor = AppTheme.sprayCaution;
      statusIcon = Icons.warning_amber_rounded;
      statusText = AppStrings.get("spray_with_caution", lang);
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withValues(alpha: 0.5), width: 1.5),
      ),
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
                    Icon(Icons.shield_outlined, color: statusColor, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      AppStrings.get("weather_gatekeeper_title", lang),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "${lang == 'en' ? 'Target Crop' : 'पीक'}: $localizedCrop ($activeCrop) | $reason",
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherMetric(Icons.thermostat, "${temp.toStringAsFixed(1)}°C", AppStrings.get("current_temp", lang)),
                _buildWeatherMetric(Icons.water_drop_outlined, "$humidity%", AppStrings.get("humidity", lang)),
                _buildWeatherMetric(Icons.air_rounded, "${wind.toStringAsFixed(1)} km/h", AppStrings.get("wind_speed", lang)),
                _buildWeatherMetric(Icons.umbrella_outlined, "$rainProb%", AppStrings.get("rain_chance", lang)),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: Text(AppStrings.get("daily_forecast", lang)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherScreen()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherMetric(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryGreen),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildQuickActionGrid(BuildContext context, String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get("quick_actions", lang),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                icon: Icons.health_and_safety_rounded,
                title: AppStrings.get("nav_crop_doctor", lang),
                subtitle: lang == 'en' ? "Leaf scan AI" : "पानांचे रोग निदान",
                color: Colors.teal,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CropDoctorScreen())),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionTile(
                icon: Icons.checklist_rtl_rounded,
                title: AppStrings.get("nav_advisory", lang),
                subtitle: lang == 'en' ? "Stage-wise advice" : "कृषी तज्ज्ञ सल्ला",
                color: Colors.indigo,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdvisoryScreen())),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                icon: Icons.cloud_outlined,
                title: AppStrings.get("nav_weather", lang),
                subtitle: lang == 'en' ? "Spray safety index" : "फवारणी वेळ व अंदाज",
                color: Colors.blue.shade700,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherScreen())),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionTile(
                icon: Icons.agriculture_rounded,
                title: AppStrings.get("manage_crops", lang),
                subtitle: lang == 'en' ? "4 core crops" : "कांदा, द्राक्ष, ऊस, गहू",
                color: AppTheme.secondaryAmber,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CropSelectionScreen())),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropDoctorCard(BuildContext context, String activeCrop, String lang) {
    final localizedCrop = AppStrings.cropName(activeCrop, lang);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.document_scanner_rounded, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  "${AppStrings.get("crop_doctor_card_title", lang)} ($localizedCrop)",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.get("crop_doctor_card_desc", lang),
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: Text(AppStrings.get("btn_diagnose", lang)),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CropDoctorScreen()));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvisoryPreview(BuildContext context, AppState appState, String lang) {
    final advisories = appState.advisories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.get("active_advisories_title", lang),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdvisoryScreen()));
              },
              child: Text(AppStrings.get("view_all_advisories", lang)),
            ),
          ],
        ),
        if (advisories.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(lang == 'en' ? "No urgent alerts for active crop." : "निवडलेल्या पिकासाठी सध्या कोणताही गंभीर इशारा नाही."),
            ),
          )
        else
          ...advisories.take(2).map((adv) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.12),
                  child: const Icon(Icons.notifications_active_outlined, color: AppTheme.primaryGreen, size: 20),
                ),
                title: Text(adv.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text("${adv.cropName} • ${adv.stage}", style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdvisoryScreen()));
                },
              ),
            );
          }),
      ],
    );
  }

  IconData _getCropIcon(String name) {
    switch (name.toLowerCase()) {
      case "grapes":
        return Icons.grain_rounded;
      case "onion":
        return Icons.circle_outlined;
      case "sugarcane":
        return Icons.grass_rounded;
      case "wheat":
        return Icons.spa_rounded;
      default:
        return Icons.eco_rounded;
    }
  }
}
