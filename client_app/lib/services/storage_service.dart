import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
	final FirebaseStorage _storage = FirebaseStorage.instance;

	Future<String> uploadJobMedia({required String clientId, required File file}) async {
		final String path = 'jobs/'+clientId+'/'+DateTime.now().millisecondsSinceEpoch.toString()+'.'+file.path.split('.').last;
		final ref = _storage.ref().child(path);
		final task = await ref.putFile(file, SettableMetadata(cacheControl: 'public, max-age=3600'));
		return task.ref.getDownloadURL();
	}
}