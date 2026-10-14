class ComparisonCriterion {
  final String criterion;
  final double weight;
  final double? inventoryScore;
  final double? recommendedScore;
  final String inventoryReason;
  final String recommendedReason;
  final String source;
  final double confidence;

  ComparisonCriterion({
    required this.criterion,
    required this.weight,
    this.inventoryScore,
    this.recommendedScore,
    required this.inventoryReason,
    required this.recommendedReason,
    required this.source,
    this.confidence = 0.9,
  });

  factory ComparisonCriterion.fromJson(Map<String, dynamic> json) {
    return ComparisonCriterion(
      criterion: json['criterion'] ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.1,
      inventoryScore: (json['inventory_score'] as num?)?.toDouble(),
      recommendedScore: (json['recommended_score'] as num?)?.toDouble(),
      inventoryReason: json['inventory_reason'] ?? '',
      recommendedReason: json['recommended_reason'] ?? '',
      source: json['source'] ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.9,
    );
  }
}

class PesticideComparisonResponse {
  final String comparisonId;
  final String crop;
  final String problem;
  final String overallResult;
  final double confidence;
  final double? inventoryScore;
  final double? recommendedScore;
  final Map<String, dynamic> inventoryProduct;
  final Map<String, dynamic> recommendedProduct;
  final List<ComparisonCriterion> criteria;
  final List<String> safetyWarnings;
  final String weatherGatekeeperStatus;
  final String finalAdvisory;
  final String disclaimer;
  final String? blockchainRecordId;
  final String createdAt;

  PesticideComparisonResponse({
    required this.comparisonId,
    required this.crop,
    required this.problem,
    required this.overallResult,
    required this.confidence,
    this.inventoryScore,
    this.recommendedScore,
    required this.inventoryProduct,
    required this.recommendedProduct,
    required this.criteria,
    required this.safetyWarnings,
    required this.weatherGatekeeperStatus,
    required this.finalAdvisory,
    required this.disclaimer,
    this.blockchainRecordId,
    required this.createdAt,
  });

  bool get isDoNotSpray => overallResult == "DO_NOT_SPRAY_WEATHER_OVERRIDE" || weatherGatekeeperStatus == "DO_NOT_SPRAY";
  bool get isBothSimilar => overallResult == "BOTH_SIMILAR";
  bool get isInventoryWinner => overallResult == "INVENTORY_PRODUCT_MORE_SUITABLE";
  bool get isRecommendedWinner => overallResult == "RECOMMENDED_PRODUCT_MORE_SUITABLE";
  bool get isInsufficientData => overallResult == "INSUFFICIENT_VERIFIED_DATA";

  factory PesticideComparisonResponse.fromJson(Map<String, dynamic> json) {
    var rawCrits = json['criteria'] as List<dynamic>? ?? [];
    return PesticideComparisonResponse(
      comparisonId: json['comparison_id'] ?? '',
      crop: json['crop'] ?? '',
      problem: json['problem'] ?? '',
      overallResult: json['overall_result'] ?? 'INSUFFICIENT_VERIFIED_DATA',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.85,
      inventoryScore: (json['inventory_score'] as num?)?.toDouble(),
      recommendedScore: (json['recommended_score'] as num?)?.toDouble(),
      inventoryProduct: Map<String, dynamic>.from(json['inventory_product'] ?? {}),
      recommendedProduct: Map<String, dynamic>.from(json['recommended_product'] ?? {}),
      criteria: rawCrits.map((e) => ComparisonCriterion.fromJson(e as Map<String, dynamic>)).toList(),
      safetyWarnings: (json['safety_warnings'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      weatherGatekeeperStatus: json['weather_gatekeeper_status'] ?? 'GOOD_TO_SPRAY',
      finalAdvisory: json['final_advisory'] ?? '',
      disclaimer: json['disclaimer'] ?? '',
      blockchainRecordId: json['blockchain_record_id'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
