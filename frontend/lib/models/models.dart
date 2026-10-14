export 'pesticide_inventory.dart';
export 'pesticide_comparison.dart';

class FarmModel {
  final String farmId;
  final String userId;
  final String farmName;
  final String village;
  final String district;
  final String state;
  final double latitude;
  final double longitude;
  final double area;
  final String areaUnit;
  final String soilType;
  final String irrigationType;

  FarmModel({
    required this.farmId,
    required this.userId,
    required this.farmName,
    required this.village,
    required this.district,
    this.state = "Maharashtra",
    this.latitude = 18.5204,
    this.longitude = 73.8567,
    required this.area,
    this.areaUnit = "Acres",
    this.soilType = "Clay loam",
    this.irrigationType = "Drip Irrigation",
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      farmId: json['farm_id'] ?? 'farm_001',
      userId: json['user_id'] ?? 'usr_demo',
      farmName: json['farm_name'] ?? 'Primary Family Plot',
      village: json['village'] ?? 'Nashik',
      district: json['district'] ?? 'Nashik',
      state: json['state'] ?? 'Maharashtra',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 18.5204,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 73.8567,
      area: (json['area'] as num?)?.toDouble() ?? 3.0,
      areaUnit: json['area_unit'] ?? 'Acres',
      soilType: json['soil_type'] ?? 'Medium Black Clay Loam',
      irrigationType: json['irrigation_type'] ?? 'Drip Irrigation',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'farm_id': farmId,
      'user_id': userId,
      'farm_name': farmName,
      'village': village,
      'district': district,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'area': area,
      'area_unit': areaUnit,
      'soil_type': soilType,
      'irrigation_type': irrigationType,
    };
  }
}

class UserModel {
  final String id;
  final String name;
  final String? email;
  final String mobile;
  final String village;
  final String district;
  final String state;
  final double farmSizeAcres;
  final List<String> selectedCrops;
  final String language;
  final int farmingExperienceYears;
  final List<FarmModel> farms;
  final String verificationStatus;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    required this.mobile,
    required this.village,
    required this.district,
    this.state = "Maharashtra",
    required this.farmSizeAcres,
    required this.selectedCrops,
    required this.language,
    this.farmingExperienceYears = 5,
    this.farms = const [],
    this.verificationStatus = "DEMO",
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    var rawFarms = json['farms'] as List<dynamic>?;
    List<FarmModel> parsedFarms = rawFarms != null
        ? rawFarms.map((f) => FarmModel.fromJson(f as Map<String, dynamic>)).toList()
        : [];

    return UserModel(
      id: json['id'] ?? 'usr_demo',
      name: json['name'] ?? 'Farmer Demo',
      email: json['email'],
      mobile: json['mobile'] ?? '9876543210',
      village: json['village'] ?? 'Nashik',
      district: json['district'] ?? 'Nashik',
      state: json['state'] ?? 'Maharashtra',
      farmSizeAcres: (json['farm_size_acres'] as num?)?.toDouble() ?? 3.0,
      selectedCrops: (json['selected_crops'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['Grapes', 'Onion'],
      language: json['language'] ?? 'en',
      farmingExperienceYears: json['farming_experience_years'] ?? 5,
      farms: parsedFarms,
      verificationStatus: json['verification_status'] ?? 'DEMO',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'village': village,
      'district': district,
      'state': state,
      'farm_size_acres': farmSizeAcres,
      'selected_crops': selectedCrops,
      'language': language,
      'farming_experience_years': farmingExperienceYears,
      'farms': farms.map((f) => f.toJson()).toList(),
      'verification_status': verificationStatus,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? mobile,
    String? village,
    String? district,
    String? state,
    double? farmSizeAcres,
    List<String>? selectedCrops,
    String? language,
    int? farmingExperienceYears,
    List<FarmModel>? farms,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      village: village ?? this.village,
      district: district ?? this.district,
      state: state ?? this.state,
      farmSizeAcres: farmSizeAcres ?? this.farmSizeAcres,
      selectedCrops: selectedCrops ?? this.selectedCrops,
      language: language ?? this.language,
      farmingExperienceYears: farmingExperienceYears ?? this.farmingExperienceYears,
      farms: farms ?? this.farms,
      verificationStatus: verificationStatus,
    );
  }
}

class CropItem {
  final String id;
  final String name;
  final String scientificName;
  final String marathiName;
  final List<String> season;
  final int durationDays;
  final List<String> majorDistricts;
  final String source;
  final String verificationStatus;

  CropItem({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.marathiName,
    required this.season,
    required this.durationDays,
    required this.majorDistricts,
    this.source = "ICAR",
    this.verificationStatus = "VERIFIED",
  });

  factory CropItem.fromJson(Map<String, dynamic> json) {
    return CropItem(
      id: json['crop_id'] ?? json['id'] ?? '',
      name: json['crop_name'] ?? json['name'] ?? '',
      scientificName: json['scientific_name'] ?? '',
      marathiName: json['marathi_name'] ?? '',
      season: (json['season'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      durationDays: json['duration_days'] ?? 120,
      majorDistricts: (json['major_districts'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      source: json['source'] ?? 'ICAR',
      verificationStatus: json['verification_status'] ?? 'VERIFIED',
    );
  }
}

class WeatherData {
  final String district;
  final String state;
  final double tempC;
  final double feelsLikeC;
  final int humidity;
  final double windKmh;
  final String windDirection;
  final int rainProbability;
  final String condition;
  final String sprayCondition; // GOOD_TO_SPRAY | CAUTION | DO_NOT_SPRAY
  final String sprayReason;
  final List<Map<String, dynamic>> hourly;
  final List<Map<String, dynamic>> daily;
  final String verificationStatus;

  WeatherData({
    required this.district,
    required this.state,
    required this.tempC,
    required this.feelsLikeC,
    required this.humidity,
    required this.windKmh,
    required this.windDirection,
    required this.rainProbability,
    required this.condition,
    required this.sprayCondition,
    required this.sprayReason,
    required this.hourly,
    required this.daily,
    this.verificationStatus = "DEMO",
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final cur = json['current'] ?? {};
    return WeatherData(
      district: json['district'] ?? 'Pune',
      state: json['state'] ?? 'Maharashtra',
      tempC: (cur['temperature_c'] as num?)?.toDouble() ?? 28.5,
      feelsLikeC: (cur['feels_like_c'] as num?)?.toDouble() ?? 30.1,
      humidity: (cur['humidity_pct'] as num?)?.toInt() ?? 62,
      windKmh: (cur['wind_speed_kmh'] as num?)?.toDouble() ?? 8.4,
      windDirection: cur['wind_direction'] ?? 'WSW',
      rainProbability: (cur['rain_probability_pct'] as num?)?.toInt() ?? 10,
      condition: cur['weather_condition'] ?? cur['condition'] ?? 'Partly Cloudy',
      sprayCondition: cur['spray_condition'] ?? 'GOOD_TO_SPRAY',
      sprayReason: cur['spray_reason'] ?? 'Optimal spraying conditions.',
      hourly: List<Map<String, dynamic>>.from(json['hourly_forecast'] ?? []),
      daily: List<Map<String, dynamic>>.from(json['daily_forecast'] ?? []),
      verificationStatus: json['verification_status'] ?? 'DEMO',
    );
  }
}

class DiagnosisResult {
  final String diagnosisId;
  final String crop;
  final String diseaseName;
  final String pathogen;
  final String marathiName;
  final double confidence;
  final String severity;
  final String diseaseRisk;
  final String symptoms;
  final String weatherRisk;
  final String organicTreatment;
  final String chemicalTreatment;
  final String source;
  final String verificationStatus;
  final String blockchainHash;

  DiagnosisResult({
    this.diagnosisId = "diag_001",
    required this.crop,
    required this.diseaseName,
    required this.pathogen,
    required this.marathiName,
    required this.confidence,
    required this.severity,
    this.diseaseRisk = "Medium",
    required this.symptoms,
    this.weatherRisk = "Normal",
    required this.organicTreatment,
    required this.chemicalTreatment,
    this.source = "ICAR-NRC Grapes / DOGR",
    this.verificationStatus = "DEMO",
    this.blockchainHash = "7c992d551bfa3ca3ee45812d6fee2ca014856f690226346addd1c60144c10f5f",
  });

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) {
    return DiagnosisResult(
      diagnosisId: json['diagnosis_id'] ?? 'diag_001',
      crop: json['crop'] ?? 'Grapes',
      diseaseName: json['disease_name'] ?? 'Downy Mildew',
      pathogen: json['pathogen'] ?? 'Plasmopara viticola',
      marathiName: json['marathi_name'] ?? 'केवडा',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.95,
      severity: json['severity'] ?? 'Medium',
      diseaseRisk: json['disease_risk'] ?? 'High',
      symptoms: json['symptoms'] ?? 'Yellow translucent oily spots.',
      weatherRisk: json['weather_risk'] ?? 'High humidity encourages spore release.',
      organicTreatment: json['organic_treatment'] ?? 'Potassium Phosphonate @ 3g/L',
      chemicalTreatment: json['chemical_treatment'] ?? 'Dimethomorph 50% WP @ 1g/L',
      source: json['source'] ?? 'ICAR',
      verificationStatus: json['verification_status'] ?? 'DEMO',
      blockchainHash: json['blockchain_hash'] ?? '',
    );
  }
}

class CandidateRecommendationModel {
  final String pesticideId;
  final String productName;
  final String activeIngredient;
  final String targetProblem;
  final double ahpScore;
  final int rank;
  final String problemRelevance;
  final String weatherSuitability;
  final String phiCompliance;
  final String sourceStatus;
  final String source;
  final String reasons;
  final String verificationStatus;

  CandidateRecommendationModel({
    required this.pesticideId,
    required this.productName,
    required this.activeIngredient,
    required this.targetProblem,
    required this.ahpScore,
    required this.rank,
    required this.problemRelevance,
    required this.weatherSuitability,
    required this.phiCompliance,
    required this.sourceStatus,
    required this.source,
    required this.reasons,
    this.verificationStatus = "VERIFIED",
  });

  factory CandidateRecommendationModel.fromJson(Map<String, dynamic> json) {
    return CandidateRecommendationModel(
      pesticideId: json['pesticide_id'] ?? '',
      productName: json['product_name'] ?? '',
      activeIngredient: json['active_ingredient'] ?? '',
      targetProblem: json['target_problem'] ?? '',
      ahpScore: (json['ahp_score'] as num?)?.toDouble() ?? 0.0,
      rank: json['rank'] ?? 1,
      problemRelevance: json['problem_relevance'] ?? 'High',
      weatherSuitability: json['weather_suitability'] ?? 'Medium',
      phiCompliance: json['phi_compliance'] ?? 'Compliant',
      sourceStatus: json['source_status'] ?? 'VERIFIED',
      source: json['source'] ?? 'CIB&RC',
      reasons: json['reasons'] ?? '',
      verificationStatus: json['verification_status'] ?? 'VERIFIED',
    );
  }
}

class RecommendationResponseModel {
  final String crop;
  final String disease;
  final String weatherGatekeeperStatus;
  final String weatherGatekeeperReason;
  final bool isSprayAllowed;
  final String? sprayOverrideWarning;
  final List<CandidateRecommendationModel> ranking;
  final String verificationStatus;
  final String blockchainHash;

  RecommendationResponseModel({
    required this.crop,
    required this.disease,
    required this.weatherGatekeeperStatus,
    required this.weatherGatekeeperReason,
    required this.isSprayAllowed,
    this.sprayOverrideWarning,
    required this.ranking,
    required this.verificationStatus,
    required this.blockchainHash,
  });

  factory RecommendationResponseModel.fromJson(Map<String, dynamic> json) {
    var rawList = json['ranking'] as List<dynamic>? ?? [];
    return RecommendationResponseModel(
      crop: json['crop'] ?? 'Grapes',
      disease: json['disease'] ?? 'Downy Mildew',
      weatherGatekeeperStatus: json['weather_gatekeeper_status'] ?? 'GOOD_TO_SPRAY',
      weatherGatekeeperReason: json['weather_gatekeeper_reason'] ?? '',
      isSprayAllowed: json['is_spray_allowed'] ?? true,
      sprayOverrideWarning: json['spray_override_warning'],
      ranking: rawList.map((e) => CandidateRecommendationModel.fromJson(e as Map<String, dynamic>)).toList(),
      verificationStatus: json['verification_status'] ?? 'VERIFIED',
      blockchainHash: json['blockchain_hash'] ?? '',
    );
  }
}

class AdvisoryItemModel {
  final String id;
  final String cropName;
  final String stage;
  final String alertType;
  final String title;
  final String summary;
  final List<String> actionPoints;
  final String weatherGatekeeperStatus;
  final double ahpScore;
  final String blockchainProof;
  final String source;
  final String verificationStatus;

  AdvisoryItemModel({
    required this.id,
    required this.cropName,
    required this.stage,
    required this.alertType,
    required this.title,
    required this.summary,
    required this.actionPoints,
    required this.weatherGatekeeperStatus,
    required this.ahpScore,
    required this.blockchainProof,
    this.source = "ICAR-NRC Grapes / DOGR",
    this.verificationStatus = "DEMO",
  });

  factory AdvisoryItemModel.fromJson(Map<String, dynamic> json) {
    return AdvisoryItemModel(
      id: json['id'] ?? '',
      cropName: json['crop_name'] ?? '',
      stage: json['stage'] ?? '',
      alertType: json['alert_type'] ?? 'INFO',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      actionPoints: (json['action_points'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      weatherGatekeeperStatus: json['weather_gatekeeper_status'] ?? 'GOOD TO SPRAY',
      ahpScore: (json['ahp_score'] as num?)?.toDouble() ?? 0.85,
      blockchainProof: json['blockchain_proof'] ?? '',
      source: json['source'] ?? 'ICAR',
      verificationStatus: json['verification_status'] ?? 'DEMO',
    );
  }
}

class AHPCropRank {
  final String cropName;
  final double compositeScore;
  final int rank;
  final double expectedYield;
  final double projectedProfit;
  final String justification;
  final String verificationStatus;

  AHPCropRank({
    required this.cropName,
    required this.compositeScore,
    required this.rank,
    required this.expectedYield,
    required this.projectedProfit,
    required this.justification,
    this.verificationStatus = "DEMO",
  });

  factory AHPCropRank.fromJson(Map<String, dynamic> json) {
    return AHPCropRank(
      cropName: json['crop_name'] ?? '',
      compositeScore: (json['composite_score'] as num?)?.toDouble() ?? 0.0,
      rank: json['rank'] ?? 1,
      expectedYield: (json['expected_yield'] as num?)?.toDouble() ?? 0.0,
      projectedProfit: (json['projected_profit'] as num?)?.toDouble() ?? 0.0,
      justification: json['justification'] ?? '',
      verificationStatus: json['verification_status'] ?? 'DEMO',
    );
  }
}

class BlockchainVerifyResult {
  final String recordId;
  final String currentHash;
  final String storedHash;
  final String integrityStatus;
  final String timestamp;
  final String source;
  final String verificationStatus;

  BlockchainVerifyResult({
    required this.recordId,
    required this.currentHash,
    required this.storedHash,
    required this.integrityStatus,
    required this.timestamp,
    required this.source,
    required this.verificationStatus,
  });

  factory BlockchainVerifyResult.fromJson(Map<String, dynamic> json) {
    return BlockchainVerifyResult(
      recordId: json['record_id'] ?? '',
      currentHash: json['current_hash'] ?? '',
      storedHash: json['stored_hash'] ?? '',
      integrityStatus: json['integrity_status'] ?? 'INTEGRITY VERIFIED',
      timestamp: json['timestamp'] ?? '',
      source: json['source'] ?? 'AgriIntel Cryptographic Ledger',
      verificationStatus: json['verification_status'] ?? 'VERIFIED',
    );
  }
}

