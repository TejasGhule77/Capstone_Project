import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'organic_decorations.dart';

class SafetyWarningCard extends StatelessWidget {
  final List<String> warnings;
  final String weatherGatekeeperStatus;
  final double? windSpeed;
  final double? rainProb;
  final double? temperature;
  final double? humidity;
  final String? disclaimer;

  const SafetyWarningCard({
    super.key,
    required this.warnings,
    required this.weatherGatekeeperStatus,
    this.windSpeed,
    this.rainProb,
    this.temperature,
    this.humidity,
    this.disclaimer,
  });

  @override
  Widget build(BuildContext context) {
    final isUnsafe = weatherGatekeeperStatus == "DO_NOT_SPRAY";
    final isCaution = weatherGatekeeperStatus == "CAUTION";

    Color headerBg = AppColors.sprayGoodBg;
    Color headerBorder = AppColors.sprayGoodBorder;
    Color headerColor = AppColors.sprayGood;
    IconData headerIcon = Icons.verified_user_rounded;
    String headerTitle = "SPRAY GATEKEEPER: SAFE TO SPRAY";
    String headerSubtitle = "Microclimate parameters are optimal for foliar spray absorption.";

    if (isUnsafe) {
      headerBg = AppColors.sprayStopBg;
      headerBorder = AppColors.sprayStopBorder;
      headerColor = AppColors.sprayStop;
      headerIcon = Icons.gpp_bad_outlined;
      headerTitle = "SPRAY GATEKEEPER: DO NOT SPRAY";
      headerSubtitle = "Current microclimate conditions exceed agronomic spray safety limits.";
    } else if (isCaution) {
      headerBg = AppColors.sprayCautionBg;
      headerBorder = AppColors.sprayCautionBorder;
      headerColor = AppColors.sprayCaution;
      headerIcon = Icons.warning_amber_rounded;
      headerTitle = "SPRAY GATEKEEPER: SPRAY WITH CAUTION";
      headerSubtitle = "Marginal conditions detected. Adhere to safety buffer guidelines.";
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Card(
          elevation: 0,
          color: AppColors.cardCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: headerBorder,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weather Gatekeeper Status Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: headerBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: headerBorder,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.cardCream,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: headerColor.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          headerIcon,
                          color: headerColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              headerTitle,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: headerColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              headerSubtitle,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: headerColor == AppColors.sprayStop
                                    ? const Color(0xFFB71C1C)
                                    : (headerColor == AppColors.sprayCaution
                                        ? const Color(0xFF9A3412)
                                        : const Color(0xFF2E7D32)),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Weather Context Metrics Bar
                if (windSpeed != null || rainProb != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.sageBg.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (windSpeed != null)
                          _buildMetric(
                            "Wind Speed",
                            "${windSpeed!.toStringAsFixed(1)} km/h",
                            windSpeed! > 15 ? Icons.warning_amber_rounded : Icons.air_rounded,
                            windSpeed! > 15 ? AppColors.sprayStop : AppColors.textSecondary,
                          ),
                        if (rainProb != null)
                          _buildMetric(
                            "Rain Chance",
                            "${rainProb!.toInt()}%",
                            rainProb! > 40 ? Icons.thunderstorm_outlined : Icons.water_drop_outlined,
                            rainProb! > 40 ? AppColors.sprayStop : const Color(0xFF0277BD),
                          ),
                        if (temperature != null)
                          _buildMetric(
                            "Temperature",
                            "${temperature!.toStringAsFixed(1)}°C",
                            Icons.thermostat_rounded,
                            AppColors.terracotta,
                          ),
                        if (humidity != null)
                          _buildMetric(
                            "Humidity",
                            "${humidity!.toInt()}%",
                            Icons.opacity_rounded,
                            AppColors.fernGreen,
                          ),
                      ],
                    ),
                  ),
                ],

                // Agronomic Safety Warnings List
                if (warnings.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(Icons.shield_outlined, size: 16, color: AppColors.sprayStop),
                      const SizedBox(width: 6),
                      Text(
                        "Critical Safety & Compliance Warnings",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.sprayStop,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...warnings.map((w) => Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.sprayStopBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.sprayStopBorder),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.error_outline_rounded, size: 16, color: AppColors.sprayStop),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  w,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textPrimary,
                                    height: 1.35,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],

                // PPE Reminder
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.goldLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.diwaliGold.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.masks_outlined, size: 20, color: AppColors.diwaliGold),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Mandatory PPE: Always wear protective goggles, respirator mask, chemical gloves, and long-sleeved clothing during pesticide preparation and spraying.",
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF5D3B00), height: 1.35, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),

                // Mandatory Disclaimer Text
                if (disclaimer != null && disclaimer!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    disclaimer!,
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
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

  Widget _buildMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
