import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/core/services/connectivity/network_info.dart';
import 'package:pairup/features/notification/data/datasource/notification_datasource.dart';
import 'package:pairup/features/notification/data/datasource/remote/notification_remote_datasource.dart';
import 'package:pairup/features/notification/domain/entities/notification_entities.dart';
import 'package:pairup/features/notification/domain/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {
  return NotificationRepository(
    remoteDataSource: ref.read(notificationRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class NotificationRepository implements INotificationRepository {
  final INotificationRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  NotificationRepository({
    required INotificationRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<NotificationItemEntity>>>
  getNotifications() async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final models = await _remoteDataSource.getNotifications();
      return Right(models.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      final message = (e.response?.data is Map<String, dynamic>)
          ? ((e.response?.data['message'] as String?) ??
                'Failed to load notifications')
          : (e.message ?? 'Failed to load notifications');
      return Left(
        ApiFailure(message: message, statusCode: e.response?.statusCode),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> respondToNotification({
    required NotificationItemEntity notification,
    required NotificationItemAction action,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      await _remoteDataSource.respondToNotification(
        type: notification.type,
        notificationId: notification.id,
        fromUserId: notification.fromUserId,
        action: action,
      );
      return const Right(unit);
    } on DioException catch (e) {
      final message = (e.response?.data is Map<String, dynamic>)
          ? ((e.response?.data['message'] as String?) ??
                'Failed to update notification')
          : (e.message ?? 'Failed to update notification');
      return Left(
        ApiFailure(message: message, statusCode: e.response?.statusCode),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
