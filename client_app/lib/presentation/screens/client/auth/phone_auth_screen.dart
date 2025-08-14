import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../providers/auth_provider.dart';

class PhoneAuthScreen extends StatefulWidget {
	const PhoneAuthScreen({super.key});

	@override
	State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
	final TextEditingController _phoneController = TextEditingController();
	final TextEditingController _nameController = TextEditingController();
	final TextEditingController _otpController = TextEditingController();
	bool _codeSent = false;

	@override
	Widget build(BuildContext context) {
		final auth = context.watch<AuthProvider>();
		return Scaffold(
			backgroundColor: AppColors.gray50,
			body: SafeArea(
				child: Column(
					children: [
						Container(
							height: 200,
							decoration: const BoxDecoration(gradient: AppGradients.primary, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24))),
							child: const Center(
								child: Text('Khidmeti', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
							),
						),
						const SizedBox(height: 24),
						Padding(
							padding: const EdgeInsets.symmetric(horizontal: 20),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.stretch,
								children: [
									if (!_codeSent) ...[
										TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Téléphone', prefixText: '+213 ')),
										const SizedBox(height: 12),
										TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nom d\'utilisateur')),
										const SizedBox(height: 20),
										ElevatedButton(
											onPressed: auth.isLoading
												? null
												: () async {
													await auth.startPhoneSignIn('+213 '+_phoneController.text.trim(), _nameController.text.trim());
													setState(() => _codeSent = true);
												},
											child: const Text('Recevoir le code'),
										),
									],
									if (_codeSent) ...[
										TextField(controller: _otpController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Code OTP')),
										const SizedBox(height: 20),
										ElevatedButton(
											onPressed: auth.isLoading
												? null
												: () async {
													await auth.verifyOtp(_otpController.text.trim());
												},
											child: const Text('Se connecter'),
										),
									],
								],
							),
						),
					],
				),
			),
		);
	}
}