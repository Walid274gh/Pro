// Abstract BaseModel respectant le principe SRP
abstract class BaseModel {
  String get id;
  DateTime get createdAt;
  Map<String, dynamic> toMap();
  
  // Méthode utilitaire pour la validation
  bool isValid();
}