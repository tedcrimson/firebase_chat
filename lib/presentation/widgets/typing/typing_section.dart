import 'dart:async';
import 'package:firebase_chat/models/peer_user.dart';
import 'package:firebase_chat/presentation/widgets/typing/typing_widget.dart';
import 'package:firebase_chat/repositories/activity_repository.dart';
import 'package:flutter/material.dart';

class TypingSection extends StatefulWidget {
  final ActivityRepository activityRepository;
  final Map<String, PeerUser> peers;
  final String userId;
  final Color color;
  const TypingSection({
    @required this.userId,
    @required this.activityRepository,
    @required this.peers,
    this.color,
  });
  @override
  _TypingSectionState createState() => _TypingSectionState();
}

class _TypingSectionState extends State<TypingSection> {
  List<String> typingPeers = [];
  StreamSubscription _typingSubscription;

  @override
  void initState() {
    _typingSubscription =
        widget.activityRepository.reference.snapshots().listen((onData) {
      var data = onData.data();
      if (onData.exists) {
        var typing = data['typing'];
        if (typing != null) {
          setState(() {
            typingPeers = typing.keys
                .where((element) => typing[element] == true)
                .toList();
          });
        }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _typingSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: typingPeers
          .map(
            (e) => widget.peers[e]?.id == widget.userId
                ? SizedBox()
                : TypingWidget(
                    widget.peers[e],
                    widget.color,
                  ),
          )
          .toList(),
    );
  }
}
