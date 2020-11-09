# Firebase Chat🔥💬

![](https://raw.githubusercontent.com/tedcrimson/firebase_chat/master/resources/preview.gif)

## ⛏️ Getting started

To get started with Firebase, please see the documentation available at https://firebase.flutter.dev/docs/overview

Add **Firebase Chat** to your project by following the instructions on the 
**[install page](https://pub.dev/packages/firebase_chat/install)** and start using it:
```dart
import 'package:firebase_chat/firebase_chat.dart';
```
## 📱 Example
### Extend your StatefulWidget
```dart
class ChatPage extends BaseChat {
  ChatPage({
    @required ChatEntity entity,
  }) : super(entity);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends BaseChatState<ChatPage> {
...
```

### Override Methods and Properties
> You can checkout [example file](https://pub.dev/packages/firebase_chat/example)
```dart
Widget inputBuilder(BuildContext context, ChatInputState state);
Future editAndUpload(Uint8List data);
Future getImage();

Widget get emptyWidget;
Widget get errorWidget;
Widget get loadingWidget;
Color  get primaryColor;
Color  get secondaryColor;
```

## Models 📦
#### Peer User 👨
##### Fields
* `id` - user Id
* `image` - user image url
* `name` - user display name
##### Constructors
* `PeerUser({this.id, this.image, this.name})`
* `PeerUser.fromSnapshot(DocumentSnapshot snap)`

### Chat Entity 📩 
##### Fields
* `mainUser` - logged in user
* `peers` - Map of users `<user ID, PeerUser>`
* `lastMessage` - last sent message
* `title` - name of the chat (You can name group chats, can be `nullable`)




## License ⚖️
- [MIT](https://github.com/tedcrimson/firebase_chat/blob/master/LICENSE)

## Issues and feedback 💭
If you have any suggestion for including a feature or if something doesn't work, feel free to open a Github [issue](https://github.com/fayeed/dash_chat/issues) for us to have a discussion on it.