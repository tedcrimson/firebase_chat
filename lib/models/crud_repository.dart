part of 'firestore_repository.dart';

abstract class CRUDRepository {
  Future create(String path, dynamic data);
  Future read(String path);
  Future update(String path, dynamic data);
  Future delete(String path);
}
