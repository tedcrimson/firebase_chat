import 'package:firebase_chat/firebase_chat.dart';
import 'package:firebase_chat/models/activities/activitylog.dart';

class ChatEntity {
  final PeerUser mainUser; //TODO: change name
  final Map<String, PeerUser> peers;
  final ActivityLog lastMessage;
  final String path;
  final String title;

  ChatEntity({
    this.mainUser,
    this.peers,
    this.lastMessage,
    this.path,
    this.title,
  });
}
