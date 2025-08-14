import 'package:flutter/foundation.dart';

import '../../domain/entities/worker.dart';
import '../../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
	final AuthService _authService;
	Worker? _currentWorker;
	bool _isLoading = false;
	String? _error;

	AuthProvider(this._authService) {
		_authService.authStateChanges().listen((w) {
			_currentWorker = w;
			notifyListeners();
		});
	}

	Worker? get currentWorker => _currentWorker;
	bool get isLoading => _isLoading;
	String? get error => _error;

	Future<void> signInWithDocument(String documentId) async {
		_isLoading = true;
		_error = null;
		notifyListeners();
		try {
			final w = await _authService.signInWithDocument(documentId: documentId);
			_currentWorker = w;
		} catch (e) {
			_error = e.toString();
			rethrow;
		} finally {
			_isLoading = false;
			notifyListeners();
		}
	}
}