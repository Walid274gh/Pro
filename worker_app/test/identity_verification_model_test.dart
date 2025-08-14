import 'package:flutter_test/flutter_test.dart';
import 'package:worker_app/data/models/identity_verification_model.dart';
import 'package:worker_app/core/constants/document_type.dart';
import 'package:worker_app/domain/entities/identity_verification.dart';
import 'package:worker_app/core/constants/verification_status.dart';

void main() {
	test('IdentityVerificationModel toMap/fromMap round trip', () {
		final model = IdentityVerificationModel(
			id: 'vid',
			workerId: 'wid',
			type: DocumentType.idCard,
			frontImageUrl: 'front',
			backImageUrl: 'selfie',
			extractedInfo: const ExtractedData(
				firstName: 'Ali', lastName: 'Ben', documentNumber: 'ABC123', birthDate: DateTime(1990,1,1), expiryDate: DateTime(2030,1,1), nationality: 'DZ'),
			faceMatch: const FaceVerificationResult(isMatch: true, confidence: 0.9, livenessPassed: true),
			status: VerificationStatus.pending,
			createdAt: DateTime(2025,1,1),
		);
		final map = model.toMap();
		final parsed = IdentityVerificationModel.fromMap(map);
		expect(parsed.workerId, 'wid');
		expect(parsed.type, DocumentType.idCard);
		expect(parsed.extractedInfo.firstName, 'Ali');
		expect(parsed.faceMatch.isMatch, true);
	});
}