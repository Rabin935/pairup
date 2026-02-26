import 'package:pairup/features/auth/domain/entities/auth_entity.dart';
import 'package:pairup/features/chat/domain/entities/chat_entities.dart';
import 'package:pairup/features/notification/domain/entities/notification_entities.dart';
import 'package:pairup/features/sensor/domain/entities/sensor_vector_entity.dart';
import 'package:pairup/features/user/domain/entities/public_user_profile_entity.dart';
import 'package:pairup/features/user/domain/entities/upload_user_images_result_entity.dart';
import 'package:pairup/features/user/domain/entities/user_entities.dart';
import 'package:pairup/features/user/domain/entities/user_image_like_result_entity.dart';

const sampleAuthEntity = AuthEntity(
  userId: 'auth-1',
  firstname: 'Alex',
  lastname: 'Ray',
  email: 'alex@pairup.app',
  password: 'password123',
  age: 25,
  gender: 'male',
  number: '+15550000000',
  bio: 'bio',
  interests: <String>['music'],
  photos: <String>['photo.jpg'],
  location: 'NYC',
);

const sampleUserEntity = UserEntity(
  userId: 'user-1',
  name: 'alex',
  email: 'alex@pairup.app',
  age: 25,
  gender: 'male',
  bio: 'bio',
  interests: <String>['music', 'travel'],
  photos: <String>['photo.jpg'],
  location: 'NYC',
);

const samplePublicProfile = PublicUserProfileEntity(
  id: 'profile-1',
  uid: 'user-1',
  firstname: 'Alex',
  lastname: 'Ray',
  age: 25,
  location: 'NYC',
  bio: 'bio',
  interests: <String>['music'],
  profileImage: '',
  images: <PublicUserImageEntity>[
    PublicUserImageEntity(
      id: 'img-1',
      url: 'https://example.com/a.jpg',
      isThumbnail: true,
      likesCount: 1,
      likedByMe: false,
    ),
  ],
  isOwnProfile: false,
  lastSeen: null,
  views: 5,
  likes: 3,
  matches: 2,
);

const sampleUploadResult = UploadUserImagesResultEntity(
  imageUrls: <String>['https://example.com/photo.jpg'],
);

const sampleImageLikeResult = UserImageLikeResultEntity(
  userId: 'user-1',
  imageId: 'img-1',
  liked: true,
  likesCount: 12,
);

final sampleNotification = NotificationItemEntity(
  id: 'notif-1',
  type: NotificationItemType.like,
  fromUserId: 'user-2',
  name: 'Taylor',
  message: 'liked your profile',
  createdAt: DateTime(2026, 1, 1, 10),
);

final sampleMatchRequest = MatchRequestEntity(
  id: 'req-1',
  type: MatchRequestType.like,
  senderId: 'user-2',
  participantId: 'user-2',
  name: 'Taylor',
  subtitle: 'Liked your profile',
  createdAt: DateTime(2026, 1, 1, 10),
);

const sampleChatUser = ChatUserEntity(id: 'user-2', name: 'Taylor');

final sampleChatThread = ChatThreadEntity(
  id: 'chat-1',
  participant: sampleChatUser,
  lastMessage: 'Hello',
  lastMessageAt: DateTime(2026, 1, 1, 10),
  unreadCount: 2,
);

final sampleChatOverview = ChatOverviewEntity(
  matchRequests: <MatchRequestEntity>[sampleMatchRequest],
  newRequests: const <NewRequestEntity>[
    NewRequestEntity(id: 'nr-1', name: 'Jamie', isOnline: true),
  ],
  chats: <ChatThreadEntity>[sampleChatThread],
);

const sampleGyroscope = SensorVectorEntity(x: 0.2, y: -0.1, z: 0.05);
const sampleAccelerometer = SensorVectorEntity(x: 20, y: 1, z: 1);
