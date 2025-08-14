import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../core/constants/firestore_paths.dart';
import '../domain/entities/identity_verification.dart';

class VerificationService {
	final FirebaseFirestore _db = FirebaseFirestore.instance;
	final FirebaseStorage _storage = FirebaseStorage.instance;

	Future<String> uploadImage(String workerId, File file, String tag) async {
		final path = 'verifications/'+workerId+'/'+tag+'_'+DateTime.now().millisecondsSinceEpoch.toString()+'.jpg';
		final ref = _storage.ref().child(path);
		await ref.putFile(file, SettableMetadata(cacheControl: 'public, max-age=3600'));
		return ref.getDownloadURL();
	}

	Future<void> submitVerification(IdentityVerification verification) async {
		final ref = _db.collection(FirestorePaths.verifications).doc(verification.id);
		await ref.set({
			'id': verification.id,
			'workerId': verification.workerId,
			'type': verification.type.name,
			'frontImageUrl': verification.frontImageUrl,
			'backImageUrl': verification.backImageUrl,
			'extractedInfo': {
				'firstName': verification.extractedInfo.firstName,
				'lastName': verification.extractedInfo.lastName,
				'documentNumber': verification.extractedInfo.documentNumber,
				'birthDate': verification.extractedInfo.birthDate.millisecondsSinceEpoch,
				'expiryDate': verification.extractedInfo.expiryDate.millisecondsSinceEpoch,
				'nationality': verification.extractedInfo.nationality,
			},
			'faceMatch': {
				'isMatch': verification.faceMatch.isMatch,
				'confidence': verification.faceMatch.confidence,
				'livenessPassed': verification.faceMatch.livenessPassed,
			},
			'status': verification.status.name,
			'createdAt': FieldValue.serverTimestamp(),
		});
	}
}