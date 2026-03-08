import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pairup/core/api/api_client.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/core/services/storage/user_session_service.dart';
import 'package:pairup/features/auth/domain/entities/auth_entity.dart';
import 'package:pairup/features/auth/domain/repositories/auth_repository.dart';
import 'package:pairup/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:pairup/features/auth/domain/usecases/login_usecase.dart';
import 'package:pairup/features/auth/domain/usecases/logout_usecase.dart';
import 'package:pairup/features/auth/domain/usecases/register_usecase.dart';
import 'package:pairup/features/chat/data/services/socket_service.dart';
import 'package:pairup/features/chat/domain/entities/chat_entities.dart';
import 'package:pairup/features/chat/domain/repositories/chat_repository.dart';
import 'package:pairup/features/chat/domain/usecases/get_chat_overview_usecase.dart';
import 'package:pairup/features/notification/domain/entities/notification_entities.dart';
import 'package:pairup/features/notification/domain/repositories/notification_repository.dart';
import 'package:pairup/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:pairup/features/notification/domain/usecases/respond_notification_usecase.dart';
import 'package:pairup/features/sensor/domain/entities/sensor_vector_entity.dart';
import 'package:pairup/features/sensor/domain/repositories/motion_sensor_repository.dart';
import 'package:pairup/features/user/domain/entities/public_user_profile_entity.dart';
import 'package:pairup/features/user/domain/entities/upload_user_images_result_entity.dart';
import 'package:pairup/features/user/domain/entities/user_entities.dart';
import 'package:pairup/features/user/domain/entities/user_image_like_result_entity.dart';
import 'package:pairup/features/user/domain/repositories/public_user_profile_repository.dart';
import 'package:pairup/features/user/domain/repositories/user_media_repository.dart';
import 'package:pairup/features/user/domain/repositories/user_repository.dart';
import 'package:pairup/features/user/domain/usecases/create_user_usecase.dart';
import 'package:pairup/features/user/domain/usecases/delete_user_usecase.dart';
import 'package:pairup/features/user/domain/usecases/get_all_user_usecase.dart';
import 'package:pairup/features/user/domain/usecases/get_public_user_profile_usecase.dart';
import 'package:pairup/features/user/domain/usecases/get_user_by_id_usecase.dart';
import 'package:pairup/features/user/domain/usecases/toggle_user_image_like_usecase.dart';
import 'package:pairup/features/user/domain/usecases/update_user_usecase.dart';
import 'package:pairup/features/user/domain/usecases/upload_user_images_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockUserRepository extends Mock implements IUserRepository {}

class MockPublicUserProfileRepository extends Mock
    implements IPublicUserProfileRepository {}

class MockUserMediaRepository extends Mock implements IUserMediaRepository {}

class MockChatRepository extends Mock implements IChatRepository {}

class MockNotificationRepository extends Mock implements INotificationRepository {}

class MockMotionSensorRepository extends Mock implements IMotionSensorRepository {}

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

class MockGetAllUserUsecase extends Mock implements GetAllUserUsecase {}

class MockCreateUserUsecase extends Mock implements CreateUserUsecase {}

class MockUpdateUserUsecase extends Mock implements UpdateUserUsecase {}

class MockDeleteUserUsecase extends Mock implements DeleteUserUsecase {}

class MockGetUserByIdUsecase extends Mock implements GetUserByIdUsecase {}

class MockGetChatOverviewUsecase extends Mock implements GetChatOverviewUsecase {}

class MockGetNotificationsUsecase extends Mock implements GetNotificationsUsecase {}

class MockRespondNotificationUsecase extends Mock
    implements RespondNotificationUsecase {}

class MockUploadUserImagesUsecase extends Mock
    implements UploadUserImagesUsecase {}

class MockGetPublicUserProfileUsecase extends Mock
    implements GetPublicUserProfileUsecase {}

class MockToggleUserImageLikeUsecase extends Mock
    implements ToggleUserImageLikeUsecase {}

class MockUserSessionService extends Mock implements UserSessionService {}

class MockApiClient extends Mock implements ApiClient {}

class MockChatSocketService extends Mock implements ChatSocketService {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void registerCommonFallbackValues() {
  registerFallbackValue(
    const AuthEntity(
      firstname: 'Test',
      lastname: 'User',
      email: 'test@pairup.app',
      password: 'password123',
    ),
  );
  registerFallbackValue(const LoginUsecaseParams(email: 'e', password: 'p'));
  registerFallbackValue(
    const RegisterUsecaseParams(
      firstname: 'Test',
      lastname: 'User',
      email: 'test@pairup.app',
      password: 'password123',
      age: 21,
      gender: 'female',
      phoneNumber: '+1234567890',
    ),
  );
  registerFallbackValue(const CreateUserUsecaseParams(name: 'Test User'));
  registerFallbackValue(const DeleteUserUsecaseParams(userId: 'user-1'));
  registerFallbackValue(
    const GetUserByIdUsecaseParams(userId: 'user-1'),
  );
  registerFallbackValue(
    const UpdateUserUsecaseParams(userId: 'user-1', name: 'Updated User'),
  );
  registerFallbackValue(
    const GetPublicUserProfileUsecaseParams(userId: 'user-1'),
  );
  registerFallbackValue(
    const ToggleUserImageLikeUsecaseParams(userId: 'user-1', imageId: 'img-1'),
  );
  registerFallbackValue(
    const GetChatOverviewUsecaseParams(currentUserId: 'user-1'),
  );
  registerFallbackValue(
    NotificationItemEntity(
      id: 'n-1',
      type: NotificationItemType.like,
      fromUserId: 'u-2',
      name: 'Sam',
      message: 'liked your profile',
    ),
  );
  registerFallbackValue(NotificationItemAction.accept);
  registerFallbackValue(
    RespondNotificationUsecaseParams(
      notification: NotificationItemEntity(
        id: 'n-1',
        type: NotificationItemType.like,
        fromUserId: 'u-2',
        name: 'Sam',
      ),
      action: NotificationItemAction.accept,
    ),
  );
  registerFallbackValue(
    MatchRequestEntity(
      id: 'mr-1',
      type: MatchRequestType.like,
      senderId: 'u-2',
      participantId: 'u-2',
      name: 'Sam',
    ),
  );
  registerFallbackValue(
    Response(
      requestOptions: RequestOptions(path: '/'),
      data: <String, dynamic>{},
      statusCode: 200,
    ),
  );
  registerFallbackValue(<String, dynamic>{});
  registerFallbackValue(const SocketEventHandlers());
  registerFallbackValue(
    const SensorVectorEntity(x: 1, y: 1, z: 1),
  );
  registerFallbackValue(const <String>[]);
  registerFallbackValue(
    const UploadUserImagesUsecaseParams(imageFilePaths: <String>['a.jpg']),
  );
  registerFallbackValue(
    const UploadUserImagesResultEntity(imageUrls: <String>[]),
  );
  registerFallbackValue(
    const UserImageLikeResultEntity(
      userId: 'user-1',
      imageId: 'img-1',
      liked: true,
      likesCount: 1,
    ),
  );
  registerFallbackValue(
    const PublicUserProfileEntity(
      id: 'profile-1',
      uid: 'user-1',
      firstname: 'Test',
      lastname: 'User',
      age: 25,
      location: 'NYC',
      bio: 'bio',
      interests: <String>['music'],
      profileImage: '',
      images: <PublicUserImageEntity>[],
      isOwnProfile: false,
      lastSeen: null,
      views: 1,
      likes: 1,
      matches: 1,
    ),
  );
  registerFallbackValue(
    const UserEntity(
      name: 'Test User',
      email: 'test@pairup.app',
      age: 25,
      gender: 'female',
      bio: 'bio',
      interests: <String>['music'],
      photos: <String>['photo.jpg'],
      location: 'NYC',
    ),
  );
}

Either<Failure, T> rightResult<T>(T value) => Right(value);

Either<Failure, T> leftResult<T>(String message) =>
    Left(ApiFailure(message: message));
