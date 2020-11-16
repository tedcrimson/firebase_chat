import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final List<String> users;
  final DocumentReference lastMessageReference;
  final String path;
  final String title;
  ChatModel({this.users, this.path, this.lastMessageReference, this.title});

  factory ChatModel.fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data();
    var users = List<String>.from(data['users']);
    return ChatModel(
      users: users,
      lastMessageReference: data['lastMessage'],
      path: snap.reference.path,
      title: data['title'],
    );
  }

  Map<String, Object> toJson() {
    var map = Map<String, Object>();
    map['users'] = users;
    map['title'] = title;
    return map;
  }
}
