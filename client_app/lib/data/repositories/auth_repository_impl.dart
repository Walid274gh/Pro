import 'dart:async';

import '../../domain/entities/client_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
	String? _pendingPhone;
	String? _pendingUsername;

	@override
	Future<void> startPhoneSignIn({required String phoneNumber, required String username}) async {
		// TODO: FirebaseAuth: verifyPhoneNumber with SMS
		_pendingPhone = phoneNumber;
		_pendingUsername = username;
	}

	@override
	Future<ClientUser> verifyOtpCode(String otp) async {
		// TODO: FirebaseAuth: signInWithCredential using SMS code
		final String phone = _pendingPhone ?? 'unknown';
		final String username = _pendingUsername ?? 'User';
		return ClientUser(
			id: 'temp',
			phoneNumber: phone,
			username: username,
			profileImageUrl: null,
			currentLocation: null,
			isPhoneVerified: true,
			isBlocked: false,
			createdAt: DateTime.now(),
			lastActiveAt: DateTime.now(),
		);
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