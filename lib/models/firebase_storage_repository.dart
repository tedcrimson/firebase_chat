import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_chat/models/firestore_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageRepository extends CRUDRepository {
  FirebaseStorageRepository({
    FirebaseStorage storage,
  }) : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Reference get ref => _storage.ref();

  // void checkFields(List fields) {
  //   if (fields.contains(null)) throw FirebaseStorageNullArgumentException();
  //   if (fields.length % 2 != 0) throw FirebaseStorageArgumentException();
  // }

  Future<String> getDownloadUrl(List fields) {
    // checkFields(fields);
    return read(fields.join('/'));
  }

  Future<Uint8List> getByteData(List fields, [int maxSize]) {
    // checkFields(fields);
    return ref.child(fields.join('/')).getData(maxSize);
  }

  UploadTask uploadByteData(List fields, Uint8List data) {
    // checkFields(fields);
    return create(fields.join('/'), data);
  }

  UploadTask uploadFile(List fields, File file) {
    // checkFields(fields);
    return ref.child(fields.join('/')).putFile(file);
  }

  UploadTask uploadBlob(List fields, dynamic blob,
      [SettableMetadata metadata]) {
    // checkFields(fields);
    return ref.child(fields.join('/')).putBlob(blob, metadata);
  }

  @override
  UploadTask create(String path, dynamic data) {
    return ref.child(path).putData(data);
  }

  @override
  Future delete(String path) {
    return ref.child(path).delete();
  }

  @override
  Future read(String path) {
    return ref.child(path).getDownloadURL();
  }

  @override
  Future update(String path, dynamic data) {
    return ref.child(path).updateMetadata(data);
  }
}
