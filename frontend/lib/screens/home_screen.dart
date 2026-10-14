import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';
import '../theme/language_selector.dart';
import '../widgets/ui_components.dart';
import 'crop_selection_screen.dart';
import 'weather_screen.dart';
import 'crop_doctor_screen.dart';
import 'advisory_screen.dart';
import 'profile_screen.dart';
import 'pesticide_inventory_screen.dart';
import 'pesticide_comparison_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentTabIndex = 0;
  late AnimationController _cardAnimController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _cardAnimController, curve: Curves.easeOut);
    _cardAnimController.forward();
  }

  @override
  void dispose() {
    _cardAnimController.dispose();
    super.dispose();
  }

  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    final weather = appState.weatherData;
    final lang = appState.language;

    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        backgroundColor: AppColors.primaryForest,
        foregroundColor: AppColors.parchment,
        title: Row(
          children: [
            const AgriIntelLogo(size: 36, onDark: true),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.get("app_title", lang),
                    style: AppTextStyles.serifTitle(fontSize: 17.5, color: AppColors.parchment),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    AppStrings.get("app_tagline", lang),
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppColors.parchment.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          const LanguageSelectorButton(isDark: false),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.parchment),
            tooltip: AppStrings.get("refresh", lang),
            onPressed: () => appState.refreshAllData(),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: AppColors.parchment),
            tooltip: AppStrings.get("nav_profile", lang),
            onPressed: () => _navigateTo(const ProfileScreen()),
          ),
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
          RefreshIndicator(
            color: AppColors.primaryForest,
            onRefresh: () => appState.refreshAllData(),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Farmer & Farm Hero Greeting Card
                    _buildFarmerHeader(user, lang),
                    const SizedBox(height: 14),

                    // 2. Smart IoT & AI Farm Insights Banner
                    _buildSmartFarmBanner(lang),
                    const SizedBox(height: 14),

                    // 3. Interactive Crop Selector Bar
                    _buildCropSelectorBar(appState, lang),
                    const SizedBox(height: 14),

                    // 4. Weather Gatekeeper Card
                    _buildWeatherGatekeeperCard(context, weather, appState.activeCrop, lang),
                    const SizedBox(height: 16),

                    // 5. Quick Action Grid
                    _buildQuickActionGrid(context, lang),
                    const SizedBox(height: 16),

                    // 6. Crop Doctor Diagnostic Prompt Card
                    _buildCropDoctorCard(context, appState.activeCrop, lang),
                    const SizedBox(height: 16),

                    // 7. Active Crop Advisories Preview
                    _buildAdvisoryPreview(context, appState, lang),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        backgroundColor: AppColors.cardCream,
        indicatorColor: AppColors.fernGreen.withValues(alpha: 0.18),
        onDestinationSelected: (index) {
          setState(() => _currentTabIndex = index);
          if (index == 1) {
            _navigateTo(const WeatherScreen());
          } else if (index == 2) {
            _navigateTo(const CropDoctorScreen());
          } else if (index == 3) {
            _navigateTo(const AdvisoryScreen());
          } else if (index == 4) {
            _navigateTo(const ProfileScreen());
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded, color: AppColors.primaryForest),
            label: AppStrings.get("nav_home", lang),
          ),
          NavigationDestination(
            icon: const Icon(Icons.cloud_outlined),
            selectedIcon: const Icon(Icons.cloud_rounded, color: AppColors.primaryForest),
            label: AppStrings.get("nav_weather", lang),
          ),
          NavigationDestination(
            icon: const Icon(Icons.health_and_safety_outlined),
            selectedIcon: const Icon(Icons.health_and_safety_rounded, color: AppColors.primaryForest),
            label: AppStrings.get("nav_crop_doctor", lang),
          ),
          NavigationDestination(
            icon: const Icon(Icons.article_outlined),
            selectedIcon: const Icon(Icons.article_rounded, color: AppColors.primaryForest),
            label: AppStrings.get("nav_advisory", lang),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded, color: AppColors.primaryForest),
            label: AppStrings.get("nav_profile", lang),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerHeader(UserModel? user, String lang) {
    final name = user?.name ?? "Farmer";
    final village = user?.village ?? "Pune";
    final district = user?.district ?? "Pune";
    final acres = user?.farmSizeAcres ?? 3.5;
    final isVerified = user?.verificationStatus == "VERIFIED";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardCream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryForest, width: 2),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/farmer_ecrop.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/farmer_iot_hero.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.primaryForest,
                        child: Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : "F",
                            style: const TextStyle(color: AppColors.parchment, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: AppColors.cardCream, shape: BoxShape.circle),
                child: const Icon(Icons.verified_rounded, color: AppColors.fernGreen, size: 18),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "${AppStrings.get("hello_farmer", lang)}, $name 👋",
                        style: AppTextStyles.serifTitle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.diwaliGold),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        "$village, $district",
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.sageBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        "$acres ${lang == 'en' ? 'Acres' : 'एकर'}",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryForest),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: isVerified ? AppColors.sprayGoodBg : AppColors.demoBadgeBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isVerified ? AppColors.sprayGoodBorder : AppColors.demoBadgeText.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isVerified ? Icons.verified_rounded : Icons.shield_outlined,
                            size: 11,
                            color: isVerified ? AppColors.primaryForest : AppColors.demoBadgeText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isVerified ? (lang == 'en' ? "VERIFIED FARMER" : "सत्यापित शेतकरी") : AppStrings.get("verified_demo", lang),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isVerified ? AppColors.primaryForest : AppColors.demoBadgeText,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartFarmBanner(String lang) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/tractor_sunrise.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.primaryForest,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.deepSectionDark.withValues(alpha: 0.88),
                    AppColors.deepSectionDark.withValues(alpha: 0.45),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.diwaliGold,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "PRECISION INTELLIGENCE",
                      style: AppTextStyles.eyebrow(color: Colors.black87).copyWith(fontSize: 9.5),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lang == 'en' ? "Smart Insights • Better Yields" : "स्मार्ट शेती तंत्रज्ञान • शाश्वत नफा",
                    style: AppTextStyles.serifTitle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.parchment,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lang == 'en' ? "IoT + Agromet + AI Decision Systems" : "हवामान, ड्रोन व एआय आधारित सल्ला",
                    style: TextStyle(
                      color: AppColors.parchment.withValues(alpha: 0.9),
                      fontSize: 11.5,
                    ),
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
            Row(
              children: [
                const Icon(Icons.grass_rounded, size: 18, color: AppColors.primaryForest),
                const SizedBox(width: 6),
                Text(
                  AppStrings.get("select_active_crop", lang),
                  style: AppTextStyles.serifTitle(fontSize: 14.5, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            TextButton.icon(
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: Text(AppStrings.get("manage_crops", lang)),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: AppColors.primaryForest,
              ),
              onPressed: () => _navigateTo(const CropSelectionScreen()),
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
                  color: isActive ? AppColors.parchment : AppColors.primaryForest,
                ),
                label: Text("$localizedCropName ($crop)"),
                selected: isActive,
                selectedColor: AppColors.primaryForest,
                backgroundColor: AppColors.cardCream,
                labelStyle: TextStyle(
                  color: isActive ? AppColors.parchment : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isActive ? AppColors.primaryForest : AppColors.border,
                    width: isActive ? 1.5 : 1.0,
                  ),
                ),
                onSelected: (_) => appState.setActiveCrop(crop),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherGatekeeperCard(BuildContext context, WeatherData? weather, String activeCrop, String lang) {
    final status = (weather?.sprayCondition ?? "GOOD_TO_SPRAY").toString().replaceAll(' ', '_');
    final temp = weather?.tempC ?? 28.5;
    final humidity = weather?.humidity ?? 62;
    final wind = weather?.windKmh ?? 8.4;
    final rainProb = weather?.rainProbability ?? 10;
    final reason = weather?.sprayReason ?? "Optimal spray conditions.";
    final localizedCrop = AppStrings.cropName(activeCrop, lang);

    Color statusColor = AppColors.sprayGood;
    IconData statusIcon = Icons.check_circle_rounded;
    String statusText = AppStrings.get("safe_to_spray", lang);
    Color statusBg = AppColors.sprayGoodBg;

    if (status == "DO_NOT_SPRAY") {
      statusColor = AppColors.sprayStop;
      statusIcon = Icons.cancel_rounded;
      statusText = AppStrings.get("do_not_spray", lang);
      statusBg = AppColors.sprayStopBg;
    } else if (status == "CAUTION") {
      statusColor = AppColors.sprayCaution;
      statusIcon = Icons.warning_amber_rounded;
      statusText = AppStrings.get("spray_with_caution", lang);
      statusBg = AppColors.sprayCautionBg;
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardCream,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withValues(alpha: 0.35), width: 1.5),
            boxShadow: AppShadows.card,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.shield_rounded, color: statusColor, size: 20),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              AppStrings.get("weather_gatekeeper_title", lang),
                              style: AppTextStyles.serifTitle(fontSize: 14.5, fontWeight: FontWeight.bold),
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
                        color: statusBg,
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
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.sageBg.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primaryForest),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${lang == 'en' ? 'Target Crop' : 'पीक'}: $localizedCrop ($activeCrop) • $reason",
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: MetricTile(icon: Icons.thermostat_rounded, value: "${temp.toStringAsFixed(1)}°C", label: AppStrings.get("current_temp", lang), color: AppColors.terracotta)),
                    const SizedBox(width: 6),
                    Expanded(child: MetricTile(icon: Icons.water_drop_rounded, value: "$humidity%", label: AppStrings.get("humidity", lang), color: AppColors.fernGreen)),
                    const SizedBox(width: 6),
                    Expanded(child: MetricTile(icon: Icons.air_rounded, value: "${wind.toStringAsFixed(1)} km/h", label: AppStrings.get("wind_speed", lang), color: AppColors.textSecondary)),
                    const SizedBox(width: 6),
                    Expanded(child: MetricTile(icon: Icons.umbrella_rounded, value: "$rainProb%", label: AppStrings.get("rain_chance", lang), color: const Color(0xFF0277BD))),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: Text(AppStrings.get("daily_forecast", lang)),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: AppColors.primaryForest,
                    ),
                    onPressed: () => _navigateTo(const WeatherScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Positioned(
          top: -8,
          child: WashiTape(width: 74, height: 16),
        ),
      ],
    );
  }

  Widget _buildQuickActionGrid(BuildContext context, String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: AppStrings.get("quick_actions", lang),
          eyebrow: "Shortcuts",
          subtitle: lang == 'en' ? "Instant AI decisions & farm tools" : "झटपट एआय निर्णय व शेती साधने",
          icon: Icons.dashboard_customize_rounded,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                icon: Icons.health_and_safety_rounded,
                title: AppStrings.get("nav_crop_doctor", lang),
                subtitle: lang == 'en' ? "Leaf scan AI" : "पानांचे रोग निदान",
                color: const Color(0xFF00897B),
                onTap: () => _navigateTo(const CropDoctorScreen()),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionTile(
                icon: Icons.checklist_rtl_rounded,
                title: AppStrings.get("nav_advisory", lang),
                subtitle: lang == 'en' ? "Stage-wise advice" : "कृषी तज्ज्ञ सल्ला",
                color: const Color(0xFF3949AB),
                onTap: () => _navigateTo(const AdvisoryScreen()),
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
                color: const Color(0xFF0277BD),
                onTap: () => _navigateTo(const WeatherScreen()),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionTile(
                icon: Icons.agriculture_rounded,
                title: AppStrings.get("manage_crops", lang),
                subtitle: lang == 'en' ? "4 core crops" : "कांदा, द्राक्ष, ऊस, गहू",
                color: AppColors.diwaliGold,
                onTap: () => _navigateTo(const CropSelectionScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                icon: Icons.inventory_2_rounded,
                title: lang == 'en' ? "Chemical Locker" : "कीटकनाशक साठा",
                subtitle: lang == 'en' ? "OCR bottle scan & stock" : "बाटली स्कॅन व साठा",
                color: AppColors.primaryForest,
                onTap: () => _navigateTo(const PesticideInventoryScreen()),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionTile(
                icon: Icons.compare_arrows_rounded,
                title: lang == 'en' ? "Compare Pesticides" : "कीटकनाशक तुलना",
                subtitle: lang == 'en' ? "Multi-criteria ranking" : "योग्य औषध निवड",
                color: AppColors.terracotta,
                onTap: () => _navigateTo(const PesticideComparisonScreen()),
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
    return Material(
      color: AppColors.cardCream,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCropDoctorCard(BuildContext context, String activeCrop, String lang) {
    final localizedCrop = AppStrings.cropName(activeCrop, lang);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardCream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Image.asset(
                      'assets/images/crop_field_sun.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.primaryForest.withValues(alpha: 0.12),
                        child: const Icon(Icons.document_scanner_rounded, color: AppColors.primaryForest, size: 24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${AppStrings.get("crop_doctor_card_title", lang)} ($localizedCrop)",
                        style: AppTextStyles.serifTitle(fontSize: 15.5, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        lang == 'en' ? "AI Leaf Disease Diagnostics" : "एआय पानांचे रोग निदान",
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.get("crop_doctor_card_desc", lang),
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.35),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: Text(AppStrings.get("btn_diagnose", lang)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryForest,
                  foregroundColor: AppColors.parchment,
                ),
                onPressed: () => _navigateTo(const CropDoctorScreen()),
              ),
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
        SectionHeader(
          title: AppStrings.get("active_advisories_title", lang),
          eyebrow: "Live Feed",
          icon: Icons.notifications_active_outlined,
          trailing: TextButton(
            onPressed: () => _navigateTo(const AdvisoryScreen()),
            style: TextButton.styleFrom(foregroundColor: AppColors.primaryForest),
            child: Text(AppStrings.get("view_all_advisories", lang)),
          ),
        ),
        const SizedBox(height: 4),
        if (advisories.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardCream,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Text(
                lang == 'en' ? "No urgent alerts for active crop." : "निवडलेल्या पिकासाठी सध्या कोणताही गंभीर इशारा नाही.",
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ...advisories.take(2).map((adv) {
            Color alertColor = adv.alertType == "URGENT" || adv.alertType == "CRITICAL"
                ? AppColors.sprayStop
                : (adv.alertType == "WARNING" ? AppColors.diwaliGold : AppColors.primaryForest);

            return Material(
              color: AppColors.cardCream,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _navigateTo(const AdvisoryScreen()),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppShadows.card,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: alertColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.notifications_active_outlined, color: alertColor, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              adv.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${adv.cropName} • ${adv.stage}",
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.primaryForest),
                    ],
                  ),
                ),
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
