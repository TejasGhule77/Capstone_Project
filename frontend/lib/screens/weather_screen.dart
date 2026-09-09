import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';
import '../theme/language_selector.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final weather = appState.weatherData;
    final activeCrop = appState.activeCrop;
    final lang = appState.language;

    final status = weather?.sprayCondition ?? "GOOD TO SPRAY";
    final temp = weather?.tempC ?? 28.5;
    final feelsLike = weather?.feelsLikeC ?? 30.1;
    final humidity = weather?.humidity ?? 62;
    final wind = weather?.windKmh ?? 8.4;
    final rainProb = weather?.rainProbability ?? 10;
    final condition = weather?.condition ?? "Partly Cloudy";
    final reason = weather?.sprayReason ?? "Optimal wind speed and moisture.";
    final district = weather?.district ?? "Pune";
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

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get("weather_title", lang)),
        actions: [
          const LanguageSelectorButton(),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => appState.refreshAllData(),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => appState.refreshAllData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Location & Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppTheme.secondaryAmber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          "$district, Maharashtra",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.demoBadgeBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.demoBadgeText.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        AppStrings.get("verified_demo", lang),
                        style: const TextStyle(color: AppTheme.demoBadgeText, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Current Weather Card
                Card(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade50,
                          Colors.white,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${temp.toStringAsFixed(1)}°C",
                                  style: const TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.surfaceDark,
                                  ),
                                ),
                                Text(
                                  "${AppStrings.get("feels_like", lang)} ${feelsLike.toStringAsFixed(1)}°C • $condition",
                                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                                ),
                              ],
                            ),
                            const Icon(Icons.wb_sunny_rounded, size: 56, color: AppTheme.secondaryAmber),
                          ],
                        ),
                        const Divider(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildDetailItem(Icons.water_drop_outlined, "$humidity%", AppStrings.get("humidity", lang)),
                            _buildDetailItem(Icons.air_rounded, "${wind.toStringAsFixed(1)} km/h", AppStrings.get("wind_speed", lang)),
                            _buildDetailItem(Icons.umbrella_outlined, "$rainProb%", AppStrings.get("rain_chance", lang)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Weather Gatekeeper Decision Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: statusColor, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(statusIcon, color: statusColor, size: 28),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.get("weather_gatekeeper_title", lang).toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    statusText,
                                    style: TextStyle(
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
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "${lang == 'en' ? 'Target Crop' : 'पीक'}: $localizedCrop ($activeCrop)\n$reason",
                            style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.info_outline, size: 14, color: Colors.black54),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                lang == 'en'
                                    ? "Safety Thresholds: Wind < 15 km/h, Rain Prob < 30%, Temp 15-32°C."
                                    : "सुरक्षा निकष: वारा < १५ किमी/तास, पाऊस < ३०%, तापमान १५-३२°C.",
                                style: const TextStyle(fontSize: 11, color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Hourly Spray Window Forecast
                Text(
                  AppStrings.get("hourly_forecast", lang),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.surfaceDark),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: (weather?.hourly.length ?? 0) > 0 ? weather!.hourly.length : 4,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (ctx, i) {
                      final item = (weather != null && weather.hourly.length > i)
                          ? weather.hourly[i]
                          : {
                              "time": "${8 + i * 3}:00",
                              "temp_c": 24.0 + i * 2,
                              "humidity_pct": 70 - i * 5,
                              "spray_status": i == 3 ? "DO NOT SPRAY" : (i == 2 ? "CAUTION" : "GOOD TO SPRAY"),
                            };

                      final spray = item['spray_status'] ?? 'GOOD TO SPRAY';
                      Color color = AppTheme.sprayGood;
                      String localSpray = lang == 'en' ? "SAFE" : "योग्य";
                      if (spray == "DO NOT SPRAY") {
                        color = AppTheme.sprayStop;
                        localSpray = lang == 'en' ? "STOP" : "थांबा";
                      } else if (spray == "CAUTION") {
                        color = AppTheme.sprayCaution;
                        localSpray = lang == 'en' ? "CAUTION" : "सावध";
                      }

                      return Container(
                        width: 110,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(item['time'] ?? '10:00', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text("${item['temp_c']}°C", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                  ),
                ),
                const SizedBox(height: 18),

                // 3-Day Agronomy Forecast
                Text(
                  AppStrings.get("daily_forecast", lang),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.surfaceDark),
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        _buildDailyRow(
                          lang == 'en' ? "Today" : (lang == 'hi' ? "आज" : "आज"),
                          "22° / 32°C",
                          lang == 'en' ? "Partly Cloudy" : "अंशतः ढगाळ",
                          lang == 'en' ? "Ideal (06:00 - 11:30 AM)" : "योग्य वेळ (सकाळी ०६:०० - ११:३०)",
                          AppTheme.sprayGood,
                        ),
                        const Divider(),
                        _buildDailyRow(
                          lang == 'en' ? "Tomorrow" : (lang == 'hi' ? "कल" : "उद्या"),
                          "21° / 31°C",
                          lang == 'en' ? "Scattered Showers" : "पावसाची शक्यता",
                          lang == 'en' ? "DO NOT SPRAY (Rain 65%)" : "फवारणी करू नका (पाऊस ६५%)",
                          AppTheme.sprayStop,
                        ),
                        const Divider(),
                        _buildDailyRow(
                          lang == 'en' ? "Friday" : (lang == 'hi' ? "परसों" : "परवा"),
                          "20° / 30°C",
                          lang == 'en' ? "Sunny Clear" : "निरभ्र ऊन",
                          lang == 'en' ? "Ideal (07:00 - 12:00 PM)" : "योग्य वेळ (सकाळी ०७:०० - १२:००)",
                          AppTheme.sprayGood,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 24),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }

  Widget _buildDailyRow(String day, String temp, String condition, String window, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(condition, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(temp, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text(window, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
