import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'app_theme.dart';

class LanguageSelectorButton extends StatelessWidget {
  final bool isDark;
  const LanguageSelectorButton({super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final current = appState.language;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? AppColors.deepSectionDark.withValues(alpha: 0.12) : AppColors.cardCream.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.parchment.withValues(alpha: 0.5),
          width: 1.2,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current,
          icon: Icon(
            Icons.translate_rounded,
            size: 16,
            color: isDark ? AppColors.primaryForest : AppColors.parchment,
          ),
          dropdownColor: AppColors.cardCream,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.primaryForest : AppColors.parchment,
          ),
          items: const [
            DropdownMenuItem(
              value: "mr",
              child: Text("मराठी", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            ),
            DropdownMenuItem(
              value: "hi",
              child: Text("हिंदी", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            ),
            DropdownMenuItem(
              value: "en",
              child: Text("English", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            ),
          ],
          onChanged: (val) {
            if (val != null) {
              appState.setLanguage(val);
            }
          },
        ),
      ),
    );
  }
}
