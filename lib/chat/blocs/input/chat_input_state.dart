part of 'chat_input_cubit.dart';

abstract class ChatInputState extends Equatable {
  const ChatInputState();

  @override
  List<Object> get props => [];
}

class InputEmptyState extends ChatInputState {}

class ReadyToSendState extends ChatInputState {
  final String message;
  ReadyToSendState(
    this.message,
  );
}
