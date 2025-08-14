import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../services/ml_kit_service_impl.dart';
import '../../../../domain/entities/identity_verification.dart';
import '../../../../core/constants/document_type.dart';
import '../../../../core/constants/verification_status.dart';
import '../../../../services/verification_service.dart';

class VerificationScreen extends StatefulWidget {
	const VerificationScreen({super.key});
	@override
	State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
	final MLKitServiceImpl _ml = MLKitServiceImpl();
	final VerificationService _service = VerificationService();
	File? _docFront;
	File? _selfie;
	ExtractedData? _extracted;
	bool? _faceOk;
	DocumentType? _docType;
	bool _busy = false;

	Future<void> _pickDoc() async {
		final x = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 85);
		if (x != null) {
			setState(() => _docFront = File(x.path));
			_extracted = await _ml.extractDataFromDocument(x.path);
			_docType = await _ml.classifyDocument(x.path);
			setState(() {});
		}
	}

	Future<void> _pickSelfie() async {
		final x = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 85);
		if (x != null) {
			setState(() => _selfie = File(x.path));
			if (_docFront != null) {
				_faceOk = await _ml.verifyFaceMatch(_selfie!.path, _docFront!.path);
				setState(() {});
			}
		}
	}

	Future<void> _submit() async {
		if (_docFront == null || _selfie == null || _extracted == null || _docType == null) return;
		setState(() => _busy = true);
		final workerId = 'me'; // TODO: from worker auth
		final frontUrl = await _service.uploadImage(workerId, _docFront!, 'front');
		final selfieUrl = await _service.uploadImage(workerId, _selfie!, 'selfie');
		final verification = IdentityVerification(
			id: DateTime.now().millisecondsSinceEpoch.toString(),
			workerId: workerId,
			type: _docType!,
			frontImageUrl: frontUrl,
			backImageUrl: selfieUrl,
			extractedInfo: _extracted!,
			faceMatch: FaceVerificationResult(isMatch: _faceOk ?? false, confidence: (_faceOk ?? false) ? 0.9 : 0.0, livenessPassed: true),
			status: VerificationStatus.pending,
			createdAt: DateTime.now(),
		);
		await _service.submitVerification(verification);
		if (mounted) {
			setState(() => _busy = false);
			ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vérification soumise')));
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Vérification d\'identité')),
			body: Padding(
				padding: const EdgeInsets.all(16),
				child: ListView(
					children: [
						Row(children: [
							Expanded(child: ElevatedButton(onPressed: _pickDoc, child: const Text('Scanner Document'))),
							const SizedBox(width: 12),
							Expanded(child: ElevatedButton(onPressed: _pickSelfie, child: const Text('Selfie'))),
						]),
						const SizedBox(height: 16),
						if (_docFront != null) Image.file(_docFront!, height: 160, fit: BoxFit.cover),
						if (_selfie != null) Padding(padding: const EdgeInsets.only(top: 12), child: Image.file(_selfie!, height: 160, fit: BoxFit.cover)),
						const SizedBox(height: 12),
						if (_extracted != null) ...[
							Text('Nom: '+_extracted!.lastName),
							Text('Prénom: '+_extracted!.firstName),
							Text('N°: '+_extracted!.documentNumber),
						],
						if (_docType != null) Text('Type: '+_docType!.name.toUpperCase()),
						if (_faceOk != null) Text(_faceOk! ? 'Correspondance visage: OK' : 'Correspondance visage: Échec', style: TextStyle(color: _faceOk! ? Colors.green : Colors.red)),
						const SizedBox(height: 16),
						ElevatedButton(onPressed: _busy ? null : _submit, child: Text(_busy ? 'Envoi...' : 'Soumettre')),
					],
				),
			),
		);
	}
}