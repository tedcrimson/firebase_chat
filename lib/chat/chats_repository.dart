import 'package:firebase_chat/models.dart';
import 'package:firestore_repository/firestore_repository.dart';

class ChatsRepository {
  ChatsRepository({FirestoreRepository firestoreRepository})
      : _firestoreRepository = firestoreRepository ?? FirestoreRepository();

  final FirestoreRepository _firestoreRepository;

  Query getChatsQuery(String collection, List<QueryFilter> filters) {
    return _firestoreRepository.getQuery([collection], filters: filters);
  }

  Future<PeerUser> getPeer(String userId) async {
    var snap = await _firestoreRepository.getDocument(['Users', userId]);
    return PeerUser.fromSnapshot(snap);
  }

  Future<ActivityLog> getActivity(DocumentReference reference) async {
    if (reference == null) return null;
    var snap = await reference.get();
    return ActivityLog.fromSnapshot(snap);
  }
}
