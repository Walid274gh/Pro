import 'package:flutter/foundation.dart';

import '../../domain/entities/client_user.dart';
import '../../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
	final AuthService _authService;
	ClientUser? _currentUser;
	bool _isLoading = false;
	String? _error;

	AuthProvider(this._authService) {
		_authService.authStateChanges().listen((u) {
			_currentUser = u;
			notifyListeners();
		});
	}

	ClientUser? get currentUser => _currentUser;
	bool get isLoading => _isLoading;
	String? get error => _error;

	Future<void> startPhoneSignIn(String phone, String username) async {
		_isLoading = true;
		_error = null;
		notifyListeners();
		try {
			await _authService.startPhoneSignIn(phoneNumber: phone, username: username);
		} catch (e) {
			_error = e.toString();
		} finally {
			_isLoading = false;
			notifyListeners();
		}
	}

	Future<ClientUser> verifyOtp(String otp) async {
		_isLoading = true;
		_error = null;
		notifyListeners();
		try {
			final user = await _authService.verifyOtpCode(otp);
			_currentUser = user;
			return user;
		} catch (e) {
			_error = e.toString();
			rethrow;
		} finally {
			_isLoading = false;
			notifyListeners();
		}
	}
}