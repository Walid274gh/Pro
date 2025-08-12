import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/worker_model.dart';
import '../models/service_model.dart';
import '../models/request_model.dart';

// Interface de base de données (SRP)
abstract class DatabaseService {
  // Opérations sur les utilisateurs
  Future<void> createUser(UserModel user);
  Future<UserModel?> getUser(String userId);
  Future<void> updateUser(UserModel user);
  Future<void> deleteUser(String userId);
  
  // Opérations sur les travailleurs
  Future<List<WorkerModel>> getWorkers();
  Future<WorkerModel?> getWorker(String workerId);
  Future<List<WorkerModel>> searchWorkers(String query);
  Future<List<WorkerModel>> getWorkersByCategory(String category);
  
  // Opérations sur les services
  Future<List<ServiceModel>> getServices();
  Future<ServiceModel?> getService(String serviceId);
  Future<List<ServiceModel>> getServicesByCategory(String category);
  Future<List<ServiceModel>> searchServices(String query);
  
  // Opérations sur les demandes
  Future<void> createRequest(RequestModel request);
  Future<RequestModel?> getRequest(String requestId);
  Future<List<RequestModel>> getUserRequests(String userId);
  Future<void> updateRequest(RequestModel request);
  Future<void> deleteRequest(String requestId);
}

// Implémentation concrète du service de base de données
class FirestoreDatabaseService implements DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== OPÉRATIONS SUR LES UTILISATEURS =====
  
  @override
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      print('Erreur de création d\'utilisateur: $e');
      rethrow;
    }
  }

  @override
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Erreur de récupération d\'utilisateur: $e');
      return null;
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      print('Erreur de mise à jour d\'utilisateur: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      print('Erreur de suppression d\'utilisateur: $e');
      rethrow;
    }
  }

  // ===== OPÉRATIONS SUR LES TRAVAILLEURS =====

  @override
  Future<List<WorkerModel>> getWorkers() async {
    try {
      final querySnapshot = await _firestore
          .collection('workers')
          .where('isAvailable', isEqualTo: true)
          .orderBy('rating', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => WorkerModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Erreur de récupération des travailleurs: $e');
      return [];
    }
  }

  @override
  Future<WorkerModel?> getWorker(String workerId) async {
    try {
      final doc = await _firestore.collection('workers').doc(workerId).get();
      if (doc.exists) {
        return WorkerModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Erreur de récupération de travailleur: $e');
      return null;
    }
  }

  @override
  Future<List<WorkerModel>> searchWorkers(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('workers')
          .where('isAvailable', isEqualTo: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => WorkerModel.fromMap(doc.data()))
          .where((worker) => 
              worker.name.toLowerCase().contains(query.toLowerCase()) ||
              worker.skills.any((skill) => skill.toLowerCase().contains(query.toLowerCase())))
          .toList();
    } catch (e) {
      print('Erreur de recherche de travailleurs: $e');
      return [];
    }
  }

  @override
  Future<List<WorkerModel>> getWorkersByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection('workers')
          .where('isAvailable', isEqualTo: true)
          .where('skills', arrayContains: category)
          .orderBy('rating', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => WorkerModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Erreur de récupération de travailleurs par catégorie: $e');
      return [];
    }
  }

  // ===== OPÉRATIONS SUR LES SERVICES =====

  @override
  Future<List<ServiceModel>> getServices() async {
    try {
      final querySnapshot = await _firestore
          .collection('services')
          .where('isAvailable', isEqualTo: true)
          .orderBy('rating', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => ServiceModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Erreur de récupération des services: $e');
      return [];
    }
  }

  @override
  Future<ServiceModel?> getService(String serviceId) async {
    try {
      final doc = await _firestore.collection('services').doc(serviceId).get();
      if (doc.exists) {
        return ServiceModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Erreur de récupération de service: $e');
      return null;
    }
  }

  @override
  Future<List<ServiceModel>> getServicesByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection('services')
          .where('isAvailable', isEqualTo: true)
          .where('category', isEqualTo: category)
          .orderBy('rating', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => ServiceModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Erreur de récupération de services par catégorie: $e');
      return [];
    }
  }

  @override
  Future<List<ServiceModel>> searchServices(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('services')
          .where('isAvailable', isEqualTo: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => ServiceModel.fromMap(doc.data()))
          .where((service) => 
              service.name.toLowerCase().contains(query.toLowerCase()) ||
              service.description.toLowerCase().contains(query.toLowerCase()) ||
              service.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase())))
          .toList();
    } catch (e) {
      print('Erreur de recherche de services: $e');
      return [];
    }
  }

  // ===== OPÉRATIONS SUR LES DEMANDES =====

  @override
  Future<void> createRequest(RequestModel request) async {
    try {
      await _firestore.collection('requests').doc(request.id).set(request.toMap());
    } catch (e) {
      print('Erreur de création de demande: $e');
      rethrow;
    }
  }

  @override
  Future<RequestModel?> getRequest(String requestId) async {
    try {
      final doc = await _firestore.collection('requests').doc(requestId).get();
      if (doc.exists) {
        return RequestModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Erreur de récupération de demande: $e');
      return null;
    }
  }

  @override
  Future<List<RequestModel>> getUserRequests(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('requests')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => RequestModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Erreur de récupération des demandes utilisateur: $e');
      return [];
    }
  }

  @override
  Future<void> updateRequest(RequestModel request) async {
    try {
      await _firestore.collection('requests').doc(request.id).update(request.toMap());
    } catch (e) {
      print('Erreur de mise à jour de demande: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteRequest(String requestId) async {
    try {
      await _firestore.collection('requests').doc(requestId).delete();
    } catch (e) {
      print('Erreur de suppression de demande: $e');
      rethrow;
    }
  }

  // ===== MÉTHODES UTILITAIRES =====

  // Générer un ID unique pour les documents
  String generateDocumentId() {
    return _firestore.collection('temp').doc().id;
  }

  // Obtenir la référence d'un document
  DocumentReference getDocumentReference(String collection, String documentId) {
    return _firestore.collection(collection).doc(documentId);
  }

  // Écouter les changements en temps réel
  Stream<List<UserModel>> streamUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data()))
            .toList());
  }

  Stream<List<WorkerModel>> streamWorkers() {
    return _firestore
        .collection('workers')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorkerModel.fromMap(doc.data()))
            .toList());
  }

  Stream<List<ServiceModel>> streamServices() {
    return _firestore
        .collection('services')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceModel.fromMap(doc.data()))
            .toList());
  }

  Stream<List<RequestModel>> streamUserRequests(String userId) {
    return _firestore
        .collection('requests')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RequestModel.fromMap(doc.data()))
            .toList());
  }
}