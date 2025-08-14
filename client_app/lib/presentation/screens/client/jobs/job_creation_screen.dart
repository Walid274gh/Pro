import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../domain/value_objects/location.dart';
import '../../../../domain/value_objects/time_slot.dart';
import '../../../../core/constants/service_categories.dart';
import '../../../../domain/entities/job_request.dart';
import '../../../../services/job_service.dart';
import '../../../../services/storage_service.dart';

class JobCreationScreen extends StatefulWidget {
	const JobCreationScreen({super.key});

	@override
	State<JobCreationScreen> createState() => _JobCreationScreenState();
}

class _JobCreationScreenState extends State<JobCreationScreen> {
	final TextEditingController _title = TextEditingController();
	final TextEditingController _desc = TextEditingController();
	ServiceCategory _category = ServiceCategory.cleaning;
	DateTime _date = DateTime.now().add(const Duration(days: 1));
	TimeSlot _slot = const TimeSlot(startMinutes: 9*60, endMinutes: 11*60);
	final Location _mockLocation = const Location(latitude: 36.7525, longitude: 3.04197);
	final TextEditingController _budget = TextEditingController();
	final List<File> _media = <File>[];
	bool _isUploading = false;

	Future<void> _pickMedia() async {
		final picker = ImagePicker();
		final images = await picker.pickMultiImage(imageQuality: 85);
		setState(() {
			_media.addAll(images.map((x) => File(x.path)));
		});
	}

	@override
	Widget build(BuildContext context) {
		final jobService = Provider.of<JobService>(context, listen: false);
		final storage = StorageService();
		return Scaffold(
			appBar: AppBar(title: const Text('Nouveau Travail')),
			body: Padding(
				padding: const EdgeInsets.all(16),
				child: ListView(
					children: [
						TextField(controller: _title, decoration: const InputDecoration(labelText: 'Titre')), 
						const SizedBox(height: 12),
						TextField(controller: _desc, maxLines: 4, decoration: const InputDecoration(labelText: 'Description')), 
						const SizedBox(height: 12),
						DropdownButtonFormField<ServiceCategory>(
							value: _category,
							decoration: const InputDecoration(labelText: 'Catégorie'),
							items: ServiceCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
							onChanged: (v) => setState(() => _category = v ?? _category),
						),
						const SizedBox(height: 12),
						TextField(controller: _budget, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Budget max (DA)')), 
						const SizedBox(height: 12),
						Wrap(
							spacing: 8,
							runSpacing: 8,
							children: [
								..._media.map((f) => Stack(
									children: [
										ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(f, width: 90, height: 90, fit: BoxFit.cover)),
										Positioned(
											right: 0,
											top: 0,
											child: InkWell(onTap: () { setState(() { _media.remove(f); }); }, child: const CircleAvatar(radius: 12, child: Icon(Icons.close, size: 14))),
										),
									],
								)),
								OutlinedButton.icon(onPressed: _pickMedia, icon: const Icon(Icons.add_a_photo), label: const Text('Ajouter des photos')),
							],
						),
						const SizedBox(height: 20),
						ElevatedButton(
							onPressed: _isUploading ? null : () async {
								setState(() => _isUploading = true);
								final urls = <String>[];
								for (final f in _media) {
									final url = await storage.uploadJobMedia(clientId: 'me', file: f);
									urls.add(url);
								}
								final job = JobRequest(
									id: 'local',
									title: _title.text.trim(),
									description: _desc.text.trim(),
									mediaUrls: urls,
									category: _category,
									preferredDate: _date,
									timeSlot: _slot,
									workLocation: _mockLocation,
									budgetMax: double.tryParse(_budget.text.trim()),
									clientId: 'me',
									createdAt: DateTime.now(),
									status: 'open',
								);
								final id = await jobService.createJob(job);
								if (context.mounted) Navigator.of(context).pop(id);
								setState(() => _isUploading = false);
							},
							child: Text(_isUploading ? 'Publication...' : 'Publier la demande'),
						),
					],
				),
			),
		);
	}
}