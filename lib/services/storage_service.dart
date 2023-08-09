// storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(File file, String path) async {
    UploadTask uploadTask = _storage.ref(path).putFile(file);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
