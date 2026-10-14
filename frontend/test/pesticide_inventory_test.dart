import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agriintel_app/models/models.dart';
import 'package:agriintel_app/widgets/pesticide_inventory_card.dart';
import 'package:agriintel_app/widgets/comparison_criteria_table.dart';
import 'package:agriintel_app/widgets/safety_warning_card.dart';
import 'package:agriintel_app/screens/pesticide_review_screen.dart';

void main() {
  group('Pesticide Inventory & Comparison UI Tests', () {
    // 1. Inventory list rendering
    testWidgets('1. Inventory card renders title, active ingredients, and formulation', (tester) async {
      final item = PesticideInventoryItem(
        id: 'inv_001',
        farmerId: 'usr_001',
        brandName: 'Ridomil Gold',
        productName: 'Ridomil Gold 68 WG',
        formulation: 'WP',
        recommendedDose: '2.5 g/L',
        phiDays: 60,
        activeIngredients: [
          InventoryActiveIngredient(name: 'Metalaxyl-M', concentration: '4%'),
          InventoryActiveIngredient(name: 'Mancozeb', concentration: '64%'),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PesticideInventoryCard(item: item),
          ),
        ),
      );

      expect(find.text('Ridomil Gold'), findsOneWidget);
      expect(find.text('WP'), findsOneWidget);
      expect(find.text('Metalaxyl-M 4%'), findsOneWidget);
      expect(find.text('Mancozeb 64%'), findsOneWidget);
      expect(find.text('PHI: 60d'), findsOneWidget);
    });

    // 2. Image upload state & preview rendering
    testWidgets('2. Inventory card shows thumbnail placeholder when no image URL', (tester) async {
      final item = PesticideInventoryItem(
        id: 'inv_002',
        farmerId: 'usr_001',
        brandName: 'Generic Chemical',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PesticideInventoryCard(item: item),
          ),
        ),
      );

      expect(find.byIcon(Icons.science_outlined), findsOneWidget);
    });

    // 3. OCR review form rendering
    testWidgets('3. OCR review form displays extracted fields and confidence indicators', (tester) async {
      final ocrResult = PesticideOCRResult(
        ocrJobId: 'ocr_001',
        status: 'COMPLETED',
        rawText: 'PRODUCT: Acrobat 50 WP\nACTIVE: Dimethomorph 50%',
        extractedFields: {
          'brand_name': 'Acrobat',
          'product_name': 'Acrobat 50 WP',
          'formulation': 'WP',
          'active_ingredients': [
            {'name': 'Dimethomorph', 'concentration': '50%'}
          ],
        },
        fieldConfidence: {
          'brand_name': OCRFieldConfidence(value: 'Acrobat', confidence: 0.92, level: 'HIGH'),
        },
        ocrConfidence: 0.90,
        fieldsRequiringConfirmation: [],
        verificationStatus: 'PENDING_VERIFICATION',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: PesticideReviewScreen(
            ocrResult: ocrResult,
            imageIds: const ['img_001'],
          ),
        ),
      );

      expect(find.text('OCR Review & Confirm'), findsOneWidget);
      expect(find.text('Acrobat'), findsWidgets);
      expect(find.text('Confirm & Add to Inventory'), findsOneWidget);
    });

    // 4. Manual field correction
    testWidgets('4. OCR review form allows field editing', (tester) async {
      final ocrResult = PesticideOCRResult(
        ocrJobId: 'ocr_002',
        status: 'COMPLETED',
        rawText: 'Label text',
        extractedFields: {
          'brand_name': 'Initial Brand',
          'active_ingredients': [
            {'name': 'Mancozeb', 'concentration': '75%'}
          ],
        },
        fieldConfidence: {},
        ocrConfidence: 0.85,
        fieldsRequiringConfirmation: [],
        verificationStatus: 'PENDING_VERIFICATION',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: PesticideReviewScreen(
            ocrResult: ocrResult,
            imageIds: const ['img_002'],
          ),
        ),
      );

      // Find the text field containing 'Initial Brand' and enter new text
      final brandFinder = find.widgetWithText(TextFormField, 'Initial Brand');
      expect(brandFinder, findsOneWidget);
      await tester.enterText(brandFinder, 'Corrected Dithane M-45');
      await tester.pump();

      expect(find.text('Corrected Dithane M-45'), findsOneWidget);
    });

    // 5. Comparison table rendering
    testWidgets('5. ComparisonCriteriaTable renders all criteria and scores', (tester) async {
      final criteria = [
        ComparisonCriterion(
          criterion: 'Target disease or pest match',
          weight: 0.30,
          inventoryScore: 80.0,
          recommendedScore: 95.0,
          inventoryReason: 'Broad spectrum foliar activity.',
          recommendedReason: 'Registered specifically for downy mildew.',
          source: 'CIB&RC Registry',
        ),
        ComparisonCriterion(
          criterion: 'Crop registration and compatibility',
          weight: 0.25,
          inventoryScore: 100.0,
          recommendedScore: 100.0,
          inventoryReason: 'Registered on Grapes.',
          recommendedReason: 'Registered on Grapes.',
          source: 'CIB&RC',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComparisonCriteriaTable(criteria: criteria),
          ),
        ),
      );

      expect(find.text('Multi-Criteria Suitability Breakdown'), findsOneWidget);
      expect(find.text('80/100'), findsOneWidget);
      expect(find.text('95/100'), findsOneWidget);
      expect(find.text('100/100'), findsNWidgets(2));
    });

    // 6. Weather warning banner
    testWidgets('6. SafetyWarningCard renders DO NOT SPRAY override when unsafe', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SafetyWarningCard(
              warnings: ['High wind drift hazard (22.5 km/h)'],
              weatherGatekeeperStatus: 'DO_NOT_SPRAY',
              windSpeed: 22.5,
              rainProb: 60.0,
            ),
          ),
        ),
      );

      expect(find.text('SPRAY GATEKEEPER: DO NOT SPRAY'), findsOneWidget);
      expect(find.text('High wind drift hazard (22.5 km/h)'), findsOneWidget);
      expect(find.byIcon(Icons.gpp_bad_outlined), findsOneWidget);
    });

    // 7. Expired product badge
    testWidgets('7. PesticideInventoryCard shows EXPIRED badge for expired product', (tester) async {
      final expiredItem = PesticideInventoryItem(
        id: 'inv_003',
        farmerId: 'usr_001',
        brandName: 'Old Chemical Bottle',
        inventoryStatus: 'EXPIRED',
        expiryDate: '2020-01-01',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PesticideInventoryCard(item: expiredItem),
          ),
        ),
      );

      expect(find.text('EXPIRED'), findsOneWidget);
    });

    // 8. Missing composition warning
    testWidgets('8. SafetyWarningCard shows active ingredient warning', (tester) async {
      const warn = 'The active ingredient could not be verified from the product label.';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SafetyWarningCard(
              warnings: [warn],
              weatherGatekeeperStatus: 'GOOD_TO_SPRAY',
            ),
          ),
        ),
      );

      expect(find.text(warn), findsOneWidget);
    });

    // 9. Navigation / Action triggers
    testWidgets('9. PesticideInventoryCard invokes onCompare callback', (tester) async {
      bool compared = false;
      final item = PesticideInventoryItem(
        id: 'inv_004',
        farmerId: 'usr_001',
        brandName: 'Compare Me',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PesticideInventoryCard(
              item: item,
              onCompare: () => compared = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Compare'));
      expect(compared, isTrue);
    });

    // 10. Empty inventory state
    testWidgets('10. Renders PPE Reminder in safety warning card', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SafetyWarningCard(
              warnings: [],
              weatherGatekeeperStatus: 'GOOD_TO_SPRAY',
            ),
          ),
        ),
      );

      expect(find.textContaining('Mandatory PPE'), findsOneWidget);
    });
  });
}
