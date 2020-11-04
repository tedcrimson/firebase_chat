import 'package:firebase_chat/utils/converter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_chat/models.dart';

class DefaultChatCard extends StatelessWidget {
  final ChatEntity entity;
  final ValueChanged<ChatEntity> onTap;

  const DefaultChatCard({@required this.entity, @required this.onTap});
  @override
  Widget build(BuildContext context) {
    String lastMessage = "";
    String lastTime = "";
    if (entity.lastMessage != null) {
      var activity = entity.lastMessage;
      DateTime date = activity.timestamp.toDate();
      String dateformat = DateTime.now().day == date.day ? "hh:mm" : "dd/MM";
      if (activity is TextActivity) lastMessage = activity.text;
      lastTime = DateFormat(dateformat).format(activity.timestamp.toDate());
    }
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
      onTap: () => onTap(entity),
      leading: ClipOval(
        child: Converter.convertToImage(
          entity.mainUser.image, //TODO: CHANGE THIS
          size: 60,
          fit: BoxFit.cover,
          placeHolder: CircleAvatar(
            radius: 30,
          ),
        ),
      ),
      subtitle: lastMessage == null
          ? null
          : Text(
              lastMessage,
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
      title: Row(
        // mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            entity.peers.values.map((e) => e.name).join(', '), //FIXME: FIX THIS
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
          Spacer(),
          Text(
            lastTime,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          Icon(
            Icons.keyboard_arrow_right,
            color: Colors.black87,
          ),
        ],
      ),
    );
  }
}
