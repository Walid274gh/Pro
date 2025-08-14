import '../domain/entities/client_user.dart';
import '../domain/repositories/auth_repository.dart';

abstract class AuthService {
	Future<void> startPhoneSignIn({required String phoneNumber, required String username});
	Future<ClientUser> verifyOtpCode(String otp);
	Future<void> signOut();
	Stream<ClientUser?> authStateChanges();
}

class AuthServiceImpl implements AuthService {
	final AuthRepository _repository;
	AuthServiceImpl(this._repository);

	@override
	Future<void> startPhoneSignIn({required String phoneNumber, required String username}) {
		return _repository.startPhoneSignIn(phoneNumber: phoneNumber, username: username);
	}

	@override
	Future<ClientUser> verifyOtpCode(String otp) {
		return _repository.verifyOtpCode(otp);
	}

	@override
	Future<void> signOut() => _repository.signOut();

	@override
	Stream<ClientUser?> authStateChanges() => _repository.authStateChanges();
}