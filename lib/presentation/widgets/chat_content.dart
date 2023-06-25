import 'dart:math';

import 'package:firebase_chat/models.dart';
import 'package:firebase_chat/presentation/widgets/activities/image_activity_widget.dart';
import 'package:firebase_chat/presentation/widgets/activities/text_activity_widget.dart';
import 'package:firebase_chat/presentation/widgets/chat_avatar.dart';
import 'package:firebase_chat/repositories/activity_repository.dart';
import 'package:firebase_chat/utils/converter.dart';

import 'package:flutter/material.dart';
import 'package:gallery_previewer/gallery_previewer.dart';
import 'package:intl/intl.dart';

class ChatActivityWidget extends StatelessWidget {
  final List<ActivityLog> listMessage;

  final int i;
  final PeerUser peer;

  // final Map<String,//TODO:ADD PEERS FOR SEENBY
  final String userId;
  final ActivityLog activityLog;
  final List<GalleryViewItem> images;

  final Radius corner = const Radius.circular(18.0);
  final Radius flat = const Radius.circular(5.0);
  final ActivityRepository activityRepository;
  final Color primaryColor;
  final Widget loadingWidget;

  const ChatActivityWidget({
    Key key,
    this.primaryColor = Colors.blue,
    this.activityLog,
    this.i,
    this.listMessage,
    this.userId,
    this.peer,
    this.images,
    this.activityRepository,
    this.loadingWidget,
  }) : super(key: key);

  bool get isMe {
    return activityLog.userId == this.userId;
  }

  @override
  Widget build(BuildContext context) {
    var index = i;

    // print("OLA");
    if (!isMe && !activityLog.seenBy.contains(userId)) {
      activityRepository.changeSeenStatus(
          userId, activityLog.path, SeenStatus.Seen);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            padding: EdgeInsets.only(
              left: 10.0,
              right: 10.0,
              bottom: isMe && isLastMessageRight(index) ? 20.0 : 2.0,
            ),
            child: Row(
                mainAxisAlignment:
                    isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                // mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  //avatar
                  ChatAvatar(
                    showAvatar: !isMe &&
                        (index == 0 ||
                            listMessage[max(0, index - 1)].userId !=
                                listMessage[index].userId),
                    peer: peer,
                    userImage: Converter.convertToImage(peer?.image, size: 35),
                  ),
                  Flexible(
                    child: Material(
                        color: isMe && activityLog is TextActivity
                            ? primaryColor
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.only(
                          topLeft:
                              (isMe) || (!isMe && isLastMessageLeft(index + 2))
                                  ? corner
                                  : flat,
                          topRight:
                              (isMe && isLastMessageRight(index + 2)) || (!isMe)
                                  ? corner
                                  : flat,
                          bottomRight:
                              isMe && isLastMessageRight(index) || (!isMe)
                                  ? corner
                                  : flat,
                          bottomLeft: isMe ||
                                  (!isMe &&
                                      isLastMessageLeft(index) &&
                                      index == i)
                              ? corner
                              : flat,
                        ),
                        elevation: 1,
                        clipBehavior: Clip.hardEdge,
                        child: _drawMessage(activityLog, isMe)),
                  ),

                  //seen
                  if (isMe)
                    Icon(
                      activityLog.seenStatus == SeenStatus.Sent
                          ? Icons.check_circle_outline
                          : activityLog.seenStatus == SeenStatus.Recieved
                              ? Icons.check_circle_rounded
                              : Icons.check_circle,
                      size: 12,
                      color: activityLog.seenStatus < SeenStatus.Seen
                          ? primaryColor
                          : Colors.transparent,
                    )
                ])),
        // if (isMe)
        // Row(children: activityLog.seenBy.map((e) => Text(e)).toList()),

        // Time
        if (!isMe && isLastMessageLeft(index))
          Container(
            child: Text(
              DateFormat('dd MMM kk:mm')
                  .format((activityLog.timestamp).toDate()),
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 12.0,
                  fontStyle: FontStyle.italic),
            ),
            margin: EdgeInsets.only(left: 5.0, top: 5.0, bottom: 5.0),
          )
      ],
    );
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[min(index, listMessage.length) - 1].userId ==
                this.userId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[min(index, listMessage.length) - 1].userId !=
                this.userId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  _drawMessage(ActivityLog activityLog, bool isMe) {
    if (activityLog is ImageActivity) {
      return ImageActivityWidget(
        imageActivity: activityLog,
        images: images,
        loadingWidget: loadingWidget,
      );
    } else {
      return TextActivityWidget(
        textActivity: activityLog as TextActivity,
        isMe: isMe,
      );
    }
  }
}
