import '../domain/entities/worker.dart';
import '../domain/repositories/auth_repository.dart';

abstract class AuthService {
	Future<Worker> signInWithDocument({required String documentId});
	Future<void> signOut();
	Stream<Worker?> authStateChanges();
}

class AuthServiceImpl implements AuthService {
	final AuthRepository _repository;
	AuthServiceImpl(this._repository);

	@override
	Future<Worker> signInWithDocument({required String documentId}) {
		return _repository.signInWithDocument(documentId: documentId);
	}

	@override
	Future<void> signOut() => _repository.signOut();

	@override
	Stream<Worker?> authStateChanges() => _repository.authStateChanges();
}