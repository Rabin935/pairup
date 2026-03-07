import 'package:equatable/equatable.dart';
import 'package:pairup/features/chat/domain/entities/chat_entities.dart';

enum ChatStatus { initial, loading, loaded, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final ChatOverviewEntity overview;
  final String? errorMessage;
  final List<String> processingRequestKeys;

  const ChatState({
    this.status = ChatStatus.initial,
    this.overview = ChatOverviewEntity.empty,
    this.errorMessage,
    this.processingRequestKeys = const [],
  });

  ChatState copyWith({
    ChatStatus? status,
    ChatOverviewEntity? overview,
    String? errorMessage,
    List<String>? processingRequestKeys,
    bool clearErrorMessage = false,
  }) {
    return ChatState(
      status: status ?? this.status,
      overview: overview ?? this.overview,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      processingRequestKeys:
          processingRequestKeys ?? this.processingRequestKeys,
    );
  }

  @override
  List<Object?> get props => [
    status,
    overview,
    errorMessage,
    processingRequestKeys,
  ];
}
