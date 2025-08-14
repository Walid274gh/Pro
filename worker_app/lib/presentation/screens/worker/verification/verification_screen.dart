import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../services/ml_kit_service_impl.dart';
import '../../../../domain/entities/identity_verification.dart';
import '../../../../core/constants/document_type.dart';

class VerificationScreen extends StatefulWidget {
	const VerificationScreen({super.key});
	@override
	State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
	final MLKitServiceImpl _ml = MLKitServiceImpl();
	File? _docFront;
	File? _selfie;
	ExtractedData? _extracted;
	bool? _faceOk;
	DocumentType? _docType;

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
					],
				),
			),
		);
	}
}