import 'package:firebase_chat/firebase_chat.dart';

class ChatEntity {
  final PeerUser mainUser;
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
