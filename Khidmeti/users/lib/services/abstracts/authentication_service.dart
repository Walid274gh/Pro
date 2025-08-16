import '../../models/user_model.dart';

// Interface abstract pour le service d'authentification (SRP)
abstract class AuthenticationService {
  // Méthodes d'authentification
  Future<UserModel?> signInWithEmail(String email, String password);
  Future<UserModel?> signUpWithEmail(String email, String password, String firstName, String lastName);
  Future<void> signOut();
  
  // Gestion de l'état d'authentification
  Stream<UserModel?> get authStateChanges;
  UserModel? get currentUser;
  
  // Méthodes de récupération
  Future<void> sendPasswordResetEmail(String email);
  Future<void> verifyEmail();
  
  // Méthodes de mise à jour
  Future<void> updateUserProfile(UserModel user);
  Future<void> updatePassword(String newPassword);
  
  // Méthodes de validation
  bool isEmailValid(String email);
  bool isPasswordValid(String password);
}