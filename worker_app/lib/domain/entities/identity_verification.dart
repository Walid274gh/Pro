import '../../core/constants/document_type.dart';
import '../../core/constants/verification_status.dart';

class ExtractedData {
	final String firstName;
	final String lastName;
	final String documentNumber;
	final DateTime birthDate;
	final DateTime expiryDate;
	final String nationality;

	const ExtractedData({
		required this.firstName,
		required this.lastName,
		required this.documentNumber,
		required this.birthDate,
		required this.expiryDate,
		required this.nationality,
	});

	ExtractedData copyWith({
		String? firstName,
		String? lastName,
		String? documentNumber,
		DateTime? birthDate,
		DateTime? expiryDate,
		String? nationality,
	}) {
		return ExtractedData(
			firstName: firstName ?? this.firstName,
			lastName: lastName ?? this.lastName,
			documentNumber: documentNumber ?? this.documentNumber,
			birthDate: birthDate ?? this.birthDate,
			expiryDate: expiryDate ?? this.expiryDate,
			nationality: nationality ?? this.nationality,
		);
	}
}

class FaceVerificationResult {
	final bool isMatch;
	final double confidence;
	final bool livenessPassed;

	const FaceVerificationResult({
		required this.isMatch,
		required this.confidence,
		required this.livenessPassed,
	});
}

class IdentityVerification {
	final String id;
	final String workerId;
	final DocumentType type;
	final String frontImageUrl;
	final String backImageUrl;
	final ExtractedData extractedInfo;
	final FaceVerificationResult faceMatch;
	final VerificationStatus status;
	final DateTime createdAt;
	final DateTime? reviewedAt;
	final String? reviewerComment;

	const IdentityVerification({
		required this.id,
		required this.workerId,
		required this.type,
		required this.frontImageUrl,
		required this.backImageUrl,
		required this.extractedInfo,
		required this.faceMatch,
		required this.status,
		required this.createdAt,
		this.reviewedAt,
		this.reviewerComment,
	});

	IdentityVerification copyWith({
		String? id,
		String? workerId,
		DocumentType? type,
		String? frontImageUrl,
		String? backImageUrl,
		ExtractedData? extractedInfo,
		FaceVerificationResult? faceMatch,
		VerificationStatus? status,
		DateTime? createdAt,
		DateTime? reviewedAt,
		String? reviewerComment,
	}) {
		return IdentityVerification(
			id: id ?? this.id,
			workerId: workerId ?? this.workerId,
			type: type ?? this.type,
			frontImageUrl: frontImageUrl ?? this.frontImageUrl,
			backImageUrl: backImageUrl ?? this.backImageUrl,
			extractedInfo: extractedInfo ?? this.extractedInfo,
			faceMatch: faceMatch ?? this.faceMatch,
			status: status ?? this.status,
			createdAt: createdAt ?? this.createdAt,
			reviewedAt: reviewedAt ?? this.reviewedAt,
			reviewerComment: reviewerComment ?? this.reviewerComment,
		);
	}
}