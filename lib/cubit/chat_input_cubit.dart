import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_chat/repositories/activity_repository.dart';
import 'package:flutter/material.dart';

import 'package:firebase_chat/models.dart';
part 'chat_input_state.dart';

class ChatInputCubit extends Cubit<ChatInputState> {
  ChatInputCubit({
    @required this.userId,
    @required this.activityRepository,
    @required this.textController,
    this.scrollController,
  }) : super(InputEmptyState());
  final ActivityRepository activityRepository;
  // final PaginationBloc paginationBloc;
  final TextEditingController textController;
  final ScrollController scrollController;
  final String userId;

  @override
  Future<void> close() {
    activityRepository.setTyping(userId, false);
    return super.close();
  }

  void inputChanged(String input) {
    // return;
    if (input.isEmpty) {
      emit(InputEmptyState());

      activityRepository.setTyping(userId, false);
    } else {
      if (!(state is ReadyToSendState))
        activityRepository.setTyping(userId, true);
      emit(ReadyToSendState(input));
    }
  }

  Future<bool> sendImage(Uint8List imageFile) async {
    if (imageFile == null) return false;
    var docReference = activityRepository.createActivityReference();
    var fileName = docReference.path.replaceAll(new RegExp(r'/'), '!');

    var url = await activityRepository.uploadData(fileName, imageFile);
    var activity = ImageActivity(userId: userId, imagePath: url);
    await activityRepository.addActivity(docReference, activity);
    return true;
  }

  void sendMessage() async {
    if (state is ReadyToSendState) {
      // ReadyToSendState readtState = state;
      var text = textController.text;
      textController.clear();
      emit(InputEmptyState());

      var docReference = activityRepository.createActivityReference();

      activityRepository.setTyping(userId, false);
      ActivityLog activity = TextActivity(userId: userId, text: text);
      activityRepository.addActivity(docReference, activity);

      if (scrollController != null)
        scrollController.animateTo(0.0,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }
}
