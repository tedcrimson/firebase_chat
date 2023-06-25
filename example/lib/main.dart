import 'package:firebase_chat/firebase_chat.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import 'package:draw_page/draw_page.dart';
import 'package:flutter/foundation.dart';
import 'package:camera_capture/camera_capture.dart';
// import 'dart:convert';
// import 'dart:html' as html;
// import 'package:file_picker_web/file_picker_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Firebase Chat Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, PeerUser> peers = {
    'myId': PeerUser(id: 'myId', name: 'Grievous'),
    'otherId': PeerUser(
        id: 'otherId',
        name: 'Kenobi',
        image:
            'https://cdn.vox-cdn.com/thumbor/SRwHbaTMxPr4f8EJdfai_UR2y34=/1400x1050/filters:format(jpeg)/cdn.vox-cdn.com/uploads/chorus_asset/file/6434955/obi-wan.0.jpg'),
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ChatPage(
          entity: ChatEntity(
            mainUser: peers['myId'],
            peers: peers,
            path: 'Chats/chatId',
            title: peers['otherId'].name, // ALSO: 'Group Name',
          ),
        ));
  }
}

class ChatPage extends BaseChat {
  ChatPage({
    @required ChatEntity entity,
  }) : super(entity);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends BaseChatState<ChatPage> {
  @override
  Color get primaryColor => Colors.blue;

  @override
  Color get secondaryColor => Colors.blue;

  @override
  Widget get loadingWidget => Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: CircularProgressIndicator(),
        ),
      );

  @override
  Widget get emptyWidget => Center(
          child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Text("Welcome"),
      ));

  @override
  Widget get errorWidget => Center(child: Text("Something wrong"));

  @override
  Future editAndUpload(Uint8List data) async {
    Uint8List edited = await Navigator.of(context)
        .push<Uint8List>(MaterialPageRoute(builder: (BuildContext context) {
      return DrawPage(imageData: data, loadingWidget: loadingWidget);
    }));
    sendImage(edited);
  }

  // Future<Uint8List> _getHtmlFileContent(html.File blob) async {
  //   Uint8List file;
  //   final reader = html.FileReader();
  //   reader.readAsDataUrl(blob.slice(0, blob.size, blob.type));
  //   reader.onLoadEnd.listen((event) {
  //     Uint8List data =
  //         Base64Decoder().convert(reader.result.toString().split(",").last);
  //     file = data;
  //   }).onData((data) {
  //     file = Base64Decoder().convert(reader.result.toString().split(",").last);
  //     return file;
  //   });
  //   while (file == null) {
  //     await new Future.delayed(const Duration(milliseconds: 1));
  //     if (file != null) {
  //       break;
  //     }
  //   }
  //   return file;
  // }

  @override
  Future getImage() async {
    List<Uint8List> images;
    // Coming soon
    // if (kIsWeb) {
    //   var file = await FilePicker.getFile();

    //   if (file != null) {
    //     var g = await _getHtmlFileContent(file);
    //     images = [g];
    //   }
    // } else {
    images = await Navigator.of(context).push<List<Uint8List>>(
        MaterialPageRoute(builder: (BuildContext context) => CameraPage()));
    if (images != null && images.length == 1) {
      Uint8List image = await Navigator.of(context)
          .push<Uint8List>(MaterialPageRoute(builder: (BuildContext context) {
        return DrawPage(imageData: images[0], loadingWidget: loadingWidget);
      }));
      if (image == null) return null;
      images = [image];
      // }
    }

    if (images != null) {
      for (var image in images) {
        await sendImage(image);
      }
    }
  }

  @override
  Widget inputBuilder(BuildContext context, ChatInputState state) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Container(
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  onSubmitted: (text) {
                    if (text.isNotEmpty) sendMessage();
                  },
                  autofocus: false,
                  maxLines: null,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 20.0),
                  controller: textEditingController,
                  onChanged: inputChanged,
                  decoration: InputDecoration.collapsed(
                    hintText: "Type here",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
            if (state is InputEmptyState && !kIsWeb) //doesnt support web yet
              Material(
                child: new Container(
                  child: new IconButton(
                    icon: new Icon(Icons.add_a_photo),
                    onPressed: () => getImage(),
                    color: primaryColor,
                    disabledColor: Colors.grey,
                  ),
                ),
                color: Colors.white,
              ),

            // Send message button
            Material(
              child: new Container(
                margin: new EdgeInsets.only(right: 4.0),
                child: new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: state is ReadyToSendState ? sendMessage : null,
                  color: primaryColor,
                  disabledColor: Colors.grey,
                ),
              ),
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
