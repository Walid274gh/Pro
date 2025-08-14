import '../core/constants/document_type.dart';
import '../domain/entities/identity_verification.dart';

abstract class MLKitService {
	Future<ExtractedData> extractDataFromDocument(String imagePath);
	Future<bool> verifyFaceMatch(String selfieUrl, String documentUrl);
	Future<DocumentType> classifyDocument(String imagePath);
}