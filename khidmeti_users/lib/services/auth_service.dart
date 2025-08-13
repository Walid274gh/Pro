import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'firebase_sync_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseSyncService _syncService = FirebaseSyncService();

  // État de l'utilisateur actuel
  User? _currentUser;
  User? get currentUser => _currentUser;

  // Stream de l'état d'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges().map(_mapFirebaseUser);

  // Initialisation du service
  Future<void> initialize() async {
    // Écouter les changements d'état d'authentification
    _auth.authStateChanges().listen((firebaseUser) {
      _currentUser = _mapFirebaseUser(firebaseUser);
      if (_currentUser != null) {
        _syncService.initialize();
      }
    });

    // Vérifier si un utilisateur est déjà connecté
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      _currentUser = await _mapFirebaseUser(firebaseUser);
      await _syncService.initialize();
    }
  }

  // Inscription avec email et mot de passe
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    try {
      // Créer l'utilisateur Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Créer le profil utilisateur dans Firestore
      User user = User(
        id: userCredential.user!.uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
        language: await _getStoredLanguage(),
      );

      await _firestore
          .collection('users')
          .doc(user.id)
          .set(user.toFirestore());

      // Mettre à jour l'utilisateur actuel
      _currentUser = user;

      // Envoyer l'email de vérification
      await userCredential.user!.sendEmailVerification();

      return user;
    } on FirebaseAuthException catch (e) {
      String message = _getAuthErrorMessage(e.code);
      throw AuthException(message);
    } catch (e) {
      throw AuthException('Une erreur inattendue s\'est produite: $e');
    }
  }

  // Inscription avec numéro de téléphone
  Future<void> signUpWithPhone({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    try {
      // Vérifier si le numéro est déjà utilisé
      QuerySnapshot existingUsers = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      if (existingUsers.docs.isNotEmpty) {
        throw AuthException('Ce numéro de téléphone est déjà utilisé');
      }

      // Créer l'utilisateur dans Firestore (sans authentification Firebase)
      User user = User(
        id: _generateTemporaryId(),
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
        language: await _getStoredLanguage(),
      );

      await _firestore
          .collection('users')
          .doc(user.id)
          .set(user.toFirestore());

      // Stocker temporairement les informations pour la vérification
      await _storeTemporaryUser(user);

      // TODO: Implémenter la vérification SMS
      // await _verifyPhoneNumber(phoneNumber);
    } catch (e) {
      throw AuthException('Erreur lors de l\'inscription: $e');
    }
  }

  // Connexion avec email et mot de passe
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Récupérer les données utilisateur depuis Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw AuthException('Profil utilisateur introuvable');
      }

      User user = User.fromFirestore(userDoc);
      _currentUser = user;

      // Mettre à jour la dernière activité
      await _updateLastActive(user.id);

      // Mettre à jour le token FCM
      await _updateFcmToken(user.id);

      return user;
    } on FirebaseAuthException catch (e) {
      String message = _getAuthErrorMessage(e.code);
      throw AuthException(message);
    } catch (e) {
      throw AuthException('Erreur lors de la connexion: $e');
    }
  }

  // Connexion avec numéro de téléphone
  Future<User> signInWithPhone({
    required String phoneNumber,
    required String verificationCode,
  }) async {
    try {
      // TODO: Vérifier le code SMS
      // bool isValid = await _verifySmsCode(phoneNumber, verificationCode);
      // if (!isValid) throw AuthException('Code de vérification invalide');

      // Rechercher l'utilisateur par numéro de téléphone
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      if (userQuery.docs.isEmpty) {
        throw AuthException('Aucun compte trouvé avec ce numéro');
      }

      User user = User.fromFirestore(userQuery.docs.first);
      _currentUser = user;

      // Mettre à jour la dernière activité
      await _updateLastActive(user.id);

      // Mettre à jour le token FCM
      await _updateFcmToken(user.id);

      return user;
    } catch (e) {
      throw AuthException('Erreur lors de la connexion: $e');
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      // Mettre à jour le statut hors ligne
      if (_currentUser != null) {
        await _updateLastActive(_currentUser!.id);
        await _removeFcmToken(_currentUser!.id);
      }

      // Déconnexion Firebase
      await _auth.signOut();
      _currentUser = null;

      // Nettoyer les préférences locales
      await _clearLocalData();
    } catch (e) {
      throw AuthException('Erreur lors de la déconnexion: $e');
    }
  }

  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      String message = _getAuthErrorMessage(e.code);
      throw AuthException(message);
    } catch (e) {
      throw AuthException('Erreur lors de la réinitialisation: $e');
    }
  }

  // Mise à jour du profil utilisateur
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      if (_currentUser == null) {
        throw AuthException('Aucun utilisateur connecté');
      }

      User updatedUser = _currentUser!.copyWith(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
      );

      await _firestore
          .collection('users')
          .doc(updatedUser.id)
          .update(updatedUser.toFirestore());

      _currentUser = updatedUser;
    } catch (e) {
      throw AuthException('Erreur lors de la mise à jour du profil: $e');
    }
  }

  // Mise à jour de la langue
  Future<void> updateLanguage(String language) async {
    try {
      if (_currentUser == null) {
        throw AuthException('Aucun utilisateur connecté');
      }

      User updatedUser = _currentUser!.updateLanguage(language);
      await _firestore
          .collection('users')
          .doc(updatedUser.id)
          .update(updatedUser.toFirestore());

      _currentUser = updatedUser;

      // Stocker la langue localement
      await _storeLanguage(language);
    } catch (e) {
      throw AuthException('Erreur lors de la mise à jour de la langue: $e');
    }
  }

  // Suppression du compte
  Future<void> deleteAccount() async {
    try {
      if (_currentUser == null) {
        throw AuthException('Aucun utilisateur connecté');
      }

      // Supprimer les données Firestore
      await _firestore
          .collection('users')
          .doc(_currentUser!.id)
          .delete();

      // Supprimer le compte Firebase Auth
      await _auth.currentUser?.delete();

      _currentUser = null;
      await _clearLocalData();
    } catch (e) {
      throw AuthException('Erreur lors de la suppression du compte: $e');
    }
  }

  // Vérification de l'email
  Future<void> verifyEmail() async {
    try {
      User? firebaseUser = _auth.currentUser;
      if (firebaseUser != null && !firebaseUser.emailVerified) {
        await firebaseUser.sendEmailVerification();
      }
    } catch (e) {
      throw AuthException('Erreur lors de l\'envoi de la vérification: $e');
    }
  }

  // Mise à jour de la dernière activité
  Future<void> _updateLastActive(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur lors de la mise à jour de la dernière activité: $e');
    }
  }

  // Mise à jour du token FCM
  Future<void> _updateFcmToken(String userId) async {
    try {
      // TODO: Obtenir le token FCM actuel
      // String? fcmToken = await FirebaseMessaging.instance.getToken();
      // if (fcmToken != null) {
      //   await _firestore
      //       .collection('users')
      //       .doc(userId)
      //       .update({'fcmToken': fcmToken});
      // }
    } catch (e) {
      print('Erreur lors de la mise à jour du token FCM: $e');
    }
  }

  // Suppression du token FCM
  Future<void> _removeFcmToken(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'fcmToken': FieldValue.delete()});
    } catch (e) {
      print('Erreur lors de la suppression du token FCM: $e');
    }
  }

  // Mapper Firebase User vers notre modèle User
  User? _mapFirebaseUser(FirebaseUser? firebaseUser) {
    if (firebaseUser == null) return null;
    
    // Retourner l'utilisateur actuel s'il existe déjà
    if (_currentUser != null && _currentUser!.id == firebaseUser.uid) {
      return _currentUser;
    }
    
    return null; // L'utilisateur sera chargé depuis Firestore
  }

  // Obtenir la langue stockée localement
  Future<String> _getStoredLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('language') ?? 'fr';
  }

  // Stocker la langue localement
  Future<void> _storeLanguage(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
  }

  // Stocker temporairement les informations utilisateur
  Future<void> _storeTemporaryUser(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('temp_user_id', user.id);
    await prefs.setString('temp_user_phone', user.phoneNumber ?? '');
  }

  // Nettoyer les données locales
  Future<void> _clearLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('temp_user_id');
    await prefs.remove('temp_user_phone');
  }

  // Générer un ID temporaire
  String _generateTemporaryId() {
    return 'temp_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Obtenir le message d'erreur d'authentification
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'weak-password':
        return 'Le mot de passe est trop faible';
      case 'invalid-email':
        return 'Adresse email invalide';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard';
      case 'operation-not-allowed':
        return 'Cette opération n\'est pas autorisée';
      default:
        return 'Erreur d\'authentification: $code';
    }
  }

  // Vérifier si l'utilisateur est connecté
  bool get isSignedIn => _currentUser != null;

  // Vérifier si l'email est vérifié
  bool get isEmailVerified {
    FirebaseUser? firebaseUser = _auth.currentUser;
    return firebaseUser?.emailVerified ?? false;
  }

  // Obtenir l'ID de l'utilisateur actuel
  String? get currentUserId => _currentUser?.id;

  // Obtenir la langue actuelle
  String get currentLanguage => _currentUser?.language ?? 'fr';
}

// Exception personnalisée pour l'authentification
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}