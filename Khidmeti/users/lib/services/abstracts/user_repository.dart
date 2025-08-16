import '../../models/user_model.dart';

// Interface abstract pour le repository utilisateur (SRP)
abstract class UserRepository {
  // Opérations de lecture
  Future<UserModel?> getUserById(String id);
  Stream<UserModel?> getUserStream(String id);
  Future<List<UserModel>> getAllUsers();
  
  // Opérations d'écriture
  Future<void> createUser(UserModel user);
  Future<void> updateUser(UserModel user);
  Future<void> deleteUser(String id);
  
  // Opérations de recherche
  Future<List<UserModel>> searchUsers(String query);
  Future<List<UserModel>> getUsersByLocation(GeoPoint location, double radius);
  
  // Opérations de validation
  Future<bool> isEmailAvailable(String email);
  Future<bool> isPhoneAvailable(String phoneNumber);
}