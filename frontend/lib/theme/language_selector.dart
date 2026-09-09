import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class LanguageSelectorButton extends StatelessWidget {
  final bool isDark;
  const LanguageSelectorButton({super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final current = appState.language;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade200 : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey.shade400 : Colors.white38,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current,
          icon: Icon(
            Icons.translate_rounded,
            size: 16,
            color: isDark ? Colors.black87 : Colors.white,
          ),
          dropdownColor: Colors.white,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.black87 : Colors.white,
          ),
          items: const [
            DropdownMenuItem(
              value: "mr",
              child: Text("मराठी", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
            ),
            DropdownMenuItem(
              value: "hi",
              child: Text("हिंदी", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
            ),
            DropdownMenuItem(
              value: "en",
              child: Text("English", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
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
