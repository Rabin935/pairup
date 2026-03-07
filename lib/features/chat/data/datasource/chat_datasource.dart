import 'package:pairup/features/chat/data/models/chat_api_models.dart';

abstract interface class IChatRemoteDataSource {
  Future<ChatOverviewApiModel> getChatOverview({required String currentUserId});
}
