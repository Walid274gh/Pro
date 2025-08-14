import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../domain/entities/worker.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/worker_model.dart';
import '../../services/firebase_service.dart';

class AuthRepositoryImpl implements AuthRepository {
	FirebaseAuth get _auth => FirebaseService.auth;
	FirebaseFirestore get _db => FirebaseService.db;

	@override
	Future<Worker> signInWithDocument({required String documentId}) async {
		if (_auth.currentUser == null) {
			await _auth.signInAnonymously();
		}
		final uid = _auth.currentUser!.uid;
		final ref = _db.collection(FirestorePaths.workers).doc(uid);
		final snap = await ref.get();
		if (!snap.exists) {
			final model = WorkerModel(
				id: uid,
				phoneNumber: _auth.currentUser!.phoneNumber ?? 'n/a',
				fullName: 'Nouveau Artisan',
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
			await ref.set({
				...model.toMap(),
				'documentId': documentId,
				'createdAt': FieldValue.serverTimestamp(),
				'lastActiveAt': FieldValue.serverTimestamp(),
			});
		} else {
			await ref.update({'lastActiveAt': FieldValue.serverTimestamp()});
		}
		final m = await _fetchWorker(uid);
		return m;
	}

	Future<Worker> _fetchWorker(String uid) async {
		final ref = _db.collection(FirestorePaths.workers).doc(uid);
		final snap = await ref.get();
		final data = snap.data() as Map<String, dynamic>;
		data['id'] = uid;
		return WorkerModel.fromMap(data);
	}

	@override
	Future<void> signOut() async {
		await _auth.signOut();
	}

	@override
	Stream<Worker?> authStateChanges() {
		return _auth.authStateChanges().asyncExpand((user) {
			if (user == null) return Stream<Worker?>.value(null);
			final ref = _db.collection(FirestorePaths.workers).doc(user.uid);
			return ref.snapshots().map((snap) {
				if (!snap.exists) return null;
				final data = snap.data() as Map<String, dynamic>;
				data['id'] = user.uid;
				return WorkerModel.fromMap(data);
			});
		});
	}
}