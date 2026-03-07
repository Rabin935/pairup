import 'package:dartz/dartz.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/features/chat/domain/entities/chat_entities.dart';

abstract interface class IChatRepository {
  Future<Either<Failure, ChatOverviewEntity>> getChatOverview({
    required String currentUserId,
  });
}
