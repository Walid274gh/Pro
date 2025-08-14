import 'dart:async';

import '../../domain/entities/worker.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
	@override
	Future<Worker> signInWithDocument({required String documentId}) async {
		// TODO: integrate with Firebase Auth custom token or phone and fetch worker profile
		return Worker(
			id: 'temp',
			phoneNumber: 'n/a',
			fullName: 'Artisan Temp',
			avatarUrl: null,
			isVerified: false,
			isOnline: false,
			currentLocation: null,
			serviceCategories: const <String>[],
			averageRating: 0.0,
			completedJobs: 0,
			createdAt: DateTime.now(),
			lastActiveAt: DateTime.now(),
			nextAvailable: null,
		);
	}

	@override
	Future<void> signOut() async {
		// TODO
		return;
	}

	@override
	Stream<Worker?> authStateChanges() {
		// TODO
		return const Stream.empty();
	}
}