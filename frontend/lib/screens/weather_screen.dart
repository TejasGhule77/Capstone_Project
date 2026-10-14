import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';
import '../theme/language_selector.dart';
import '../widgets/ui_components.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final List<String> _districts = [
    "Pune",
    "Nashik",
    "Sangli",
    "Solapur",
    "Kolhapur",
    "Satara",
    "Ahmednagar",
    "Nagpur",
    "Chhatrapati Sambhajinagar",
    "Jalgaon",
    "Amravati",
    "Latur",
    "Nanded",
    "Mumbai",
  ];

  bool _isLoading = false;

  Future<void> _selectDistrict(String district, AppState appState) async {
    setState(() => _isLoading = true);
    await appState.fetchWeatherForDistrict(district);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  IconData _getWeatherIcon(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('thunder') || c.contains('storm')) {
      return Icons.thunderstorm_rounded;
    } else if (c.contains('rain') || c.contains('drizzle') || c.contains('shower')) {
      return Icons.grain_rounded;
    } else if (c.contains('cloud') || c.contains('overcast')) {
      return Icons.wb_cloudy_rounded;
    } else if (c.contains('fog')) {
      return Icons.cloud_outlined;
    } else {
      return Icons.wb_sunny_rounded;
    }
  }

  Color _getWeatherIconColor(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('thunder') || c.contains('rain') || c.contains('shower')) {
      return const Color(0xFF0277BD);
    } else if (c.contains('cloud') || c.contains('overcast')) {
      return AppColors.textSecondary;
    } else {
      return AppColors.diwaliGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final weather = appState.weatherData;
    final activeCrop = appState.activeCrop;
    final lang = appState.language;

    final status = weather?.sprayCondition ?? "GOOD_TO_SPRAY";
    final temp = weather?.tempC ?? 28.5;
    final feelsLike = weather?.feelsLikeC ?? 30.1;
    final humidity = weather?.humidity ?? 62;
    final wind = weather?.windKmh ?? 8.4;
    final windDir = weather?.windDirection ?? "WSW";
    final rainProb = weather?.rainProbability ?? 10;
    final condition = weather?.condition ?? "Partly Cloudy";
    final reason = weather?.sprayReason ?? "Optimal wind speed and moisture.";
    final district = weather?.district ?? (appState.currentUser?.district ?? "Pune");
    final localizedCrop = AppStrings.cropName(activeCrop, lang);
    final isLive = (weather?.verificationStatus ?? "").contains("LIVE") || (weather?.verificationStatus ?? "") == "VERIFIED";

    Color statusColor = AppColors.sprayGood;
    IconData statusIcon = Icons.check_circle_rounded;
    String statusText = AppStrings.get("safe_to_spray", lang);
    Color statusBg = AppColors.sprayGoodBg;

    if (status == "DO_NOT_SPRAY" || status == "DO NOT SPRAY") {
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

    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        backgroundColor: AppColors.primaryForest,
        foregroundColor: AppColors.parchment,
        title: Text(
          AppStrings.get("weather_title", lang),
          style: AppTextStyles.serifTitle(fontSize: 18, color: AppColors.parchment),
        ),
        actions: [
          const LanguageSelectorButton(isDark: false),
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.parchment),
                  )
                : const Icon(Icons.refresh_rounded, color: AppColors.parchment),
            onPressed: _isLoading ? null : () => _selectDistrict(district, appState),
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
          SafeArea(
            child: RefreshIndicator(
              color: AppColors.primaryForest,
              onRefresh: () => appState.fetchWeatherForDistrict(district),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Location Selector & Live Status Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on, color: AppColors.diwaliGold, size: 22),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _districts.any((d) => d.toLowerCase() == district.toLowerCase())
                                              ? _districts.firstWhere((d) => d.toLowerCase() == district.toLowerCase())
                                              : _districts.first,
                                          isExpanded: true,
                                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryForest),
                                          style: AppTextStyles.serifTitle(fontSize: 16, fontWeight: FontWeight.bold),
                                          dropdownColor: AppColors.cardCream,
                                          onChanged: _isLoading
                                              ? null
                                              : (newDistrict) {
                                                  if (newDistrict != null) {
                                                    _selectDistrict(newDistrict, appState);
                                                  }
                                                },
                                          items: _districts.map((d) {
                                            return DropdownMenuItem<String>(
                                              value: d,
                                              child: Text(
                                                "$d, Maharashtra",
                                                style: const TextStyle(color: AppColors.textPrimary),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isLive ? AppColors.sprayGoodBg : AppColors.demoBadgeBg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isLive ? AppColors.sprayGoodBorder : AppColors.demoBadgeText.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isLive) ...[
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryForest,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      isLive
                                          ? (lang == 'mr' ? "थेट हवामान" : (lang == 'hi' ? "लाइव मौसम" : "LIVE WEATHER"))
                                          : AppStrings.get("verified_demo", lang),
                                      style: TextStyle(
                                        color: isLive ? AppColors.primaryForest : AppColors.demoBadgeText,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Quick District Chips
                          SizedBox(
                            height: 34,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _districts.take(8).length,
                              separatorBuilder: (_, __) => const SizedBox(width: 6),
                              itemBuilder: (context, i) {
                                final d = _districts[i];
                                final isSelected = d.toLowerCase() == district.toLowerCase();
                                return ChoiceChip(
                                  label: Text(d, style: TextStyle(fontSize: 11.5, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                                  selected: isSelected,
                                  selectedColor: AppColors.primaryForest,
                                  backgroundColor: AppColors.sageBg.withValues(alpha: 0.5),
                                  labelStyle: TextStyle(
                                    color: isSelected ? AppColors.parchment : AppColors.textPrimary,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                      color: isSelected ? AppColors.primaryForest : AppColors.border,
                                    ),
                                  ),
                                  onSelected: _isLoading ? null : (_) => _selectDistrict(d, appState),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Current Weather Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardCream,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.border, width: 1.2),
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.sageBg,
                            AppColors.cardCream,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: AppShadows.card,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${temp.toStringAsFixed(1)}°C",
                                      style: AppTextStyles.serifTitle(
                                        fontSize: 44,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                    Text(
                                      "${AppStrings.get("feels_like", lang)} ${feelsLike.toStringAsFixed(1)}°C • $condition",
                                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(_getWeatherIcon(condition), size: 56, color: _getWeatherIconColor(condition)),
                            ],
                          ),
                          const SizedBox(height: 18),
                          const DottedSketchDivider(height: 1),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(child: MetricTile(icon: Icons.water_drop_rounded, value: "$humidity%", label: AppStrings.get("humidity", lang), color: AppColors.fernGreen)),
                              const SizedBox(width: 8),
                              Expanded(child: MetricTile(icon: Icons.air_rounded, value: "${wind.toStringAsFixed(1)} km/h\n($windDir)", label: AppStrings.get("wind_speed", lang), color: AppColors.textSecondary)),
                              const SizedBox(width: 8),
                              Expanded(child: MetricTile(icon: Icons.umbrella_rounded, value: "$rainProb%", label: AppStrings.get("rain_chance", lang), color: const Color(0xFF0277BD))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Weather Gatekeeper Decision Card with Washi Tape
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.cardCream,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor, width: 1.8),
                            boxShadow: AppShadows.card,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: statusBg,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(statusIcon, color: statusColor, size: 28),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppStrings.get("weather_gatekeeper_title", lang).toUpperCase(),
                                          style: AppTextStyles.eyebrow(color: AppColors.textSecondary).copyWith(fontSize: 11),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          statusText,
                                          style: AppTextStyles.serifTitle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            color: statusColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                                ),
                                child: Text(
                                  "${lang == 'en' ? 'Target Crop' : 'पीक'}: $localizedCrop ($activeCrop)\n$reason",
                                  style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.textSecondary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      lang == 'en'
                                          ? "Safety Thresholds: Wind < 15 km/h, Rain Prob < 30%, Temp 15-32°C."
                                          : (lang == 'hi'
                                              ? "सुरक्षा मानदंड: हवा < 15 किमी/घंटा, बारिश < 30%, तापमान 15-32°C।"
                                              : "सुरक्षा निकष: वारा < १५ किमी/तास, पाऊस < ३०%, तापमान १५-३२°C."),
                                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Positioned(
                          top: -8,
                          child: WashiTape(width: 76, height: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Dynamic Hourly Spray Window Forecast
                    SectionHeader(
                      title: AppStrings.get("hourly_forecast", lang),
                      eyebrow: "Timeline",
                      subtitle: lang == 'en' ? "Microclimate window prediction" : "फवारणी वेळेचा २४ तासांचा अंदाज",
                      icon: Icons.schedule_rounded,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: Builder(
                        builder: (context) {
                          final hourlyList = weather?.hourly ?? [];
                          final count = hourlyList.isNotEmpty ? hourlyList.length : 4;

                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: count,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (ctx, i) {
                              final item = hourlyList.isNotEmpty && hourlyList.length > i
                                  ? hourlyList[i]
                                  : {
                                      "time": "${8 + i * 3}:00",
                                      "temp_c": 24.0 + i * 2,
                                      "humidity_pct": 70 - i * 5,
                                      "spray_status": i == 3 ? "DO_NOT_SPRAY" : (i == 2 ? "CAUTION" : "GOOD_TO_SPRAY"),
                                    };

                              final spray = (item['spray_status'] ?? 'GOOD_TO_SPRAY').toString().replaceAll(' ', '_');
                              Color color = AppColors.sprayGood;
                              String localSpray = lang == 'en' ? "SAFE" : (lang == 'hi' ? "उपयुक्त" : "योग्य");
                              if (spray == "DO_NOT_SPRAY") {
                                color = AppColors.sprayStop;
                                localSpray = lang == 'en' ? "STOP" : (lang == 'hi' ? "रोकें" : "थांबा");
                              } else if (spray == "CAUTION") {
                                color = AppColors.sprayCaution;
                                localSpray = lang == 'en' ? "CAUTION" : (lang == 'hi' ? "सावधान" : "सावध");
                              }

                              final itemTemp = item['temp_c'] ?? temp;
                              final itemTime = item['time'] ?? '12:00';
                              final itemRain = item['rain_prob'] != null ? "${item['rain_prob']}%" : null;

                              return Container(
                                width: 114,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.cardCream,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
                                  boxShadow: AppShadows.card,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(itemTime, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary)),
                                    const SizedBox(height: 2),
                                    Text(
                                      "${(itemTemp is num ? itemTemp.toDouble() : double.tryParse(itemTemp.toString()) ?? 28.0).toStringAsFixed(1)}°C",
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                                    ),
                                    if (itemRain != null) ...[
                                      const SizedBox(height: 1),
                                      Text("💧 $itemRain", style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                    ],
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        localSpray,
                                        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Dynamic Agronomy Multi-Day Forecast
                    SectionHeader(
                      title: AppStrings.get("daily_forecast", lang),
                      eyebrow: "5-Day Outlook",
                      subtitle: lang == 'en' ? "5-day agricultural weather trends" : "५ दिवसांचा कृषी हवामान अंदाज",
                      icon: Icons.calendar_month_rounded,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardCream,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border, width: 1.2),
                        boxShadow: AppShadows.card,
                      ),
                      child: Builder(
                        builder: (context) {
                          final dailyList = weather?.daily ?? [];
                          if (dailyList.isEmpty) {
                            return Column(
                              children: [
                                _buildDailyRow(
                                  lang == 'en' ? "Today" : "आज",
                                  "${(temp - 4).toStringAsFixed(0)}° / ${(temp + 4).toStringAsFixed(0)}°C",
                                  condition,
                                  "Optimal (06:00 - 11:30 AM)",
                                  AppColors.sprayGood,
                                ),
                                const DottedSketchDivider(height: 16),
                                _buildDailyRow(
                                  lang == 'en' ? "Tomorrow" : "उद्या",
                                  "${(temp - 5).toStringAsFixed(0)}° / ${(temp + 3).toStringAsFixed(0)}°C",
                                  "Scattered Clouds",
                                  "Morning spraying suitable",
                                  AppColors.sprayGood,
                                ),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              for (int idx = 0; idx < dailyList.length; idx++) ...[
                                if (idx > 0) const DottedSketchDivider(height: 18),
                                () {
                                  final d = dailyList[idx];
                                  final dayRaw = (d['day'] ?? '').toString();
                                  String dayTitle = dayRaw;
                                  if (dayRaw == "Today") {
                                    dayTitle = lang == 'en' ? "Today" : (lang == 'hi' ? "आज" : "आज");
                                  } else if (dayRaw == "Tomorrow") {
                                    dayTitle = lang == 'en' ? "Tomorrow" : (lang == 'hi' ? "कल" : "उद्या");
                                  }

                                  final maxT = (d['temp_max'] as num?)?.toDouble() ?? (temp + 3);
                                  final minT = (d['temp_min'] as num?)?.toDouble() ?? (temp - 5);
                                  final cond = (d['condition'] ?? 'Partly Cloudy').toString();
                                  final rain = (d['rain_pct'] as num?)?.toInt() ?? 10;
                                  final rec = (d['spray_recommendation'] ?? 'Suitable').toString();

                                  Color windowColor = AppColors.sprayGood;
                                  if (rec.contains("DO NOT SPRAY") || rain > 40) {
                                    windowColor = AppColors.sprayStop;
                                  } else if (rec.contains("Caution") || rec.contains("Early morning") || maxT > 33) {
                                    windowColor = AppColors.sprayCaution;
                                  }

                                  return _buildDailyRow(
                                    dayTitle,
                                    "${minT.toStringAsFixed(0)}° / ${maxT.toStringAsFixed(0)}°C",
                                    "$cond • $rain% 💧",
                                    rec,
                                    windowColor,
                                  );
                                }(),
                              ],
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRow(String day, String temp, String condition, String window, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(condition, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(temp, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(
                  window,
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: color),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
