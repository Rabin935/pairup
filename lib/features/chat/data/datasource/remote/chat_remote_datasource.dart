import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/api/api_client.dart';
import 'package:pairup/core/api/api_endpoint.dart';
import 'package:pairup/features/chat/data/datasource/chat_datasource.dart';
import 'package:pairup/features/chat/data/models/chat_api_models.dart';

final chatRemoteDataSourceProvider = Provider<IChatRemoteDataSource>((ref) {
  return ChatRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

class ChatRemoteDataSource implements IChatRemoteDataSource {
  final ApiClient _apiClient;

  ChatRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<ChatOverviewApiModel> getChatOverview({
    required String currentUserId,
  }) async {
    final responses = await Future.wait<Response<dynamic>?>([
      _safeGet(ApiEndpoints.conversations),
      _safeGet(ApiEndpoints.matches),
      _safeGet(ApiEndpoints.pendingLikes),
      _safeGet(ApiEndpoints.pendingInvites),
    ]);

    if (responses.every((item) => item == null)) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.conversations),
        message: 'Unable to load chat overview',
      );
    }

    final chatThreads = _parseConversations(
      payload: responses[0]?.data,
      currentUserId: currentUserId,
    );
    final newRequests = _parseNewRequests(responses[1]?.data);

    final likeRequests = _parseLikeRequests(responses[2]?.data);
    final inviteRequests = _parseInviteRequests(responses[3]?.data);

    return ChatOverviewApiModel(
      matchRequests: [...likeRequests, ...inviteRequests],
      newRequests: newRequests,
      chats: chatThreads,
    );
  }

  Future<Response<dynamic>?> _safeGet(String path) async {
    try {
      return await _apiClient.get(path);
    } catch (_) {
      return null;
    }
  }

  List<ChatThreadApiModel> _parseConversations({
    required dynamic payload,
    required String currentUserId,
  }) {
    final body = payload is Map<String, dynamic>
        ? payload
        : const <String, dynamic>{};
    final source = body['conversations'];
    final rows = _readMapList(source);

    return rows
        .map(
          (row) =>
              ChatThreadApiModel.fromJson(row, currentUserId: currentUserId),
        )
        .where((item) => item.id.isNotEmpty)
        .toList();
  }

  List<NewRequestApiModel> _parseNewRequests(dynamic payload) {
    final body = payload is Map<String, dynamic>
        ? payload
        : const <String, dynamic>{};
    final source = body['matches'];
    final rows = _readMapList(source);

    return rows
        .map(NewRequestApiModel.fromJson)
        .where((item) => item.id.isNotEmpty)
        .toList();
  }

  List<MatchRequestApiModel> _parseLikeRequests(dynamic payload) {
    final body = payload is Map<String, dynamic>
        ? payload
        : const <String, dynamic>{};
    final source = body['likes'];
    final rows = _readMapList(source);

    return rows
        .map(MatchRequestApiModel.fromLikeJson)
        .where((item) => item.id.isNotEmpty)
        .toList();
  }

  List<MatchRequestApiModel> _parseInviteRequests(dynamic payload) {
    final body = payload is Map<String, dynamic>
        ? payload
        : const <String, dynamic>{};
    final source = body['invitations'];
    final rows = _readMapList(source);

    return rows
        .map(MatchRequestApiModel.fromInviteJson)
        .where((item) => item.id.isNotEmpty)
        .toList();
  }
}

List<Map<String, dynamic>> _readMapList(dynamic value) {
  if (value is List<dynamic>) {
    return value.whereType<Map<String, dynamic>>().toList();
  }
  return const [];
}
