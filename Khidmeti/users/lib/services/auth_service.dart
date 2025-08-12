import 'package:firebase_auth/firebase_auth.dart';

// Interface d'authentification (SRP)
abstract class AuthenticationService {
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password);
  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  User? getCurrentUser();
  Stream<User?> get authStateChanges;
}

// Implémentation concrète du service d'authentification
class AuthService implements AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('Erreur de connexion: $e');
      return null;
    }
  }

  @override
  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('Erreur de création de compte: $e');
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Méthodes supplémentaires pour la gestion des utilisateurs
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Erreur d\'envoi d\'email de réinitialisation: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile({String? displayName, String? photoURL}) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      await _auth.currentUser?.updatePhotoURL(photoURL);
    } catch (e) {
      print('Erreur de mise à jour du profil: $e');
      rethrow;
    }
  }

  Future<void> updateUserEmail(String newEmail) async {
    try {
      await _auth.currentUser?.updateEmail(newEmail);
    } catch (e) {
      print('Erreur de mise à jour de l\'email: $e');
      rethrow;
    }
  }

  Future<void> updateUserPassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } catch (e) {
      print('Erreur de mise à jour du mot de passe: $e');
      rethrow;
    }
  }

  Future<void> deleteUser() async {
    try {
      await _auth.currentUser?.delete();
    } catch (e) {
      print('Erreur de suppression du compte: $e');
      rethrow;
    }
  }

  Future<bool> isEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (e) {
      print('Erreur de vérification de l\'email: $e');
      return false;
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      print('Erreur d\'envoi de vérification d\'email: $e');
      rethrow;
    }
  }

  // Méthodes pour la gestion des erreurs d'authentification
  String getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé par un autre compte.';
      case 'weak-password':
        return 'Le mot de passe est trop faible.';
      case 'invalid-email':
        return 'L\'adresse email n\'est pas valide.';
      case 'user-disabled':
        return 'Ce compte utilisateur a été désactivé.';
      case 'too-many-requests':
        return 'Trop de tentatives. Veuillez réessayer plus tard.';
      case 'operation-not-allowed':
        return 'Cette opération n\'est pas autorisée.';
      case 'network-request-failed':
        return 'Erreur de réseau. Vérifiez votre connexion.';
      default:
        return 'Une erreur inattendue s\'est produite.';
    }
  }

  // Méthodes pour la validation des données
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isValidPassword(String password) {
    // Au moins 8 caractères, une majuscule, une minuscule, un chiffre
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$').hasMatch(password);
  }

  String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'L\'email est requis.';
    }
    if (!isValidEmail(email)) {
      return 'Veuillez entrer un email valide.';
    }
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Le mot de passe est requis.';
    }
    if (password.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères.';
    }
    if (!isValidPassword(password)) {
      return 'Le mot de passe doit contenir au moins une majuscule, une minuscule et un chiffre.';
    }
    return null;
  }

  String? validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return 'La confirmation du mot de passe est requise.';
    }
    if (password != confirmPassword) {
      return 'Les mots de passe ne correspondent pas.';
    }
    return null;
  }
}