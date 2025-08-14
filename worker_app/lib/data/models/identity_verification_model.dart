import '../../core/constants/document_type.dart';
import '../../core/constants/verification_status.dart';
import '../../domain/entities/identity_verification.dart';

class IdentityVerificationModel extends IdentityVerification {
	const IdentityVerificationModel({
		required super.id,
		required super.workerId,
		required super.type,
		required super.frontImageUrl,
		required super.backImageUrl,
		required super.extractedInfo,
		required super.faceMatch,
		required super.status,
		required super.createdAt,
		super.reviewedAt,
		super.reviewerComment,
	});

	Map<String, dynamic> toMap() {
		return {
			'id': id,
			'workerId': workerId,
			'type': type.key,
			'frontImageUrl': frontImageUrl,
			'backImageUrl': backImageUrl,
			'extractedInfo': {
				'firstName': extractedInfo.firstName,
				'lastName': extractedInfo.lastName,
				'documentNumber': extractedInfo.documentNumber,
				'birthDate': extractedInfo.birthDate.millisecondsSinceEpoch,
				'expiryDate': extractedInfo.expiryDate.millisecondsSinceEpoch,
				'nationality': extractedInfo.nationality,
			},
			'faceMatch': {
				'isMatch': faceMatch.isMatch,
				'confidence': faceMatch.confidence,
				'livenessPassed': faceMatch.livenessPassed,
			},
			'status': status.name,
			'createdAt': createdAt.millisecondsSinceEpoch,
			'reviewedAt': reviewedAt?.millisecondsSinceEpoch,
			'reviewerComment': reviewerComment,
		};
	}

	factory IdentityVerificationModel.fromMap(Map<String, dynamic> map) {
		return IdentityVerificationModel(
			id: map['id'] as String,
			workerId: map['workerId'] as String,
			type: DocumentType.fromKey(map['type'] as String),
			frontImageUrl: map['frontImageUrl'] as String,
			backImageUrl: map['backImageUrl'] as String,
			extractedInfo: ExtractedData(
				firstName: map['extractedInfo']['firstName'] as String,
				lastName: map['extractedInfo']['lastName'] as String,
				documentNumber: map['extractedInfo']['documentNumber'] as String,
				birthDate: _parseDate(map['extractedInfo']['birthDate']),
				expiryDate: _parseDate(map['extractedInfo']['expiryDate']),
				nationality: map['extractedInfo']['nationality'] as String,
			),
			faceMatch: FaceVerificationResult(
				isMatch: (map['faceMatch']['isMatch'] as bool?) ?? false,
				confidence: (map['faceMatch']['confidence'] as num).toDouble(),
				livenessPassed: (map['faceMatch']['livenessPassed'] as bool?) ?? false,
			),
			status: VerificationStatus.values.firstWhere(
				(e) => e.name == (map['status'] as String? ?? 'pending'),
				orElse: () => VerificationStatus.pending,
			),
			createdAt: _parseDate(map['createdAt']),
			reviewedAt: _parseNullableDate(map['reviewedAt']),
			reviewerComment: map['reviewerComment'] as String?,
		);
	}

	static DateTime _parseDate(dynamic v) {
		if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
		if (v is String) {
			final d = DateTime.tryParse(v);
			if (d != null) return d;
		}
		return DateTime.fromMillisecondsSinceEpoch(0);
	}

	static DateTime? _parseNullableDate(dynamic v) {
		if (v == null) return null;
		return _parseDate(v);
	}
}