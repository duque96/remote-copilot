import 'package:remote_copilot_app/domain/model/conversation_stream_event.dart';
import 'package:remote_copilot_app/domain/model/health_snapshot.dart';
import 'package:remote_copilot_app/domain/model/remote_session_bundle.dart';
import 'package:remote_copilot_app/domain/model/workspace_definition.dart';

abstract class RemoteCopilotRepository {
  String get baseUrl;

  set baseUrl(String value);

  Future<HealthSnapshot> getHealth();

  Future<List<CopilotModelOption>> getAvailableModels();

  Future<List<WorkspaceDefinition>> getWorkspaces();

  Future<List<WorkspaceDefinition>> syncWorkspaces();

  Future<WorkspaceDefinition> createWorkspace({required String name});

  Future<WorkspaceDefinition> updateWorkspace({required String workspaceId, required String name});

  Future<WorkspaceDefinition> deleteWorkspace({required String workspaceId});

  Future<RemoteSessionBundle> createSession({String? workspaceId, String? title});

  Future<List<RemoteSession>> listSessions({String? workspaceId});

  Future<RemoteSessionBundle> getSession(String sessionId);

  Future<void> deleteSession(String sessionId);

  Future<ConversationThread> getConversation(String conversationId);

  Future<SendMessageResponse> sendMessage({required String conversationId, required String content, String? model});

  Stream<ConversationStreamEvent> streamConversation(String conversationId);
}

class CopilotModelOption {
  const CopilotModelOption({required this.id, required this.name, this.multiplier});

  factory CopilotModelOption.fromJson(Map<String, dynamic> json) {
    final rawMultiplier = json['multiplier'];
    final parsedMultiplier = switch (rawMultiplier) {
      num value => value.toDouble(),
      String value => double.tryParse(value),
      _ => null,
    };

    return CopilotModelOption(id: (json['id'] ?? '').toString(), name: ((json['name'] ?? json['id']) ?? '').toString(), multiplier: parsedMultiplier);
  }

  final String id;
  final String name;
  final double? multiplier;
}

class SendMessageResponse {
  const SendMessageResponse({required this.session, required this.conversation, required this.userMessage, required this.assistantMessage});

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    return SendMessageResponse(
      session: RemoteSession.fromJson(json['session'] as Map<String, dynamic>),
      conversation: ConversationThread.fromJson(json['conversation'] as Map<String, dynamic>),
      userMessage: ConversationMessage.fromJson(json['userMessage'] as Map<String, dynamic>),
      assistantMessage: ConversationMessage.fromJson(json['assistantMessage'] as Map<String, dynamic>),
    );
  }

  final RemoteSession session;
  final ConversationThread conversation;
  final ConversationMessage userMessage;
  final ConversationMessage assistantMessage;
}
