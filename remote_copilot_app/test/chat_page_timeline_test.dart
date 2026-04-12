import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remote_copilot_app/domain/model/conversation_stream_event.dart';
import 'package:remote_copilot_app/domain/model/health_snapshot.dart';
import 'package:remote_copilot_app/domain/model/remote_session_bundle.dart';
import 'package:remote_copilot_app/domain/model/workspace_definition.dart';
import 'package:remote_copilot_app/domain/repositories/remote_copilot_repository.dart';
import 'package:remote_copilot_app/l10n/app_localizations.dart';
import 'package:remote_copilot_app/ui/components/animated_text_sheen.dart';
import 'package:remote_copilot_app/ui/pages/chat/chat_page.dart';
import 'package:remote_copilot_app/ui/pages/chat/widgets/assistant_message_activity.dart';

void main() {
  test('assistant activity builds natural summaries', () {
    final activity = AssistantMessageActivity.fromEvents(
      events: [
        ConversationStreamEvent(
          type: 'tool.execution_start',
          conversationId: 'conversation-1',
          timestamp: DateTime.utc(2026, 4, 12, 10, 0),
          messageId: 'assistant-1',
          data: {'toolName': 'grep_search', 'query': 'message models'},
        ),
        ConversationStreamEvent(
          type: 'skill.invoked',
          conversationId: 'conversation-1',
          timestamp: DateTime.utc(2026, 4, 12, 10, 0, 1),
          messageId: 'assistant-1',
          data: {'skillName': 'flutter-architecture-general'},
        ),
        ConversationStreamEvent(
          type: 'tool.execution_complete',
          conversationId: 'conversation-1',
          timestamp: DateTime.utc(2026, 4, 12, 10, 0, 2),
          messageId: 'assistant-1',
          data: {'toolName': 'read_file', 'filePath': 'lib/ui/pages/chat/chat_page.dart'},
        ),
        ConversationStreamEvent(
          type: 'permission.requested',
          conversationId: 'conversation-1',
          timestamp: DateTime.utc(2026, 4, 12, 10, 0, 3),
          messageId: 'assistant-1',
          data: {'fullCommandText': 'git status'},
        ),
        ConversationStreamEvent(
          type: 'permission.completed',
          conversationId: 'conversation-1',
          timestamp: DateTime.utc(2026, 4, 12, 10, 0, 4),
          messageId: 'assistant-1',
          data: {'fullCommandText': 'git status', 'resultKind': 'approved'},
        ),
      ],
      isStreaming: true,
    );

    expect(activity.entries, hasLength(5));
    expect(activity.entries[0].summary, 'Searched workspace for "message models"');
    expect(activity.entries[0].details, contains('grep_search'));
    expect(activity.entries[1].summary, 'Using flutter-architecture-general');
    expect(activity.entries[2].summary, 'Read file lib/ui/pages/chat/chat_page.dart');
    expect(activity.entries[3].summary, 'Requested permission to run git status');
    expect(activity.entries[4].summary, 'Granted permission to run git status');
  });

  test('assistant activity keeps reasoning separate from final assistant message', () {
    final activity = AssistantMessageActivity.fromEvents(
      events: [
        ConversationStreamEvent(
          type: 'assistant.reasoning_delta',
          conversationId: 'conversation-1',
          timestamp: DateTime.utc(2026, 4, 12, 10, 0),
          messageId: 'assistant-1',
          data: {'deltaContent': 'Inspecting the repository structure'},
        ),
        ConversationStreamEvent(
          type: 'assistant.reasoning',
          conversationId: 'conversation-1',
          timestamp: DateTime.utc(2026, 4, 12, 10, 0, 1),
          messageId: 'assistant-1',
          data: {'content': 'Inspecting the repository structure and identifying the relevant files.'},
        ),
        ConversationStreamEvent(
          type: 'assistant.message',
          conversationId: 'conversation-1',
          timestamp: DateTime.utc(2026, 4, 12, 10, 0, 2),
          messageId: 'assistant-1',
          data: {'content': 'Here is the final answer shown in the assistant bubble.'},
        ),
      ],
      isStreaming: false,
    );

    expect(activity.entries, hasLength(1));
    expect(activity.entries.single.kind, AssistantActivityEntryKind.reasoning);
    expect(activity.entries.single.markdown, 'Inspecting the repository structure and identifying the relevant files.');
    expect(activity.entries.single.markdown, isNot(contains('Here is the final answer')));
  });

  test('assistant activity keeps appending reasoning after a snapshot event', () {
    final activity = AssistantMessageActivity.fromEvents(
      events: [
        ConversationStreamEvent(
          type: 'assistant.reasoning_delta',
          conversationId: 'conversation-1',
          timestamp: DateTime.utc(2026, 4, 12, 10, 0),
          messageId: 'assistant-1',
          data: {'deltaContent': 'Inspecting the repository structure'},
        ),
        ConversationStreamEvent(
          type: 'assistant.reasoning',
          conversationId: 'conversation-1',
          timestamp: DateTime.utc(2026, 4, 12, 10, 0, 1),
          messageId: 'assistant-1',
          data: {'content': 'Inspecting the repository structure and identifying the relevant files.'},
        ),
        ConversationStreamEvent(
          type: 'assistant.reasoning_delta',
          conversationId: 'conversation-1',
          timestamp: DateTime.utc(2026, 4, 12, 10, 0, 2),
          messageId: 'assistant-1',
          data: {'deltaContent': 'Summarizing the findings now.'},
        ),
      ],
      isStreaming: true,
    );

    expect(activity.entries, hasLength(1));
    expect(activity.entries.single.markdown, 'Inspecting the repository structure and identifying the relevant files. Summarizing the findings now.');
  });

  testWidgets('animated text sheen wraps content in a shader while enabled', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AnimatedTextSheen(child: Text('Working...'))),
      ),
    );

    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(AnimatedTextSheen), findsOneWidget);
    expect(find.byType(ShaderMask), findsOneWidget);
    expect(find.text('Working...'), findsOneWidget);
  });

  testWidgets('chat page does not render assistant activity while disabled', (tester) async {
    final repository = _TimelineRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: ChatPage(repository: repository, sessionBundle: repository.bundle),
      ),
    );

    await tester.pumpAndSettle();

    repository.emit(
      ConversationStreamEvent(
        type: 'assistant.turn_start',
        conversationId: repository.bundle.conversation.id,
        timestamp: DateTime.utc(2026, 4, 12, 10, 0),
        messageId: 'assistant-1',
        source: 'sdk',
      ),
    );

    repository.emit(
      ConversationStreamEvent(
        type: 'assistant.reasoning_delta',
        conversationId: repository.bundle.conversation.id,
        timestamp: DateTime.utc(2026, 4, 12, 10, 0, 1),
        messageId: 'assistant-1',
        source: 'sdk',
        data: const {'deltaContent': 'Searching the repo for relevant files'},
      ),
    );

    repository.emit(
      ConversationStreamEvent(
        type: 'tool.execution_start',
        conversationId: repository.bundle.conversation.id,
        timestamp: DateTime.utc(2026, 4, 12, 10, 0, 2),
        messageId: 'assistant-1',
        source: 'sdk',
        data: const {'toolName': 'grep_search', 'query': 'message models'},
      ),
    );

    repository.emit(
      ConversationStreamEvent(
        type: 'skill.invoked',
        conversationId: repository.bundle.conversation.id,
        timestamp: DateTime.utc(2026, 4, 12, 10, 0, 3),
        messageId: 'assistant-1',
        source: 'sdk',
        data: const {
          'skillName': 'flutter-architecture-general',
          'files': ['lib/ui/pages/chat/chat_page.dart', 'lib/ui/components/chat_message_bubble.dart'],
        },
      ),
    );

    repository.emit(
      ConversationStreamEvent(
        type: 'permission.requested',
        conversationId: repository.bundle.conversation.id,
        timestamp: DateTime.utc(2026, 4, 12, 10, 0, 3, 500),
        messageId: 'assistant-1',
        source: 'sdk',
        data: const {'fullCommandText': 'git status'},
      ),
    );

    repository.emit(
      ConversationStreamEvent(
        type: 'permission.completed',
        conversationId: repository.bundle.conversation.id,
        timestamp: DateTime.utc(2026, 4, 12, 10, 0, 3, 800),
        messageId: 'assistant-1',
        source: 'sdk',
        data: const {'fullCommandText': 'git status', 'resultKind': 'approved'},
      ),
    );

    repository.emit(
      ConversationStreamEvent(
        type: 'assistant.message',
        conversationId: repository.bundle.conversation.id,
        timestamp: DateTime.utc(2026, 4, 12, 10, 0, 4),
        messageId: 'assistant-1',
        source: 'sdk',
        data: const {'content': 'Final answer'},
      ),
    );

    repository.emit(
      ConversationStreamEvent(
        type: 'assistant.turn_start',
        conversationId: repository.bundle.conversation.id,
        timestamp: DateTime.utc(2026, 4, 12, 10, 1),
        messageId: 'assistant-2',
        source: 'sdk',
      ),
    );

    repository.emit(
      ConversationStreamEvent(
        type: 'skill.invoked',
        conversationId: repository.bundle.conversation.id,
        timestamp: DateTime.utc(2026, 4, 12, 10, 1, 1),
        messageId: 'assistant-2',
        source: 'sdk',
        data: const {
          'skillName': 'aspnetcore-minimalapi-architecture-general',
          'files': ['remote_copilot_api/Program.cs'],
        },
      ),
    );

    repository.emit(
      ConversationStreamEvent(
        type: 'assistant.message',
        conversationId: repository.bundle.conversation.id,
        timestamp: DateTime.utc(2026, 4, 12, 10, 1, 2),
        messageId: 'assistant-2',
        source: 'sdk',
        data: const {'content': 'Second answer'},
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Final answer'), findsOneWidget);
    expect(find.text('Reasoning'), findsNothing);
    expect(find.textContaining('grep_search'), findsNothing);
    expect(find.textContaining('Requested permission to run git status'), findsNothing);
    expect(find.textContaining('Granted permission to run git status'), findsNothing);
    expect(find.text('Final answer'), findsOneWidget);
  });
}

class _TimelineRepository implements RemoteCopilotRepository {
  _TimelineRepository();

  final StreamController<ConversationStreamEvent> _controller = StreamController<ConversationStreamEvent>.broadcast();

  final RemoteSessionBundle bundle = RemoteSessionBundle(
    session: RemoteSession(
      id: 'session-1',
      title: 'Session',
      status: 'active',
      createdAt: DateTime.utc(2026, 4, 12, 9, 0),
      updatedAt: DateTime.utc(2026, 4, 12, 9, 0),
    ),
    conversation: ConversationThread(
      id: 'conversation-1',
      sessionId: 'session-1',
      title: 'Conversation',
      createdAt: DateTime.utc(2026, 4, 12, 9, 0),
      updatedAt: DateTime.utc(2026, 4, 12, 9, 0),
      messages: const [],
    ),
  );

  @override
  String baseUrl = 'http://localhost:8080';

  void dispose() {
    _controller.close();
  }

  void emit(ConversationStreamEvent event) {
    _controller.add(event);
  }

  @override
  Future<RemoteSessionBundle> createSession({String? workspaceId, String? title}) async {
    throw UnimplementedError();
  }

  @override
  Future<ConversationThread> getConversation(String conversationId) async {
    return bundle.conversation;
  }

  @override
  Future<HealthSnapshot> getHealth() async {
    return const HealthSnapshot(status: 'healthy', apiVersion: '0.1.0', databaseAvailable: true, copilotServerAvailable: true);
  }

  @override
  Future<List<CopilotModelOption>> getAvailableModels() async {
    return const [CopilotModelOption(id: 'gpt-4.1', name: 'GPT-4.1')];
  }

  @override
  Future<List<WorkspaceDefinition>> getWorkspaces() async {
    return const [];
  }

  @override
  Future<SendMessageResponse> sendMessage({required String conversationId, required String content, String? model}) async {
    throw UnimplementedError();
  }

  @override
  Stream<ConversationStreamEvent> streamConversation(String conversationId) {
    return _controller.stream;
  }
}
