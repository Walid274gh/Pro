import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../services/ml_kit_service_impl.dart';
import '../../../../services/verification_service.dart';
import '../../../../domain/entities/identity_verification.dart';
import '../../../../core/constants/document_type.dart';
import '../../../../core/constants/verification_status.dart';

class VerificationStepperScreen extends StatefulWidget {
	const VerificationStepperScreen({super.key});
	@override
	State<VerificationStepperScreen> createState() => _VerificationStepperScreenState();
}

class _VerificationStepperScreenState extends State<VerificationStepperScreen> {
	int _currentStep = 0;
	final MLKitServiceImpl _ml = MLKitServiceImpl();
	final VerificationService _service = VerificationService();

	File? _docFront;
	File? _selfie;
	ExtractedData? _extracted;
	DocumentType? _docType;
	bool? _faceOk;
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
		final workerId = 'me'; // TODO: replace with authenticated worker id
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
		if (!mounted) return;
		setState(() => _busy = false);
		ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vérification envoyée')));
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Vérification d\'identité')),
			body: Stepper(
				currentStep: _currentStep,
				onStepContinue: () async {
					if (_currentStep == 0) {
						setState(() => _currentStep = 1);
					} else if (_currentStep == 1) {
						setState(() => _currentStep = 2);
					} else if (_currentStep == 2) {
						await _submit();
					}
				},
				onStepCancel: () {
					if (_currentStep > 0) setState(() => _currentStep -= 1);
				},
				controlsBuilder: (context, details) {
					return Row(children: [
						ElevatedButton(onPressed: _busy ? null : details.onStepContinue, child: Text(_currentStep == 2 ? (_busy ? 'Envoi...' : 'Soumettre') : 'Continuer')),
						const SizedBox(width: 8),
						if (_currentStep > 0) OutlinedButton(onPressed: details.onStepCancel, child: const Text('Retour')),
					]);
				},
				steps: [
					Step(
						title: const Text('Document'),
						isActive: _currentStep >= 0,
						state: _docFront != null ? StepState.complete : StepState.indexed,
						content: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
							ElevatedButton(onPressed: _pickDoc, child: const Text('Scanner le document')),
							const SizedBox(height: 12),
							if (_docFront != null) Image.file(_docFront!, height: 160, fit: BoxFit.cover),
							if (_extracted != null) ...[
								Text('Nom: '+_extracted!.lastName),
								Text('Prénom: '+_extracted!.firstName),
								Text('N°: '+_extracted!.documentNumber),
							],
							if (_docType != null) Text('Type: '+_docType!.name.toUpperCase()),
						]),
					),
					Step(
						title: const Text('Selfie & Liveness'),
						isActive: _currentStep >= 1,
						state: _selfie != null ? StepState.complete : StepState.indexed,
						content: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
							ElevatedButton(onPressed: _pickSelfie, child: const Text('Prendre un selfie')),
							const SizedBox(height: 12),
							if (_selfie != null) Image.file(_selfie!, height: 160, fit: BoxFit.cover),
							if (_faceOk != null) Text(_faceOk! ? 'Correspondance visage: OK' : 'Correspondance visage: Échec', style: TextStyle(color: _faceOk! ? Colors.green : Colors.red)),
						]),
					),
					Step(
						title: const Text('Récapitulatif'),
						isActive: _currentStep >= 2,
						state: StepState.indexed,
						content: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
							Text('Vérifiez vos informations avant l\'envoi'),
							const SizedBox(height: 8),
							Text('Nom: '+(_extracted?.lastName ?? '-')),
							Text('Prénom: '+(_extracted?.firstName ?? '-')),
							Text('N° doc: '+(_extracted?.documentNumber ?? '-')),
							Text('Type: '+(_docType?.name.toUpperCase() ?? '-')),
						]),
					),
				],
			),
		);
	}
}