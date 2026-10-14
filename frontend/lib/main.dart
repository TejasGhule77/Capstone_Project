import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/crop_selection_screen.dart';
import 'screens/weather_screen.dart';
import 'screens/crop_doctor_screen.dart';
import 'screens/advisory_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/pesticide_inventory_screen.dart';
import 'screens/add_pesticide_screen.dart';
import 'screens/pesticide_comparison_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AgriIntelApp());
}

class AgriIntelApp extends StatelessWidget {
  const AgriIntelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: MaterialApp(
        title: 'AgriIntel',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/crops': (context) => const CropSelectionScreen(),
          '/weather': (context) => const WeatherScreen(),
          '/crop-doctor': (context) => const CropDoctorScreen(),
          '/advisory': (context) => const AdvisoryScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/inventory': (context) => const PesticideInventoryScreen(),
          '/inventory/add': (context) => const AddPesticideScreen(),
          '/inventory/compare': (context) => const PesticideComparisonScreen(),
        },
      ),
    );
  }
}
