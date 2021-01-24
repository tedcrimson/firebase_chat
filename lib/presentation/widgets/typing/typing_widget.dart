import 'package:firebase_chat/models/peer_user.dart';
import 'package:firebase_chat/presentation/widgets/chat_avatar.dart';
import 'package:firebase_chat/presentation/widgets/typing/typing_animation.dart';
import 'package:firebase_chat/utils/converter.dart';
import 'package:flutter/material.dart';

class TypingWidget extends StatelessWidget {
  final PeerUser peer;
  final Color color;

  const TypingWidget(this.peer, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              //avatar
              ChatAvatar(
                showAvatar: true,
                peer: peer,
                userImage: Converter.convertToImage(peer?.image, size: 40),
              ),
              Flexible(
                  child: Material(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                      elevation: 1,
                      clipBehavior: Clip.hardEdge,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: TypingAnimation(color),
                      )))
            ]));
  }
}
