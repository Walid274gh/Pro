import '../entities/identity_verification.dart';

abstract class VerificationRepository {
	Future<IdentityVerification> submitVerification(IdentityVerification verification);
	Stream<IdentityVerification?> watchLatestVerification(String workerId);
}