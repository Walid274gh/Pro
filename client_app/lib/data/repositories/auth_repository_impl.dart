import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../domain/entities/client_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/client_user_model.dart';
import '../../services/firebase_service.dart';

class AuthRepositoryImpl implements AuthRepository {
	String? _verificationId;
	int? _resendToken;
	String? _pendingPhone;
	String? _pendingUsername;

	FirebaseAuth get _auth => FirebaseService.auth;
	FirebaseFirestore get _db => FirebaseService.db;

	@override
	Future<void> startPhoneSignIn({required String phoneNumber, required String username}) async {
		_pendingPhone = phoneNumber;
		_pendingUsername = username;
		final completer = Completer<void>();
		await _auth.verifyPhoneNumber(
			phoneNumber: phoneNumber,
			forceResendingToken: _resendToken,
			verificationCompleted: (PhoneAuthCredential credential) async {
				await _auth.signInWithCredential(credential);
				await _ensureClientProfile(username);
				if (!completer.isCompleted) completer.complete();
			},
			verificationFailed: (FirebaseAuthException e) {
				if (!completer.isCompleted) completer.completeError(e);
			},
			codeSent: (String verificationId, int? forceResendingToken) {
				_verificationId = verificationId;
				_resendToken = forceResendingToken;
				if (!completer.isCompleted) completer.complete();
			},
			codeAutoRetrievalTimeout: (String verificationId) {
				_verificationId = verificationId;
			},
			timeout: const Duration(seconds: 60),
		);
		return completer.future;
	}

	@override
	Future<ClientUser> verifyOtpCode(String otp) async {
		final String? vid = _verificationId;
		if (vid == null) {
			throw StateError('No verification in progress');
		}
		final credential = PhoneAuthProvider.credential(verificationId: vid, smsCode: otp);
		await _auth.signInWithCredential(credential);
		await _ensureClientProfile(_pendingUsername ?? 'Utilisateur');
		final user = await _buildCurrentUser();
		if (user == null) throw StateError('Authentication failed');
		return user;
	}

	Future<void> _ensureClientProfile(String username) async {
		final uid = _auth.currentUser!.uid;
		final ref = _db.collection(FirestorePaths.clients).doc(uid);
		final snap = await ref.get();
		if (!snap.exists) {
			final model = ClientUserModel(
				id: uid,
				phoneNumber: _auth.currentUser!.phoneNumber ?? _pendingPhone ?? '',
				username: username,
				profileImageUrl: null,
				currentLocation: null,
				isPhoneVerified: true,
				isBlocked: false,
				createdAt: DateTime.now(),
				lastActiveAt: DateTime.now(),
			);
			await ref.set({
				...model.toMap(),
				'createdAt': FieldValue.serverTimestamp(),
				'lastActiveAt': FieldValue.serverTimestamp(),
			});
		} else {
			await ref.update({'lastActiveAt': FieldValue.serverTimestamp()});
		}
	}

	Future<ClientUser?> _buildCurrentUser() async {
		final u = _auth.currentUser;
		if (u == null) return null;
		final ref = _db.collection(FirestorePaths.clients).doc(u.uid);
		final snap = await ref.get();
		if (!snap.exists) return null;
		final data = snap.data() as Map<String, dynamic>;
		data['id'] = u.uid;
		return ClientUserModel.fromMap(data);
	}

	@override
	Future<void> signOut() => _auth.signOut();

	@override
	Stream<ClientUser?> authStateChanges() {
		return _auth.authStateChanges().asyncExpand((user) {
			if (user == null) return Stream<ClientUser?>.value(null);
			final ref = _db.collection(FirestorePaths.clients).doc(user.uid);
			return ref.snapshots().map((snap) {
				if (!snap.exists) return null;
				final data = snap.data() as Map<String, dynamic>;
				data['id'] = user.uid;
				return ClientUserModel.fromMap(data);
			});
		});
	}
}