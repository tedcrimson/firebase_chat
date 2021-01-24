import 'package:firebase_chat/models/peer_user.dart';
import 'package:flutter/material.dart';

class ChatAvatar extends StatelessWidget {
  final bool showAvatar;
  final PeerUser peer;
  final Widget userImage;
  final double width;
  final double height;
  const ChatAvatar({Key key, this.showAvatar, this.peer, this.userImage, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(right: 8),
        child: showAvatar
            ? ClipOval(
                child: Container(
                    color: Colors.indigo,
                    width: width ?? 35,
                    height: height ?? 35,
                    child: peer?.image == null || peer.image.isEmpty
                        ? Center(
                            child: Text(
                            peer.name[0],
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ))
                        : userImage),
              )
            : Container(
                width: width ?? 35,
              ));
  }
}
