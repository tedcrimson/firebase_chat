import 'package:cloud_firestore/cloud_firestore.dart';

class PeerUser {
  final String id;
  final String image;
  final String name;

  PeerUser({this.id, this.image, this.name});

  factory PeerUser.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    var data = snap.data();
    return PeerUser(
        id: snap.id,
        image: data['image'],
        name: data['firstName'] + " " + data['lastName']);
  }
}
