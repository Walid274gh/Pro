import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'core/themes/app_colors.dart';
import 'presentation/providers/auth_provider.dart';
import 'services/auth_service.dart';
import 'domain/repositories/auth_repository.dart' as domain;
import 'data/repositories/auth_repository_impl.dart' as data_impl;
import 'presentation/screens/client/auth/phone_auth_screen.dart';
import 'presentation/screens/client/home/home_screen.dart';
import 'services/location_service.dart';
import 'domain/repositories/location_repository.dart' as loc_domain;
import 'data/repositories/location_repository_impl.dart' as loc_impl;
import 'services/job_service.dart';
import 'domain/repositories/job_repository.dart' as job_domain;
import 'data/repositories/job_repository_impl.dart' as job_impl;

Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();
	await Firebase.initializeApp();
	runApp(const MyApp());
}

class MyApp extends StatelessWidget {
	const MyApp({super.key});

	@override
	Widget build(BuildContext context) {
		final domain.AuthRepository authRepo = data_impl.AuthRepositoryImpl();
		final authService = AuthServiceImpl(authRepo);
		final locRepo = loc_impl.LocationRepositoryImpl();
		final locService = LocationServiceImpl(locRepo);
		final job_domain.JobRepository jobRepo = job_impl.JobRepositoryImpl();
		final jobService = JobServiceImpl(jobRepo);
		return MultiProvider(
			providers: [
				ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
				Provider<LocationService>(create: (_) => locService),
				Provider<JobService>(create: (_) => jobService),
			],
			child: MaterialApp(
				title: 'Khidmeti Client',
				theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: AppColors.coral), useMaterial3: true),
				home: Consumer<AuthProvider>(
					builder: (context, auth, _) => auth.currentUser == null ? const PhoneAuthScreen() : const ClientHomeScreen(),
				),
			),
		);
	}
}