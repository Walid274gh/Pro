import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/auth_service.dart';
import '../../utils/firebase_config.dart';

class RegisterWorkerScreen extends StatefulWidget {
  const RegisterWorkerScreen({super.key});

  @override
  State<RegisterWorkerScreen> createState() => _RegisterWorkerScreenState();
}

class _RegisterWorkerScreenState extends State<RegisterWorkerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _auth = WorkerAuthService();

  // Account
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // Identity
  String _idType = FirebaseConfig.supportedIdentityTypes.first;
  final _idNumberCtrl = TextEditingController();
  File? _idFront;
  File? _idBack;
  File? _selfie;

  // Personal
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();

  // Certificate (optional)
  File? _certificate;
  DateTime? _certificateIssueDate;

  bool _busy = false;
  String? _error;

  Future<void> _pickImage(Function(File) setter, {bool camera = true}) async {
    final XFile? picked = await (camera
        ? _picker.pickImage(source: ImageSource.camera, imageQuality: 85)
        : _picker.pickImage(source: ImageSource.gallery, imageQuality: 85));
    if (picked != null) {
      setter(File(picked.path));
      setState(() {});
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_idFront == null || _idBack == null || _selfie == null) {
      setState(() => _error = 'Veuillez fournir recto/verso de la pièce et un selfie');
      return;
    }

    setState(() { _busy = true; _error = null; });
    try {
      await _auth.registerWorker(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        phoneNumber: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        firstName: _firstNameCtrl.text.trim().isEmpty ? null : _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim().isEmpty ? null : _lastNameCtrl.text.trim(),
        identityCardType: _idType,
        identityCardNumber: _idNumberCtrl.text.trim(),
        identityFrontImage: _idFront!,
        identityBackImage: _idBack!,
        selfieImage: _selfie!,
        professionalCertificateImage: _certificate,
        certificateIssueDate: _certificateIssueDate,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickIssueDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(context: context, firstDate: DateTime(1990), lastDate: now, initialDate: now);
    if (d != null) setState(() => _certificateIssueDate = d);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription Travailleur')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Compte', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v == null || v.isEmpty ? 'Email requis' : null,
              ),
              TextFormField(
                controller: _passCtrl,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (v) => v != null && v.length >= 6 ? null : '6 caractères minimum',
              ),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Téléphone (optionnel)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              const Text('Identité', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _idType,
                items: FirebaseConfig.supportedIdentityTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _idType = v ?? _idType),
                decoration: const InputDecoration(labelText: 'Type de pièce'),
              ),
              TextFormField(
                controller: _idNumberCtrl,
                decoration: const InputDecoration(labelText: 'Numéro de pièce'),
                validator: (v) => v == null || v.isEmpty ? 'Numéro requis' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ImageTile(
                      label: 'Recto',
                      file: _idFront,
                      onPickCamera: () => _pickImage((f) => _idFront = f, camera: true),
                      onPickGallery: () => _pickImage((f) => _idFront = f, camera: false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ImageTile(
                      label: 'Verso',
                      file: _idBack,
                      onPickCamera: () => _pickImage((f) => _idBack = f, camera: true),
                      onPickGallery: () => _pickImage((f) => _idBack = f, camera: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _ImageTile(
                label: 'Selfie',
                file: _selfie,
                onPickCamera: () => _pickImage((f) => _selfie = f, camera: true),
                onPickGallery: () => _pickImage((f) => _selfie = f, camera: false),
              ),
              const SizedBox(height: 16),
              const Text('Informations personnelles', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _firstNameCtrl,
                decoration: const InputDecoration(labelText: 'Prénom (peut être rempli via OCR)'),
              ),
              TextFormField(
                controller: _lastNameCtrl,
                decoration: const InputDecoration(labelText: 'Nom (peut être rempli via OCR)'),
              ),
              const SizedBox(height: 16),
              const Text('Certificat professionnel (optionnel)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ImageTile(
                      label: 'Certificat',
                      file: _certificate,
                      onPickCamera: () => _pickImage((f) => _certificate = f, camera: true),
                      onPickGallery: () => _pickImage((f) => _certificate = f, camera: false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickIssueDate,
                      child: Text(_certificateIssueDate == null
                          ? 'Date d\'émission'
                          : 'Émis le ${_certificateIssueDate!.day}/${_certificateIssueDate!.month}/${_certificateIssueDate!.year}'),
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Créer mon compte'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  final String label;
  final File? file;
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;
  const _ImageTile({required this.label, required this.file, required this.onPickCamera, required this.onPickGallery});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (file != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(file!, height: 100, fit: BoxFit.cover),
            )
          else
            Container(
              height: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.image, size: 40, color: Colors.grey),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(onPressed: onPickCamera, icon: const Icon(Icons.photo_camera), label: const Text('Caméra')),
              OutlinedButton.icon(onPressed: onPickGallery, icon: const Icon(Icons.photo_library), label: const Text('Galerie')),
            ],
          )
        ],
      ),
    );
  }
}