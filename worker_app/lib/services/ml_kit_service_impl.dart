import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../core/constants/document_type.dart';
import '../domain/entities/identity_verification.dart';
import 'ml_kit_service.dart';

class MLKitServiceImpl implements MLKitService {
	@override
	Future<ExtractedData> extractDataFromDocument(String imagePath) async {
		final InputImage inputImage = InputImage.fromFile(File(imagePath));
		final textRecognizer = TextRecognizer();
		final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
		await textRecognizer.close();

		String firstName = '';
		String lastName = '';
		String documentNumber = '';
		String nationality = '';
		DateTime birthDate = DateTime.fromMillisecondsSinceEpoch(0);
		DateTime expiryDate = DateTime.fromMillisecondsSinceEpoch(0);

		for (final block in recognizedText.blocks) {
			final t = block.text;
			if (t.contains('NOM')) {
				lastName = t.split(':').last.trim();
			}
			if (t.contains('PRENOM') || t.contains('PRÉNOM')) {
				firstName = t.split(':').last.trim();
			}
			if (t.contains('N°') || t.toLowerCase().contains('num')) {
				documentNumber = t.replaceAll(RegExp(r'[^A-Z0-9]'), '').substring(0, (t.length).clamp(0, 12));
			}
			if (t.toLowerCase().contains('nationalite') || t.toLowerCase().contains('nationalité')) {
				nationality = t.split(':').last.trim();
			}
			if (t.toLowerCase().contains('naissance')) {
				final m = RegExp(r'(\d{2}[\-/]\d{2}[\-/]\d{4})').firstMatch(t);
				if (m != null) birthDate = DateTime.tryParse(m.group(1)!.replaceAll('/', '-')) ?? birthDate;
			}
			if (t.toLowerCase().contains('expiration') || t.toLowerCase().contains('expiry')) {
				final m = RegExp(r'(\d{2}[\-/]\d{2}[\-/]\d{4})').firstMatch(t);
				if (m != null) expiryDate = DateTime.tryParse(m.group(1)!.replaceAll('/', '-')) ?? expiryDate;
			}
		}

		return ExtractedData(
			firstName: firstName,
			lastName: lastName,
			documentNumber: documentNumber,
			birthDate: birthDate,
			expiryDate: expiryDate,
			nationality: nationality,
		);
	}

	@override
	Future<bool> verifyFaceMatch(String selfieUrl, String documentUrl) async {
		final faceDetector = FaceDetector(options: const FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate));
		final selfie = await faceDetector.processImage(InputImage.fromFilePath(selfieUrl));
		final doc = await faceDetector.processImage(InputImage.fromFilePath(documentUrl));
		await faceDetector.close();
		// Simple heuristic: exactly one face in each and similar bounding box ratio
		if (selfie.length != 1 || doc.length != 1) return false;
		final r1 = selfie.first.boundingBox.width / selfie.first.boundingBox.height;
		final r2 = doc.first.boundingBox.width / doc.first.boundingBox.height;
		final diff = (r1 - r2).abs();
		return diff < 0.25; // placeholder; in prod use a proper embedding-based matcher
	}

	@override
	Future<DocumentType> classifyDocument(String imagePath) async {
		// Placeholder: rely on heuristics of text content length
		final InputImage inputImage = InputImage.fromFile(File(imagePath));
		final textRecognizer = TextRecognizer();
		final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
		await textRecognizer.close();
		final textLen = recognizedText.text.length;
		if (textLen > 500) return DocumentType.passport;
		if (textLen > 200) return DocumentType.idCard;
		return DocumentType.drivingLicense;
	}
}