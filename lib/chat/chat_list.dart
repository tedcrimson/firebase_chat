import 'package:firebase_chat/chat/chats_repository.dart';
import 'package:firebase_chat/models.dart';

import 'package:firestore_repository/firestore_repository.dart';
import 'package:flutter/material.dart';

class ChatList extends StatefulWidget {
  final String userId;

  final ChatsRepository chatsRepository;
  final PaginationList Function(PaginationBloc) paginationBuilder;
  final PaginationArgs<ChatEntity> paginationArgs;
  const ChatList({
    @required this.userId,
    @required this.chatsRepository,
    this.paginationBuilder,
    this.paginationArgs,
  });

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  PaginationBloc _paginationBloc;

  @override
  void initState() {
    _paginationBloc = PaginationBloc<ChatEntity>(
        widget.chatsRepository.getChatsQuery('Chats', [QueryFilter('users', arrayContains: widget.userId)]),
        (snap) async {
      var model = ChatModel.fromSnapshot(snap);
      Map<String, PeerUser> peers = Map<String, PeerUser>();
      for (var userId in model.users) {
        var peer = await widget.chatsRepository.getPeer(userId);
        peers[userId] = peer;
      }

      var lastActivity = await widget.chatsRepository.getActivity(model.lastMessageReference);
      return ChatEntity(
          mainUser: peers[widget.userId],
          peers: peers,
          lastMessage: lastActivity,
          path: snap.reference.path,
          title: model.title);
    });
    super.initState();
  }

  @override
  void dispose() {
    _paginationBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.paginationBuilder != null) {
      return widget.paginationBuilder(_paginationBloc);
    } else if (widget.paginationArgs != null)
      return PaginationList<ChatEntity>(
        arguments: widget.paginationArgs,
        paginationBloc: _paginationBloc,
      );
    else {
      return Center(child: Text("implement pagination"));
    }
  }
}
