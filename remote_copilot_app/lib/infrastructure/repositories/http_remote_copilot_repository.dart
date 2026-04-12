import 'package:remote_copilot_app/domain/model/conversation_stream_event.dart';
import 'package:remote_copilot_app/domain/model/health_snapshot.dart';
import 'package:remote_copilot_app/domain/model/remote_session_bundle.dart';
import 'package:remote_copilot_app/domain/model/workspace_definition.dart';
import 'package:remote_copilot_app/domain/repositories/remote_copilot_repository.dart';
import 'package:remote_copilot_app/infrastructure/services/api_client.dart';

class HttpRemoteCopilotRepository implements RemoteCopilotRepository {
  HttpRemoteCopilotRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  String get baseUrl => _apiClient.baseUrl;

  @override
  set baseUrl(String value) => _apiClient.baseUrl = value;

  @override
  Future<RemoteSessionBundle> createSession({String? workspaceId, String? title}) async {
    final json = await _apiClient.postJson('/api/sessions', {
      if (workspaceId != null && workspaceId.isNotEmpty) 'workspaceId': workspaceId,
      if (title != null && title.isNotEmpty) 'title': title,
    });

    return RemoteSessionBundle.fromJson(json);
  }

  @override
  Future<ConversationThread> getConversation(String conversationId) async {
    final json = await _apiClient.getJson('/api/conversations/$conversationId');
    return ConversationThread.fromJson(json);
  }

  @override
  Future<HealthSnapshot> getHealth() async {
    final json = await _apiClient.getJson('/api/health');
    return HealthSnapshot.fromJson(json);
  }

  @override
  Future<List<CopilotModelOption>> getAvailableModels() async {
    final json = await _apiClient.getJsonList('/api/container/models');
    final models = json
        .map((item) => item as Map<String, dynamic>)
        .map(CopilotModelOption.fromJson)
        .where((item) => item.id.trim().isNotEmpty)
        .fold<Map<String, CopilotModelOption>>({}, (map, model) {
          map[model.id] = model;
          return map;
        })
        .values
        .toList();

    models.sort((left, right) => left.id.compareTo(right.id));
    return models;
  }

  @override
  Future<List<WorkspaceDefinition>> getWorkspaces() async {
    final json = await _apiClient.getJsonList('/api/workspaces');
    return json.map((item) => WorkspaceDefinition.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<SendMessageResponse> sendMessage({required String conversationId, required String content, String? model}) async {
    final json = await _apiClient.postJson('/api/conversations/$conversationId/messages', {
      'content': content,
      if (model != null && model.trim().isNotEmpty) 'model': model.trim(),
    });

    return SendMessageResponse.fromJson(json);
  }

  @override
  Stream<ConversationStreamEvent> streamConversation(String conversationId) {
    return _apiClient.openConversationStream(conversationId);
  }
}
