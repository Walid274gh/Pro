import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '../models/worker.dart';
import '../utils/firebase_config.dart';

class WorkerAuthService {
  static final WorkerAuthService _instance = WorkerAuthService._internal();
  factory WorkerAuthService() => _instance;
  WorkerAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Worker? _currentWorker;
  Worker? get currentWorker => _currentWorker;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> initialize() async {
    // Charger le worker si connecté
    final user = _auth.currentUser;
    if (user != null) {
      _currentWorker = await _fetchWorker(user.uid);
    }

    _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        _currentWorker = await _fetchWorker(firebaseUser.uid);
      } else {
        _currentWorker = null;
      }
    });
  }

  Future<Worker?> _fetchWorker(String workerId) async {
    final doc = await _firestore.collection(FirebaseConfig.workersCollection).doc(workerId).get();
    if (!doc.exists) return null;
    return Worker.fromFirestore(doc);
  }

  Future<Worker> signInWithEmail({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final worker = await _fetchWorker(credential.user!.uid);
      if (worker == null) {
        throw AuthException('Profil travailleur introuvable');
      }
      _currentWorker = worker;
      await _updateLastActive(worker.id);
      return worker;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code));
    } catch (e) {
      throw AuthException('Erreur de connexion: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentWorker = null;
  }

  Future<Worker> registerWorker({
    // Identité du compte
    required String email,
    required String password,
    String? phoneNumber,

    // Données personnelles (si non fournies, OCR tentera de les extraire)
    String? firstName,
    String? lastName,

    // Documents d'identité
    required String identityCardType, // FirebaseConfig.supportedIdentityTypes
    required String identityCardNumber,
    required File identityFrontImage,
    required File identityBackImage,

    // Selfie pour vérification faciale
    required File selfieImage,

    // Certificat pro (optionnel)
    File? professionalCertificateImage,
    DateTime? certificateIssueDate,

    // Métadonnées
    String language = FirebaseConfig.defaultLanguage,
  }) async {
    try {
      // Vérifier unicité de la carte
      await _ensureUniqueIdentity(identityCardNumber);

      // Créer l'utilisateur auth
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final String workerId = credential.user!.uid;

      // OCR des noms si manquants
      String extractedFirstName = firstName ?? '';
      String extractedLastName = lastName ?? '';
      if (extractedFirstName.isEmpty || extractedLastName.isEmpty) {
        final names = await _extractNamesFromId(identityFrontImage);
        extractedFirstName = extractedFirstName.isEmpty ? names.firstName : extractedFirstName;
        extractedLastName = extractedLastName.isEmpty ? names.lastName : extractedLastName;
      }

      // Vérification faciale basique (présence de visage sur selfie et ID)
      final bool faceOk = await _basicFaceVerification(identityFrontImage, selfieImage);

      // Upload des documents
      final frontUrl = await _uploadFile(identityFrontImage, 'identity_documents/$workerId/front.jpg');
      final backUrl = await _uploadFile(identityBackImage, 'identity_documents/$workerId/back.jpg');
      final selfieUrl = await _uploadFile(selfieImage, 'identity_documents/$workerId/selfie.jpg');
      String? certUrl;
      if (professionalCertificateImage != null) {
        certUrl = await _uploadFile(professionalCertificateImage, 'identity_documents/$workerId/certificate.jpg');
      }

      // Calcul du score initial
      final int years = _yearsOfExperienceFromCertificate(certificateIssueDate);
      final double initialScore = _computeInitialScore(years, hasCertificate: certUrl != null);

      final now = DateTime.now();
      final worker = Worker(
        id: workerId,
        firstName: extractedFirstName,
        lastName: extractedLastName,
        phoneNumber: phoneNumber,
        email: email,
        profileImageUrl: null,
        identityCardUrl: frontUrl,
        identityCardBackUrl: backUrl,
        identityCardType: identityCardType,
        identityCardNumber: identityCardNumber,
        identityCardExpiry: null,
        status: WorkerStatus.pending,
        isIdentityVerified: true,
        isFaceVerified: faceOk,
        verificationNotes: null,
        verifiedAt: null,
        verifiedBy: null,
        subscriptionStatus: SubscriptionStatus.free,
        subscriptionStartDate: now,
        subscriptionEndDate: DateTime(now.year, now.month + FirebaseConfig.freeTrialMonths, now.day),
        subscriptionPlan: null,
        subscriptionAmount: 0.0,
        lastPaymentReceiptUrl: null,
        lastPaymentDate: null,
        services: const [],
        certifications: certUrl != null ? ['certificat_professionnel'] : const [],
        experienceYears: years,
        hourlyRate: 0.0,
        currency: 'DZD',
        skills: const {},
        currentLocation: null,
        currentAddress: null,
        isOnline: false,
        lastActive: now,
        availability: const {},
        maxDistance: FirebaseConfig.defaultMaxDistance,
        rating: 0.0,
        totalReviews: 0,
        reviews: const [],
        initialScore: initialScore,
        completedJobs: 0,
        cancelledJobs: 0,
        fcmToken: null,
        language: language,
        notificationsEnabled: true,
        createdAt: now,
        updatedAt: now,
        metadata: const {},
      );

      await _firestore.collection(FirebaseConfig.workersCollection).doc(workerId).set(worker.toFirestore());
      _currentWorker = worker;

      return worker;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code));
    } catch (e) {
      throw AuthException('Erreur lors de l\'inscription: $e');
    }
  }

  Future<void> updateProfile({String? firstName, String? lastName, String? phoneNumber, String? profileImageUrl, List<String>? services, double? hourlyRate, double? maxDistance, String? language}) async {
    if (_currentWorker == null) throw AuthException('Aucun travailleur connecté');
    final updated = _currentWorker!.copyWith(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      profileImageUrl: profileImageUrl,
      services: services,
      hourlyRate: hourlyRate,
      maxDistance: maxDistance,
      language: language,
      updatedAt: DateTime.now(),
    );
    await _firestore.collection(FirebaseConfig.workersCollection).doc(updated.id).update(updated.toFirestore());
    _currentWorker = updated;
  }

  Future<void> _ensureUniqueIdentity(String identityCardNumber) async {
    final existing = await _firestore
        .collection(FirebaseConfig.workersCollection)
        .where('identityCardNumber', isEqualTo: identityCardNumber)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      throw AuthException('Cette pièce d\'identité est déjà utilisée');
    }
  }

  Future<void> _updateLastActive(String workerId) async {
    await _firestore.collection(FirebaseConfig.workersCollection).doc(workerId).update({
      'lastActive': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> _uploadFile(File file, String path) async {
    final ref = _storage.ref().child(path);
    final snap = await ref.putFile(file);
    return await snap.ref.getDownloadURL();
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'invalid-email':
        return 'Email invalide';
      case 'weak-password':
        return 'Mot de passe trop faible';
      case 'user-not-found':
      case 'wrong-password':
        return 'Identifiants incorrects';
      default:
        return 'Erreur d\'authentification ($code)';
    }
  }

  // OCR simple pour extraire nom/prénom à partir de la carte
  Future<_Names> _extractNamesFromId(File frontImage) async {
    try {
      final input = InputImage.fromFile(frontImage);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(input);
      await textRecognizer.close();

      String firstName = '';
      String lastName = '';
      final content = recognizedText.text.toUpperCase();

      // Heuristique simple: chercher des labels usuels
      // Ex: NOM, PRENOM, NAME, FIRST NAME, LAST NAME
      for (final block in recognizedText.blocks) {
        final blockText = block.text.toUpperCase();
        if (blockText.contains('PRENOM') || blockText.contains('FIRST')) {
          firstName = _extractFollowingWord(blockText, ['PRENOM', 'FIRST', 'FIRST NAME']);
        }
        if (blockText.contains('NOM') || blockText.contains('LAST')) {
          lastName = _extractFollowingWord(blockText, ['NOM', 'LAST', 'LAST NAME']);
        }
      }

      // Fallback: prendre deux premiers mots en lettres capitales
      if (firstName.isEmpty || lastName.isEmpty) {
        final tokens = content.split(RegExp(r'[^A-ZÀÂÄÇÉÈÊËÎÏÔÖÙÛÜ\-]+')).where((s) => s.length >= 2).toList();
        if (tokens.length >= 2) {
          lastName = lastName.isEmpty ? tokens[0] : lastName;
          firstName = firstName.isEmpty ? tokens[1] : firstName;
        }
      }

      return _Names(firstName: _toTitle(firstName), lastName: _toTitle(lastName));
    } catch (_) {
      return _Names(firstName: '', lastName: '');
    }
  }

  String _extractFollowingWord(String text, List<String> keys) {
    for (final key in keys) {
      final idx = text.indexOf(key);
      if (idx >= 0) {
        final after = text.substring(idx + key.length).trim();
        final token = after.split(RegExp(r'[^A-ZÀÂÄÇÉÈÊËÎÏÔÖÙÛÜ\-]+')).where((s) => s.isNotEmpty).toList();
        if (token.isNotEmpty) return token.first;
      }
    }
    return '';
  }

  String _toTitle(String s) {
    if (s.isEmpty) return s;
    final lower = s.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  // Vérification faciale basique: présence d'un visage sur chaque image
  Future<bool> _basicFaceVerification(File idImage, File selfieImage) async {
    final faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(enableContours: true, enableClassification: true),
    );
    try {
      final idFaces = await faceDetector.processImage(InputImage.fromFile(idImage));
      final selfieFaces = await faceDetector.processImage(InputImage.fromFile(selfieImage));
      // Heuristique minimale: au moins un visage détecté sur chaque
      return idFaces.isNotEmpty && selfieFaces.isNotEmpty;
    } finally {
      await faceDetector.close();
    }
  }

  int _yearsOfExperienceFromCertificate(DateTime? issuedAt) {
    if (issuedAt == null) return 0;
    final now = DateTime.now();
    int years = now.year - issuedAt.year;
    if (DateTime(now.year, issuedAt.month, issuedAt.day).isAfter(now)) {
      years -= 1;
    }
    return years;
  }

  double _computeInitialScore(int years, {required bool hasCertificate}) {
    double score = 5.0 + (years * 0.5);
    if (hasCertificate) score += 2.0;
    if (years >= 5) score += 2.0; // Bonus ancienneté > 5 ans
    if (score > 10) score = 10;
    return score;
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => 'AuthException: $message';
}

class _Names {
  final String firstName;
  final String lastName;
  _Names({required this.firstName, required this.lastName});
}