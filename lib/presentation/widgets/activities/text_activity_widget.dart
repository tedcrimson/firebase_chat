import 'package:flutter/material.dart';
import 'package:firebase_chat/models.dart';

class TextActivityWidget extends StatelessWidget {
  final TextActivity textActivity;
  final bool isMe;
  const TextActivityWidget({Key key, this.textActivity, this.isMe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // double textMaxWidth = MediaQuery.of(context).size.width * 2 / 3;
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        constraints: BoxConstraints(maxWidth: constraints.maxWidth * 2 / 3),
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Text(
          textActivity.text,
          textAlign: TextAlign.left,
          style: Theme.of(context)
              .textTheme
              .bodyText2
              .copyWith(fontWeight: FontWeight.normal, fontSize: 16, color: isMe ? Colors.white : null),
          // style: TextStyle(
          //     fontSize: 16, color: isMe ? Colors : Colors.black),
        ),
      );
    });
  }
}
