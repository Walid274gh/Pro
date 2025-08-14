import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';

class DocumentSignInScreen extends StatefulWidget {
	const DocumentSignInScreen({super.key});

	@override
	State<DocumentSignInScreen> createState() => _DocumentSignInScreenState();
}

class _DocumentSignInScreenState extends State<DocumentSignInScreen> {
	final TextEditingController _doc = TextEditingController();

	@override
	Widget build(BuildContext context) {
		final auth = context.watch<AuthProvider>();
		return Scaffold(
			appBar: AppBar(title: const Text('Connexion Artisan')),
			body: Padding(
				padding: const EdgeInsets.all(16),
				child: Column(
					children: [
						TextField(controller: _doc, decoration: const InputDecoration(labelText: 'N° Document')), 
						const SizedBox(height: 20),
						ElevatedButton(
							onPressed: auth.isLoading ? null : () async {
								await auth.signInWithDocument(_doc.text.trim());
							},
							child: const Text('Se connecter'),
						),
					],
				),
			),
		);
	}
}