import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'core/themes/app_colors.dart';
import 'services/job_service.dart';
import 'domain/repositories/job_repository.dart' as domain;
import 'data/repositories/job_repository_impl.dart' as data_impl;
import 'presentation/screens/worker/dashboard/dashboard_screen.dart';

Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();
	await Firebase.initializeApp();
	runApp(const WorkerApp());
}

class WorkerApp extends StatelessWidget {
	const WorkerApp({super.key});

	@override
	Widget build(BuildContext context) {
		final domain.JobRepository repo = data_impl.JobRepositoryImpl();
		final jobService = JobServiceImpl(repo);
		return Provider<JobService>(
			create: (_) => jobService,
			child: MaterialApp(
				title: 'Khidmeti Worker',
				theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: AppColors.violetDeep), useMaterial3: true),
				home: const WorkerDashboardScreen(),
			),
		);
	}
}