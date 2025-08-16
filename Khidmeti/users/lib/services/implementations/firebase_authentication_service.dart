import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/user_constants.dart';
import '../../models/user_model.dart';
import '../abstracts/authentication_service.dart';
import '../abstracts/user_repository.dart';

// Implémentation Firebase du service d'authentification (SRP)
class FirebaseAuthenticationService implements AuthenticationService {
  final FirebaseAuth _auth;
  final UserRepository _userRepository;
  final FirebaseFirestore _firestore;
  
  // Stream controller pour les changements d'état
  final StreamController<UserModel?> _authStateController = StreamController<UserModel?>.broadcast();

  FirebaseAuthenticationService({
    FirebaseAuth? auth,
    UserRepository? userRepository,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _userRepository = userRepository!,
       _firestore = firestore ?? FirebaseFirestore.instance {
    // Écouter les changements d'authentification Firebase
    _auth.authStateChanges().listen((User? firebaseUser) {
      if (firebaseUser != null) {
        _loadUserData(firebaseUser.uid);
      } else {
        _authStateController.add(null);
      }
    });
  }

  @override
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      // Validation des entrées
      if (!isEmailValid(email)) {
        throw AuthException('Email invalide');
      }
      if (!isPasswordValid(password)) {
        throw AuthException('Mot de passe invalide');
      }

      // Authentification Firebase
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(UserConstants.authTimeout);

      if (credential.user != null) {
        // Charger les données utilisateur depuis Firestore
        final userModel = await _userRepository.getUserById(credential.user!.uid);
        _authStateController.add(userModel);
        return userModel;
      }
      
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } on TimeoutException {
      throw AuthException('Délai d\'authentification dépassé');
    } catch (e) {
      throw AuthException('Erreur d\'authentification: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> signUpWithEmail(
    String email, 
    String password, 
    String firstName, 
    String lastName
  ) async {
    try {
      // Validation des entrées
      if (!isEmailValid(email)) {
        throw AuthException('Email invalide');
      }
      if (!isPasswordValid(password)) {
        throw AuthException('Mot de passe invalide');
      }
      if (firstName.isEmpty || lastName.isEmpty) {
        throw AuthException('Prénom et nom requis');
      }

      // Vérifier si l'email est disponible
      final isEmailAvailable = await _userRepository.isEmailAvailable(email);
      if (!isEmailAvailable) {
        throw AuthException('Cet email est déjà utilisé');
      }

      // Créer l'utilisateur Firebase
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(UserConstants.authTimeout);

      if (credential.user != null) {
        // Créer le modèle utilisateur
        final userModel = UserModel(
          id: credential.user!.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isVerified: false,
        );

        // Sauvegarder dans Firestore
        await _userRepository.createUser(userModel);
        
        // Envoyer l'email de vérification
        await verifyEmail();
        
        _authStateController.add(userModel);
        return userModel;
      }
      
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } on TimeoutException {
      throw AuthException('Délai d\'inscription dépassé');
    } catch (e) {
      throw AuthException('Erreur d\'inscription: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _authStateController.add(null);
    } catch (e) {
      throw AuthException('Erreur lors de la déconnexion: ${e.toString()}');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  @override
  UserModel? get currentUser {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      // Retourner l'utilisateur actuel depuis le cache ou null
      return null; // Sera mis à jour via le stream
    }
    return null;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      if (!isEmailValid(email)) {
        throw AuthException('Email invalide');
      }
      
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Erreur lors de l\'envoi de l\'email: ${e.toString()}');
    }
  }

  @override
  Future<void> verifyEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Erreur lors de la vérification: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUserProfile(UserModel user) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw AuthException('Aucun utilisateur connecté');
      }

      // Mettre à jour dans Firestore
      await _userRepository.updateUser(user);
      
      // Mettre à jour le stream
      _authStateController.add(user);
    } catch (e) {
      throw AuthException('Erreur lors de la mise à jour: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      if (!isPasswordValid(newPassword)) {
        throw AuthException('Nouveau mot de passe invalide');
      }

      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      } else {
        throw AuthException('Aucun utilisateur connecté');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Erreur lors de la mise à jour du mot de passe: ${e.toString()}');
    }
  }

  @override
  bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email) && email.length <= 254;
  }

  @override
  bool isPasswordValid(String password) {
    return password.length >= UserConstants.minPasswordLength &&
           password.contains(RegExp(r'[A-Z]')) &&
           password.contains(RegExp(r'[a-z]')) &&
           password.contains(RegExp(r'[0-9]'));
  }

  // Méthodes privées
  Future<void> _loadUserData(String userId) async {
    try {
      final userModel = await _userRepository.getUserById(userId);
      _authStateController.add(userModel);
    } catch (e) {
      _authStateController.add(null);
    }
  }

  AuthException _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException('Aucun utilisateur trouvé avec cet email');
      case 'wrong-password':
        return AuthException('Mot de passe incorrect');
      case 'email-already-in-use':
        return AuthException('Cet email est déjà utilisé');
      case 'weak-password':
        return AuthException('Le mot de passe est trop faible');
      case 'invalid-email':
        return AuthException('Email invalide');
      case 'user-disabled':
        return AuthException('Compte désactivé');
      case 'too-many-requests':
        return AuthException('Trop de tentatives. Réessayez plus tard');
      default:
        return AuthException('Erreur d\'authentification: ${e.message}');
    }
  }

  // Méthode de nettoyage
  void dispose() {
    _authStateController.close();
  }
}

// Classe d'exception personnalisée
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  
  @override
  String toString() => message;
}