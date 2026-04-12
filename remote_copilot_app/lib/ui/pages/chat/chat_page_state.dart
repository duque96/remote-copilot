import 'package:remote_copilot_app/domain/model/conversation_stream_event.dart';
import 'package:remote_copilot_app/domain/model/remote_session_bundle.dart';
import 'package:remote_copilot_app/domain/repositories/remote_copilot_repository.dart';
import 'package:remote_copilot_app/domain/model/workspace_definition.dart';

enum ChatConnectionStatus { connecting, live, disconnected }

class ChatPageState {
  const ChatPageState({
    required this.session,
    required this.conversation,
    required this.messages,
    required this.timelineEvents,
    required this.connectionStatus,
    required this.availableModels,
    required this.selectedModel,
    this.workspace,
    this.isLoading = true,
    this.isSending = false,
    this.errorMessage,
  });

  final WorkspaceDefinition? workspace;
  final RemoteSession session;
  final ConversationThread conversation;
  final List<ConversationMessage> messages;
  final List<ConversationStreamEvent> timelineEvents;
  final ChatConnectionStatus connectionStatus;
  final List<CopilotModelOption> availableModels;
  final String selectedModel;
  final bool isLoading;
  final bool isSending;
  final String? errorMessage;

  ChatPageState copyWith({
    WorkspaceDefinition? workspace,
    RemoteSession? session,
    ConversationThread? conversation,
    List<ConversationMessage>? messages,
    List<ConversationStreamEvent>? timelineEvents,
    ChatConnectionStatus? connectionStatus,
    List<CopilotModelOption>? availableModels,
    String? selectedModel,
    bool? isLoading,
    bool? isSending,
    String? errorMessage,
  }) {
    return ChatPageState(
      workspace: workspace ?? this.workspace,
      session: session ?? this.session,
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      timelineEvents: timelineEvents ?? this.timelineEvents,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      availableModels: availableModels ?? this.availableModels,
      selectedModel: selectedModel ?? this.selectedModel,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage,
    );
  }
}
