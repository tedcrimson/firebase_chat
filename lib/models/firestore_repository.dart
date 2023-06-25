import 'package:cloud_firestore/cloud_firestore.dart';
part 'crud_repository.dart';
part 'exceptions.dart';
part 'query_filter.dart';

class FirestoreRepository extends CRUDRepository {
  FirestoreRepository(
      {FirebaseFirestore firestore, bool persistenceEnabled = false})
      : this.firestore = firestore ?? FirebaseFirestore.instance {
    this.firestore.settings = Settings(persistenceEnabled: persistenceEnabled);
  }

  final FirebaseFirestore firestore;
  // final FirebaseAuthenticationRepository _auth;

  DocumentReference doc(String path) => firestore.doc(path);

  Future<QuerySnapshot> getCollection(List<String> fields,
      {List<QueryFilter> filters,
      DocumentSnapshot startAfter,
      int limit,
      GetOptions getOptions}) async {
    return getQuery(fields,
            filters: filters, startAfter: startAfter, limit: limit)
        .get(getOptions);
  }

  Query getQuery(List<String> fields,
      {List<QueryFilter> filters, DocumentSnapshot startAfter, int limit}) {
    if (fields.contains(null)) throw FirestoreNullArgumentException();
    if (fields.length % 2 == 0) throw FirestoreArgumentException();
    Query query = firestore.collection(fields.join('/'));
    if (filters != null) {
      for (var filter in filters)
        query = query.where(
          filter.field,
          isEqualTo: filter.isEqualTo,
          isLessThan: filter.isLessThan,
          isLessThanOrEqualTo: filter.isLessThanOrEqualTo,
          isGreaterThan: filter.isGreaterThan,
          isGreaterThanOrEqualTo: filter.isGreaterThanOrEqualTo,
          arrayContains: filter.arrayContains,
          arrayContainsAny: filter.arrayContainsAny,
          whereIn: filter.whereIn,
          isNull: filter.isNull,
        );
    }

    if (startAfter != null) query = query.startAfterDocument(startAfter);
    if (limit != null) query = query.limit(limit);

    return limitQuery(query, startAfter: startAfter, limit: limit);
  }

  Query limitQuery(Query query, {DocumentSnapshot startAfter, int limit}) {
    if (startAfter != null) query = query.startAfterDocument(startAfter);
    if (limit != null) query = query.limit(limit);

    return query;
  }

  Future<DocumentSnapshot> getDocument(List<String> fields) {
    if (fields.contains(null)) throw FirestoreNullArgumentException();
    if (fields.length % 2 != 0) throw FirestoreArgumentException();
    return read(fields.join('/'));
  }

  Future<void> addData(List<String> fields, Map<String, dynamic> jsonData) {
    if (fields.contains(null)) throw FirestoreNullArgumentException();
    if (fields.length % 2 == 0) throw FirestoreArgumentException();
    return create(fields.join('/'), jsonData);
  }

  Future<void> setData(List<String> fields, Map<String, dynamic> jsonData) {
    if (fields.contains(null)) throw FirestoreNullArgumentException();
    if (fields.length % 2 != 0) throw FirestoreArgumentException();
    return _set(fields.join('/'), jsonData);
  }

  Future<void> updateData(List<String> fields, Map<String, dynamic> jsonData) {
    if (fields.contains(null)) throw FirestoreNullArgumentException();
    if (fields.length % 2 != 0) throw FirestoreArgumentException();
    return update(fields.join('/'), jsonData);
  }

  Stream<DocumentSnapshot> listen(List<String> fields) {
    if (fields.contains(null)) throw FirestoreNullArgumentException();
    if (fields.length % 2 != 0) throw FirestoreArgumentException();
    return firestore.doc(fields.join('/')).snapshots();
  }

  @override
  Future<DocumentReference> create(String path, dynamic data) {
    return firestore.collection(path).add(data);
  }

  @override
  Future<void> delete(String path) {
    return firestore.doc(path).delete();
  }

  @override
  Future<DocumentSnapshot> read(String path) {
    return firestore.doc(path).get();
  }

  @override
  Future<void> update(String path, dynamic data) {
    return firestore.doc(path).update(data);
  }

  Future<void> _set(String path, dynamic data) {
    return firestore.doc(path).set(data);
  }
}
