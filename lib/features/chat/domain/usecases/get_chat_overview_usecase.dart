import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/core/usecases/app_usecase.dart';
import 'package:pairup/features/chat/data/repositories/chat_repository.dart';
import 'package:pairup/features/chat/domain/entities/chat_entities.dart';
import 'package:pairup/features/chat/domain/repositories/chat_repository.dart';

class GetChatOverviewUsecaseParams extends Equatable {
  final String currentUserId;

  const GetChatOverviewUsecaseParams({required this.currentUserId});

  @override
  List<Object?> get props => [currentUserId];
}

final getChatOverviewUsecaseProvider = Provider<GetChatOverviewUsecase>((ref) {
  return GetChatOverviewUsecase(
    chatRepository: ref.read(chatRepositoryProvider),
  );
});

class GetChatOverviewUsecase
    implements
        UsecaseWithParams<ChatOverviewEntity, GetChatOverviewUsecaseParams> {
  final IChatRepository _chatRepository;

  GetChatOverviewUsecase({required IChatRepository chatRepository})
    : _chatRepository = chatRepository;

  @override
  Future<Either<Failure, ChatOverviewEntity>> call(
    GetChatOverviewUsecaseParams params,
  ) {
    return _chatRepository.getChatOverview(currentUserId: params.currentUserId);
  }
}
