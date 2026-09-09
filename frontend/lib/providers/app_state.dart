import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  UserModel? _currentUser;
  WeatherData? _weatherData;
  List<CropItem> _allCrops = [];
  List<AdvisoryItemModel> _advisories = [];
  List<AHPCropRank> _ahpRankings = [];
  String _activeCrop = "Grapes";
  String _language = "mr"; // Default to Marathi with instant Marathi/Hindi/English toggle
  bool _isLoading = false;
  bool _isBackendOnline = false;

  AppState() {
    loadFromStorage();
  }

  // Getters
  UserModel? get currentUser => _currentUser;
  WeatherData? get weatherData => _weatherData;
  List<CropItem> get allCrops => _allCrops;
  List<AdvisoryItemModel> get advisories => _advisories;
  List<AHPCropRank> get ahpRankings => _ahpRankings;
  String get activeCrop => _activeCrop;
  String get language => _language;
  bool get isLoading => _isLoading;
  bool get isBackendOnline => _isBackendOnline;
  bool get isAuthenticated => _currentUser != null;

  List<String> get selectedCrops => _currentUser?.selectedCrops ?? ["Grapes", "Onion"];

  void setLanguage(String lang) async {
    if (lang != _language) {
      _language = lang;
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(language: lang);
        await _saveUser();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("agriintel_lang", lang);
      notifyListeners();
    }
  }

  Future<void> loadFromStorage() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Load Language
      final savedLang = prefs.getString("agriintel_lang");
      if (savedLang != null && savedLang.isNotEmpty) {
        _language = savedLang;
      }

      // 2. Load User Profile from local cache
      final userStr = prefs.getString("agriintel_user");
      if (userStr != null && userStr.isNotEmpty) {
        try {
          _currentUser = UserModel.fromJson(jsonDecode(userStr));
          if (_currentUser!.language.isNotEmpty) {
            _language = _currentUser!.language;
          }
          if (_currentUser!.selectedCrops.isNotEmpty) {
            _activeCrop = _currentUser!.selectedCrops.first;
          }
        } catch (e) {
          debugPrint("Failed to parse stored user: $e");
        }
      }

      // 3. Check backend health and sync with persistent SQLite database
      _isBackendOnline = await ApiService.checkHealth();
      if (_isBackendOnline) {
        final serverUser = await ApiService.getProfile();
        if (serverUser != null) {
          _currentUser = serverUser;
          if (_currentUser!.language.isNotEmpty) {
            _language = _currentUser!.language;
          }
          if (_currentUser!.selectedCrops.isNotEmpty) {
            _activeCrop = _currentUser!.selectedCrops.first;
          }
          await _saveUser();
        }
      }

      // 4. If we have an active user, load crop & weather data
      if (_currentUser != null) {
        await refreshAllData();
      }
    } catch (e) {
      debugPrint("AppState load error: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshAllData() async {
    final district = _currentUser?.district ?? "Pune";
    _allCrops = await ApiService.getCrops();
    _weatherData = await ApiService.getWeather(district);
    _advisories = await ApiService.getAdvisories(_activeCrop);
    _ahpRankings = await ApiService.getAHPRankings(district);
    notifyListeners();
  }

  Future<void> login(String loginIdentifier, String password) async {
    _setLoading(true);
    try {
      _currentUser = await ApiService.login(loginIdentifier, password);
      if (_currentUser!.selectedCrops.isNotEmpty) {
        _activeCrop = _currentUser!.selectedCrops.first;
      }
      if (_currentUser!.language.isNotEmpty) {
        _language = _currentUser!.language;
      }
      await _saveUser();
      await refreshAllData();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      data['language'] = _language;
      _currentUser = await ApiService.register(data);
      if (_currentUser!.selectedCrops.isNotEmpty) {
        _activeCrop = _currentUser!.selectedCrops.first;
      }
      if (_currentUser!.language.isNotEmpty) {
        _language = _currentUser!.language;
      }
      await _saveUser();
      await refreshAllData();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    _setLoading(true);
    try {
      _currentUser = await ApiService.updateProfile(updatedUser);
      if (_currentUser!.language.isNotEmpty) {
        _language = _currentUser!.language;
      }
      await _saveUser();
      await refreshAllData();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateSelectedCrops(List<String> crops) async {
    const allowed = ["Onion", "Grapes", "Sugarcane", "Wheat"];
    final filtered = crops.where((c) => allowed.contains(c)).toList();
    if (filtered.isEmpty) {
      filtered.add("Onion");
    }

    _setLoading(true);
    try {
      if (_currentUser != null) {
        _currentUser = await ApiService.updateCrops(_currentUser!, filtered);
        if (!_currentUser!.selectedCrops.contains(_activeCrop)) {
          _activeCrop = _currentUser!.selectedCrops.first;
        }
        await _saveUser();
      }
      await refreshAllData();
    } finally {
      _setLoading(false);
    }
  }

  void setActiveCrop(String crop) {
    _activeCrop = crop;
    notifyListeners();
    ApiService.getAdvisories(crop).then((adv) {
      _advisories = adv;
      notifyListeners();
    });
  }

  Future<void> _saveUser() async {
    if (_currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("agriintel_user", jsonEncode(_currentUser!.toJson()));
      await prefs.setString("agriintel_lang", _language);
    }
  }

  Future<void> logout() async {
    await ApiService.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("agriintel_user");
    await prefs.remove("agriintel_token");
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
