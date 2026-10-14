class InventoryActiveIngredient {
  final String? id;
  final String name;
  final String? concentration;
  final double? concentrationValue;
  final String? concentrationUnit;
  final String? role;
  final double? confidence;

  InventoryActiveIngredient({
    this.id,
    required this.name,
    this.concentration,
    this.concentrationValue,
    this.concentrationUnit = "%",
    this.role = "fungicide",
    this.confidence = 1.0,
  });

  factory InventoryActiveIngredient.fromJson(Map<String, dynamic> json) {
    return InventoryActiveIngredient(
      id: json['id'],
      name: json['name'] ?? json['ingredient_name'] ?? '',
      concentration: json['concentration'],
      concentrationValue: (json['concentration_value'] as num?)?.toDouble(),
      concentrationUnit: json['concentration_unit'] ?? '%',
      role: json['role'] ?? 'fungicide',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (concentration != null) 'concentration': concentration,
      if (concentrationValue != null) 'concentration_value': concentrationValue,
      'concentration_unit': concentrationUnit,
      'role': role,
      'confidence': confidence,
    };
  }
}

class PesticideInventoryItem {
  final String id;
  final String farmerId;
  final String? farmId;
  final String? productName;
  final String? brandName;
  final String? manufacturer;
  final String? formulation;
  final String? productType;
  final String? registrationNumber;
  final String registrationStatus;
  final String? batchNumber;
  final String? manufacturingDate;
  final String? expiryDate;
  final double? quantityValue;
  final String? quantityUnit;
  final List<String> targetCrops;
  final List<String> targetDiseases;
  final String? recommendedDose;
  final int? phiDays;
  final String? mrlValue;
  final String? safetyInstructions;
  final String? signalWord;
  final String sourceType;
  final String verificationStatus;
  final String inventoryStatus; // AVAILABLE, EXPIRED, EXPIRING_SOON, ARCHIVED
  final double? ocrConfidence;
  final String? frontImageUrl;
  final String? backImageUrl;
  final String? compositionImageUrl;
  final String? instructionImageUrl;
  final String? blockchainRecordId;
  final List<InventoryActiveIngredient> activeIngredients;
  final String createdAt;
  final String updatedAt;

  PesticideInventoryItem({
    required this.id,
    required this.farmerId,
    this.farmId,
    this.productName,
    this.brandName,
    this.manufacturer,
    this.formulation,
    this.productType,
    this.registrationNumber,
    this.registrationStatus = "UNKNOWN",
    this.batchNumber,
    this.manufacturingDate,
    this.expiryDate,
    this.quantityValue,
    this.quantityUnit = "kg",
    this.targetCrops = const [],
    this.targetDiseases = const [],
    this.recommendedDose,
    this.phiDays,
    this.mrlValue,
    this.safetyInstructions,
    this.signalWord = "CAUTION",
    this.sourceType = "FARMER_LABEL",
    this.verificationStatus = "PENDING_VERIFICATION",
    this.inventoryStatus = "AVAILABLE",
    this.ocrConfidence,
    this.frontImageUrl,
    this.backImageUrl,
    this.compositionImageUrl,
    this.instructionImageUrl,
    this.blockchainRecordId,
    this.activeIngredients = const [],
    this.createdAt = "",
    this.updatedAt = "",
  });

  bool get isExpired => inventoryStatus == "EXPIRED";
  bool get isExpiringSoon => inventoryStatus == "EXPIRING_SOON";
  bool get isVerified => verificationStatus == "VERIFIED_BY_FARMER" || verificationStatus == "VERIFIED";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PesticideInventoryItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory PesticideInventoryItem.fromJson(Map<String, dynamic> json) {
    var rawIngs = json['active_ingredients'] as List<dynamic>? ?? [];
    return PesticideInventoryItem(
      id: json['id'] ?? '',
      farmerId: json['farmer_id'] ?? '',
      farmId: json['farm_id'],
      productName: json['product_name'],
      brandName: json['brand_name'],
      manufacturer: json['manufacturer'],
      formulation: json['formulation'],
      productType: json['product_type'],
      registrationNumber: json['registration_number'],
      registrationStatus: json['registration_status'] ?? 'UNKNOWN',
      batchNumber: json['batch_number'],
      manufacturingDate: json['manufacturing_date'],
      expiryDate: json['expiry_date'],
      quantityValue: (json['quantity_value'] as num?)?.toDouble(),
      quantityUnit: json['quantity_unit'] ?? 'kg',
      targetCrops: (json['target_crops'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      targetDiseases: (json['target_diseases'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      recommendedDose: json['recommended_dose'],
      phiDays: (json['phi_days'] as num?)?.toInt(),
      mrlValue: json['mrl_value'],
      safetyInstructions: json['safety_instructions'],
      signalWord: json['signal_word'] ?? 'CAUTION',
      sourceType: json['source_type'] ?? 'FARMER_LABEL',
      verificationStatus: json['verification_status'] ?? 'PENDING_VERIFICATION',
      inventoryStatus: json['inventory_status'] ?? 'AVAILABLE',
      ocrConfidence: (json['ocr_confidence'] as num?)?.toDouble(),
      frontImageUrl: json['front_image_url'],
      backImageUrl: json['back_image_url'],
      compositionImageUrl: json['composition_image_url'],
      instructionImageUrl: json['instruction_image_url'],
      blockchainRecordId: json['blockchain_record_id'],
      activeIngredients: rawIngs.map((e) => InventoryActiveIngredient.fromJson(e as Map<String, dynamic>)).toList(),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmer_id': farmerId,
      if (farmId != null) 'farm_id': farmId,
      'product_name': productName,
      'brand_name': brandName,
      'manufacturer': manufacturer,
      'formulation': formulation,
      'product_type': productType,
      'registration_number': registrationNumber,
      'registration_status': registrationStatus,
      'batch_number': batchNumber,
      'manufacturing_date': manufacturingDate,
      'expiry_date': expiryDate,
      'quantity_value': quantityValue,
      'quantity_unit': quantityUnit,
      'target_crops': targetCrops,
      'target_diseases': targetDiseases,
      'recommended_dose': recommendedDose,
      'phi_days': phiDays,
      'mrl_value': mrlValue,
      'safety_instructions': safetyInstructions,
      'signal_word': signalWord,
      'source_type': sourceType,
      'verification_status': verificationStatus,
      'inventory_status': inventoryStatus,
      'ocr_confidence': ocrConfidence,
      'front_image_url': frontImageUrl,
      'back_image_url': backImageUrl,
      'composition_image_url': compositionImageUrl,
      'instruction_image_url': instructionImageUrl,
      'blockchain_record_id': blockchainRecordId,
      'active_ingredients': activeIngredients.map((e) => e.toJson()).toList(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class PesticideImageUpload {
  final String imageId;
  final String imageUrl;
  final String sha256;
  final String mimeType;
  final int sizeBytes;
  final String status;

  PesticideImageUpload({
    required this.imageId,
    required this.imageUrl,
    required this.sha256,
    required this.mimeType,
    required this.sizeBytes,
    required this.status,
  });

  factory PesticideImageUpload.fromJson(Map<String, dynamic> json) {
    return PesticideImageUpload(
      imageId: json['image_id'] ?? '',
      imageUrl: json['image_url'] ?? '',
      sha256: json['sha256'] ?? '',
      mimeType: json['mime_type'] ?? '',
      sizeBytes: json['size_bytes'] ?? 0,
      status: json['status'] ?? 'UPLOADED',
    );
  }
}

class OCRFieldConfidence {
  final dynamic value;
  final double confidence;
  final String level; // HIGH, MEDIUM, LOW

  OCRFieldConfidence({
    required this.value,
    required this.confidence,
    required this.level,
  });

  factory OCRFieldConfidence.fromJson(Map<String, dynamic> json) {
    return OCRFieldConfidence(
      value: json['value'],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      level: json['level'] ?? 'LOW',
    );
  }
}

class PesticideOCRResult {
  final String ocrJobId;
  final String status;
  final String rawText;
  final Map<String, dynamic> extractedFields;
  final Map<String, OCRFieldConfidence> fieldConfidence;
  final double ocrConfidence;
  final List<String> fieldsRequiringConfirmation;
  final String verificationStatus;

  PesticideOCRResult({
    required this.ocrJobId,
    required this.status,
    required this.rawText,
    required this.extractedFields,
    required this.fieldConfidence,
    required this.ocrConfidence,
    required this.fieldsRequiringConfirmation,
    required this.verificationStatus,
  });

  factory PesticideOCRResult.fromJson(Map<String, dynamic> json) {
    var rawConf = json['field_confidence'] as Map<String, dynamic>? ?? {};
    Map<String, OCRFieldConfidence> parsedConf = {};
    rawConf.forEach((k, v) {
      if (v is Map<String, dynamic>) {
        parsedConf[k] = OCRFieldConfidence.fromJson(v);
      }
    });

    return PesticideOCRResult(
      ocrJobId: json['ocr_job_id'] ?? '',
      status: json['status'] ?? 'COMPLETED',
      rawText: json['raw_text'] ?? '',
      extractedFields: Map<String, dynamic>.from(json['extracted_fields'] ?? {}),
      fieldConfidence: parsedConf,
      ocrConfidence: (json['ocr_confidence'] as num?)?.toDouble() ?? 0.5,
      fieldsRequiringConfirmation: (json['fields_requiring_confirmation'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      verificationStatus: json['verification_status'] ?? 'PENDING_VERIFICATION',
    );
  }
}
