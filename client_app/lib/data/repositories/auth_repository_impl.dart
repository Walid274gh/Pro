import 'dart:async';

import '../../domain/entities/client_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
	@override
	Future<ClientUser> signInWithPhone({required String phoneNumber, required String username}) async {
		// TODO: integrate with FirebaseAuth + Firestore profile
		return ClientUser(
			id: 'temp',
			phoneNumber: phoneNumber,
			username: username,
			profileImageUrl: null,
			currentLocation: null,
			isPhoneVerified: false,
			isBlocked: false,
			createdAt: DateTime.now(),
			lastActiveAt: DateTime.now(),
		);
	}

	@override
	Future<void> verifyOtpCode(String otp) async {
		// TODO: verify via FirebaseAuth
		return;
	}

	@override
	Future<void> signOut() async {
		// TODO: FirebaseAuth signOut
		return;
	}

	@override
	Stream<ClientUser?> authStateChanges() {
		// TODO: stream FirebaseAuth + user profile
		return const Stream.empty();
	}
}