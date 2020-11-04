import 'dart:typed_data';

import 'package:firebase_chat/models.dart';
import 'package:firebase_storage_repository/firebase_storage_repository.dart';
import 'package:firestore_repository/firestore_repository.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityRepository {
  ActivityRepository(this.path, {FirestoreRepository firestoreRepository, FirebaseStorageRepository storageRepository})
      : _firestoreRepository = firestoreRepository ?? FirestoreRepository(),
        _storageRepository = storageRepository ?? FirebaseStorageRepository();

  final String path;

  final FirestoreRepository _firestoreRepository;
  final FirebaseStorageRepository _storageRepository;

  DocumentReference get reference => _firestoreRepository.doc(path);

  DocumentReference createActivityReference() {
    return reference.collection('Activity').doc();
  }

  Future setTyping(String userId, bool typing) {
    return reference.set(
      {
        'typing': {userId: typing}
      },
      SetOptions(merge: true),
    );
  }

  Future<void> addActivity(DocumentReference activityReference, ActivityLog activityLog) {
    var json = activityLog.toJson();

    activityReference.set(json).whenComplete(() {
      changeSeenStatus(null, activityReference.path, SeenStatus.Recieved);
    });
    return reference.update({'lastMessage': activityReference});
  }

  Future<void> changeSeenStatus(String userId, String path, int seenStatus) async {
    if (path != null)
      return _firestoreRepository.firestore.runTransaction((transaction) async {
        var documentReference = _firestoreRepository.doc(path);
        DocumentSnapshot txSnapshot = await transaction.get(documentReference);
        if (!txSnapshot.exists) return;
        var map = txSnapshot.data();
        if (userId != null) {
          if (map['seenBy'] == null) map['seenBy'] = [];
          map['seenBy'].add(userId);
        }
        map['seenStatus'] = seenStatus;
        transaction.update(documentReference, map);
      });

    // .catchError((e) {
    //   return false;
    // });
  }

  Future<String> uploadData(String fileName, Uint8List image) async {
    var task = await _storageRepository.uploadByteData(['ChatPictures', fileName], image);
    return await task.ref.getDownloadURL();
  }

  Stream<QuerySnapshot> getChatImages(DocumentReference proposalReference) {
    return reference
        .collection('Activity')
        .where("activityStatus", isEqualTo: ActivityStatus.Image)
        .orderBy('timestamp', descending: true)
        .snapshots(); //DEBUG: asd
  }
}
