import 'dart:io' as io;
import 'dart:typed_data';

import 'package:firebase_chat/models.dart';
import 'package:firebase_chat/models/firebase_storage_repository.dart';
import 'package:firebase_chat/models/firestore_repository.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityRepository {
  ActivityRepository(this.path,
      {FirestoreRepository firestoreRepository,
      FirebaseStorageRepository storageRepository})
      : _firestoreRepository = firestoreRepository ?? FirestoreRepository(),
        _storageRepository = storageRepository ?? FirebaseStorageRepository();

  final String path;

  final FirestoreRepository _firestoreRepository;
  final FirebaseStorageRepository _storageRepository;

  DocumentReference<Map<String, dynamic>> get reference =>
      _firestoreRepository.doc(path);

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

  Future<void> addActivity(
      DocumentReference activityReference, ActivityLog activityLog) {
    var json = activityLog.toJson();

    activityReference.set(json).whenComplete(() {
      changeSeenStatus(null, activityReference.path, SeenStatus.Recieved);
    });
    return reference.update({'lastMessage': activityReference});
  }

  Future<void> changeSeenStatus(
      String userId, String path, int seenStatus) async {
    if (path != null)
      return _firestoreRepository.firestore.runTransaction((transaction) async {
        var documentReference = _firestoreRepository.doc(path);
        DocumentSnapshot<Map<String, dynamic>> txSnapshot =
            await transaction.get(documentReference);
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

  Future<String> uploadData(String fileName, dynamic image) async {
    var task;
    if (image is Uint8List)
      task =
          _storageRepository.uploadByteData(['ChatPictures', fileName], image);
    else if (image is io.File) {
      task = _storageRepository.uploadFile(['ChatPictures', fileName], image);
    } // else if (image is Blob) {
    else
      task = _storageRepository.uploadBlob(['ChatPictures', fileName], image);
    // }
    // if (task == null) return null;

    var t = await task;
    return await t.ref.getDownloadURL();
  }

  Stream<QuerySnapshot> getChatImages(DocumentReference proposalReference) {
    return reference
        .collection('Activity')
        .where("activityStatus", isEqualTo: ActivityStatus.Image)
        .orderBy('timestamp', descending: true)
        .snapshots(); //FIXME:
  }
}
