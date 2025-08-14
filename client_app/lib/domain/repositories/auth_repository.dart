import '../entities/client_user.dart';

abstract class AuthRepository {
	Future<ClientUser> signInWithPhone({required String phoneNumber, required String username});
	Future<void> verifyOtpCode(String otp);
	Future<void> signOut();
	Stream<ClientUser?> authStateChanges();
}