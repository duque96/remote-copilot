import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:remote_copilot_app/domain/model/conversation_stream_event.dart';
import 'package:remote_copilot_app/domain/model/remote_session_bundle.dart';
import 'package:remote_copilot_app/domain/model/workspace_definition.dart';
import 'package:remote_copilot_app/domain/repositories/remote_copilot_repository.dart';
import 'package:remote_copilot_app/ui/pages/chat/chat_page_state.dart';

class ChatPageController extends ChangeNotifier {
  static const _defaultModel = 'gpt-4.1';
  static const _defaultModelOption = CopilotModelOption(id: _defaultModel, name: _defaultModel);
  static const _maxTimelineEvents = 250;

  ChatPageController({required RemoteCopilotRepository repository, RemoteSessionBundle? sessionBundle, WorkspaceDefinition? workspace})
    : _repository = repository,
      _streamConversationId = sessionBundle?.conversation.id,
      _state = ChatPageState(
        workspace: workspace,
        session: sessionBundle?.session,
        conversation: sessionBundle?.conversation,
        messages: sessionBundle?.conversation.messages ?? const [],
        timelineEvents: const [],
        connectionStatus: sessionBundle == null ? ChatConnectionStatus.disconnected : ChatConnectionStatus.connecting,
        availableModels: const [_defaultModelOption],
        selectedModel: _defaultModel,
      );

  final RemoteCopilotRepository _repository;
  String? _streamConversationId;

  StreamSubscription<ConversationStreamEvent>? _subscription;
  ChatPageState _state;

  ChatPageState get state => _state;

  Future<void> initialize() async {
    try {
      final availableModels = await _repository.getAvailableModels();
      final selectedModel = availableModels.any((item) => item.id == _state.selectedModel)
          ? _state.selectedModel
          : (availableModels.isEmpty
                ? _defaultModel
                : availableModels.firstWhere((item) => item.id == _defaultModel, orElse: () => availableModels.first).id);

      _state = _state.copyWith(
        availableModels: availableModels.isEmpty ? const [_defaultModelOption] : availableModels,
        selectedModel: selectedModel,
        errorMessage: null,
      );

      if (_streamConversationId == null) {
        _state = _state.copyWith(isLoading: false, connectionStatus: ChatConnectionStatus.disconnected);
        notifyListeners();
        return;
      }

      final conversation = await _repository.getConversation(_streamConversationId!);

      _state = _state.copyWith(conversation: conversation, messages: conversation.messages, isLoading: false, errorMessage: null);
      _state = _state.copyWith(session: _state.session);
      notifyListeners();

      await _subscribeToConversation(_streamConversationId!);
    } catch (error) {
      _state = _state.copyWith(isLoading: false, connectionStatus: ChatConnectionStatus.disconnected, errorMessage: error.toString());
      notifyListeners();
    }
  }

  Future<void> sendMessage(String rawContent) async {
    final content = rawContent.trim();
    if (content.isEmpty || _state.isSending) {
      return;
    }

    _state = _state.copyWith(isSending: true, errorMessage: null);
    notifyListeners();

    try {
      final conversationId = await _ensureConversation();
      if (conversationId == null) {
        _state = _state.copyWith(isSending: false, errorMessage: 'Unable to create a conversation.');
        notifyListeners();
        return;
      }

      final response = await _repository.sendMessage(conversationId: conversationId, content: content, model: _state.selectedModel);

      final updatedMessages = [..._state.messages];
      _upsertMessage(updatedMessages, response.userMessage);
      _upsertMessage(updatedMessages, response.assistantMessage);

      _state = _state.copyWith(session: response.session, conversation: response.conversation, messages: updatedMessages, isSending: false);
      notifyListeners();
    } catch (error) {
      _state = _state.copyWith(isSending: false, errorMessage: error.toString());
      notifyListeners();
    }
  }

  void selectModel(String model) {
    final trimmed = model.trim();
    if (trimmed.isEmpty || trimmed == _state.selectedModel) {
      return;
    }

    _state = _state.copyWith(selectedModel: trimmed);
    notifyListeners();
  }

  Future<String?> _ensureConversation() async {
    if (_streamConversationId != null) {
      return _streamConversationId;
    }

    final bundle = await _repository.createSession(workspaceId: _state.workspace?.id);
    _streamConversationId = bundle.conversation.id;
    _state = _state.copyWith(
      session: bundle.session,
      conversation: bundle.conversation,
      messages: bundle.conversation.messages,
      connectionStatus: ChatConnectionStatus.connecting,
      errorMessage: null,
    );
    notifyListeners();

    await _subscribeToConversation(_streamConversationId!);
    return _streamConversationId;
  }

  Future<void> _subscribeToConversation(String conversationId) async {
    await _subscription?.cancel();
    _subscription = _repository
        .streamConversation(conversationId)
        .listen(
          _handleStreamEvent,
          onError: (Object error) {
            _state = _state.copyWith(connectionStatus: ChatConnectionStatus.disconnected, isSending: false, errorMessage: error.toString());
            notifyListeners();
          },
        );

    _state = _state.copyWith(connectionStatus: ChatConnectionStatus.live);
    notifyListeners();
  }

  void _handleStreamEvent(ConversationStreamEvent event) {
    final nextTimelineEvents = [..._state.timelineEvents, event];
    if (nextTimelineEvents.length > _maxTimelineEvents) {
      nextTimelineEvents.removeRange(0, nextTimelineEvents.length - _maxTimelineEvents);
    }

    final updatedMessages = [..._state.messages];
    final messageId = event.messageId;
    final existingIndex = messageId == null ? -1 : updatedMessages.indexWhere((item) => item.id == messageId);
    var nextState = _state;

    switch (event.type) {
      case 'assistant.turn_start':
        nextState = nextState.copyWith(isSending: true);
        if (messageId != null && existingIndex == -1) {
          updatedMessages.add(
            ConversationMessage(
              id: messageId,
              conversationId: event.conversationId,
              role: 'assistant',
              content: '',
              status: 'streaming',
              sequence: updatedMessages.length + 1,
              createdAt: event.timestamp,
              updatedAt: event.timestamp,
            ),
          );
        }
        break;

      case 'assistant.message_delta':
        final delta = _readEventDataString(event, 'deltaContent');
        if (messageId == null || delta == null || delta.isEmpty) {
          break;
        }

        if (existingIndex != -1) {
          final existing = updatedMessages[existingIndex];
          updatedMessages[existingIndex] = existing.copyWith(content: '${existing.content}$delta', status: 'streaming', updatedAt: event.timestamp);
        } else {
          updatedMessages.add(
            ConversationMessage(
              id: messageId,
              conversationId: event.conversationId,
              role: 'assistant',
              content: delta,
              status: 'streaming',
              sequence: updatedMessages.length + 1,
              createdAt: event.timestamp,
              updatedAt: event.timestamp,
            ),
          );
        }
        break;

      case 'assistant.message':
        final content = _readEventDataString(event, 'content');
        if (messageId == null) {
          break;
        }

        if (existingIndex != -1) {
          updatedMessages[existingIndex] = updatedMessages[existingIndex].copyWith(
            content: content ?? updatedMessages[existingIndex].content,
            status: 'completed',
            updatedAt: event.timestamp,
          );
        } else {
          updatedMessages.add(
            ConversationMessage(
              id: messageId,
              conversationId: event.conversationId,
              role: 'assistant',
              content: content ?? '',
              status: 'completed',
              sequence: updatedMessages.length + 1,
              createdAt: event.timestamp,
              updatedAt: event.timestamp,
            ),
          );
        }
        break;

      case 'session.error':
        nextState = nextState.copyWith(isSending: false, errorMessage: _readEventDataString(event, 'message'));
        if (existingIndex != -1) {
          updatedMessages[existingIndex] = updatedMessages[existingIndex].copyWith(
            content: _readEventDataString(event, 'content') ?? updatedMessages[existingIndex].content,
            status: 'failed',
            error: _readEventDataString(event, 'message'),
            updatedAt: event.timestamp,
          );
        }
        break;

      case 'assistant.turn_end':
      case 'session.idle':
        nextState = nextState.copyWith(isSending: false);
        if (existingIndex != -1 && updatedMessages[existingIndex].status == 'streaming') {
          updatedMessages[existingIndex] = updatedMessages[existingIndex].copyWith(status: 'completed', updatedAt: event.timestamp);
        }
        break;
    }

    updatedMessages.sort((left, right) => left.sequence.compareTo(right.sequence));
    _state = nextState.copyWith(messages: updatedMessages, timelineEvents: nextTimelineEvents);
    notifyListeners();
  }

  String? _readEventDataString(ConversationStreamEvent event, String key) {
    final value = event.data?[key];
    if (value is String) {
      return value;
    }

    return value?.toString();
  }

  void _upsertMessage(List<ConversationMessage> messages, ConversationMessage message) {
    final index = messages.indexWhere((item) => item.id == message.id);
    if (index == -1) {
      messages.add(message);
    } else {
      messages[index] = message;
    }
    messages.sort((left, right) => left.sequence.compareTo(right.sequence));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
