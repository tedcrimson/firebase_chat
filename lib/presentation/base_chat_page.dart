import 'dart:async';

import 'package:firebase_chat/cubit/chat_input_cubit.dart';
import 'package:firebase_chat/models.dart';
import 'package:firebase_chat/models/firestore_repository.dart';
import 'package:firebase_chat/pagination/pagination.dart';
import 'package:firebase_chat/presentation/widgets/chat_content.dart';
import 'package:firebase_chat/presentation/widgets/typing/typing_section.dart';
import 'package:firebase_chat/repositories/activity_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_previewer/gallery_previewer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

abstract class BaseChat extends StatefulWidget {
  // final ActivityRepository activityRepository;

  BaseChat(this.entity);

  final ChatEntity entity;

  static BaseChatState of(BuildContext context) {
    return context.findAncestorStateOfType<BaseChatState>();
  }
}

abstract class BaseChatState<T extends BaseChat> extends State<BaseChat> {
  // Color randomColor = Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(1.0);
  ActivityRepository activityRepository;

  ChatEntity entity;
  List<GalleryViewItem> images;
  final ScrollController listScrollController = new ScrollController();
  int messageLimit = 20;
  Query query;
  final TextEditingController textEditingController =
      new TextEditingController();

  ChatInputCubit _chatInputCubit;
  // String userId;

  StreamSubscription _imagesSubscription;

  @override
  void dispose() {
    super.dispose();
    _chatInputCubit.close();
    _imagesSubscription.cancel();
  }

  @override
  void initState() {
    super.initState();
    entity = widget.entity;

    activityRepository = ActivityRepository(entity.path);

    _chatInputCubit = ChatInputCubit(
      userId: entity.mainUser.id,
      activityRepository: activityRepository,
      textController: textEditingController,
      scrollController: listScrollController,
    );

    // Chat.currentChatPath = widget.path;

    FirestoreRepository fire;
    try {
      fire = context.read<FirestoreRepository>();
    } catch (e) {
      fire = FirestoreRepository();
    }
    query = fire.getQuery([...entity.path.split('/'), 'Activity'],
        limit: messageLimit).orderBy('timestamp', descending: true);

    images = [];

    _imagesSubscription = activityRepository
        .getChatImages(activityRepository.reference)
        .listen((onData) {
      bool init = onData.docChanges.length > 1;
      for (var snap in onData.docChanges) {
        switch (snap.type) {
          case DocumentChangeType.added:
            ImageActivity imageData = ImageActivity.fromSnapshot(snap.doc);
            var view = GalleryViewItem(
              id: imageData.documentId,
              url: imageData.imagePath,
              thumbnail: imageData.thumbPath,
            );
            if (init) {
              images.add(view);
            } else
              images.insert(0, view);
            // images.sort((a, b) => a.timestamp.compareTo(b.timestamp));
            break;
          case DocumentChangeType.modified:
            print("OK");
            // ImageActivity imageData = ImageActivity.fromSnapshot(snap.document);
            // int i = images.indexWhere((x) => x.id == snap.document.documentID);
            // images[i] = GalleryExampleItem(
            //     id: imageData.documentID,
            //     url: imageData.imagePath,
            //     thumbnail: imageData.thumbPath);
            break;
          case DocumentChangeType.removed:
            images.removeWhere((x) => x.id == snap.doc.id);
            break;
        }
      }
    });
  }

  Widget get emptyWidget;

  Widget get errorWidget;

  FutureOr<ActivityLog> dataToModel(DocumentSnapshot snap) {
    ActivityLog activity = ActivityLog.fromSnapshot(snap);

    switch (activity.activityStatus) {
      case ActivityStatus.Text:
        return TextActivity.fromSnapshot(snap);
      case ActivityStatus.Image:
        return ImageActivity.fromSnapshot(snap);
    }
    return activity;
  }

  Future getImage();

  Future editAndUpload(Uint8List data);

  Widget buildItem(int i, List<ActivityLog> messages) {
    var activity = messages[i];
    var userId = activity.userId;
    return ChatActivityWidget(
      activityLog: activity,
      i: i,
      listMessage: messages,
      userId: entity.mainUser.id,
      peer: entity.peers[userId],
      images: images,
      activityRepository: activityRepository,
      loadingWidget: loadingWidget,
      primaryColor: primaryColor,
    );
  }

  Widget _buildMessageList() {
    return PaginationList<ActivityLog>(
      arguments: PaginationArgs<ActivityLog>(
        query: query,
        converter: dataToModel,
        loadingWidget: loadingWidget,
        limit: messageLimit,
        scrollController: listScrollController,
        reverse: true,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        buildItem: (context, state, index) => buildItem(index, state.data),
        onInitial: (context, state) => Center(child: loadingWidget),
        onFailure: (context, state) => errorWidget,
        onEmpty: (context, state) => emptyWidget,
      ),
    );
  }

  Widget _buildTyping() {
    return TypingSection(
      userId: entity.mainUser.id,
      activityRepository: activityRepository,
      peers: entity.peers,
      color: secondaryColor,
    );
  }

  @mustCallSuper
  void inputChanged(String value) {
    _chatInputCubit.inputChanged(value);
  }

  @mustCallSuper
  void sendMessage() {
    _chatInputCubit.sendMessage();
  }

  @mustCallSuper
  Future<bool> sendImage(dynamic image) {
    return _chatInputCubit.sendImage(image);
  }

  Widget get loadingWidget;

  Color get primaryColor;
  Color get secondaryColor;

  Widget _buildInput() {
    return BlocBuilder<ChatInputCubit, ChatInputState>(
        bloc: _chatInputCubit, builder: inputBuilder);
  }

  Widget inputBuilder(BuildContext context, ChatInputState state);

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        // List of messages
        Flexible(
          child: SingleChildScrollView(
              controller: listScrollController,
              reverse: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMessageList(),
                  _buildTyping(),
                ],
              )),
        ),
        // Input content
        _buildInput(),
      ],
    );
  }
}
