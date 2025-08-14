import '../entities/client_user.dart';

abstract class AuthRepository {
	Future<void> startPhoneSignIn({required String phoneNumber, required String username});
	Future<ClientUser> verifyOtpCode(String otp);
	Future<void> signOut();
	Stream<ClientUser?> authStateChanges();
}