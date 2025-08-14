import '../entities/worker.dart';

abstract class AuthRepository {
	Future<Worker> signInWithDocument({required String documentId});
	Future<void> signOut();
	Stream<Worker?> authStateChanges();
}