import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remote_copilot_app/domain/model/conversation_stream_event.dart';
import 'package:remote_copilot_app/domain/model/health_snapshot.dart';
import 'package:remote_copilot_app/domain/model/remote_session_bundle.dart';
import 'package:remote_copilot_app/domain/model/workspace_definition.dart';
import 'package:remote_copilot_app/domain/repositories/remote_copilot_repository.dart';
import 'package:remote_copilot_app/infrastructure/services/settings_service.dart';
import 'package:remote_copilot_app/main.dart';

void main() {
  testWidgets('home shell opens general chat without creating a session', (tester) async {
    final repository = _FakeRemoteCopilotRepository();

    await tester.pumpWidget(RemoteCopilotApp(repository: repository, settingsService: _FakeSettingsService(), initialThemeMode: ThemeMode.system));

    await tester.pumpAndSettle();

    expect(find.text('How can I help you?'), findsOneWidget);
    expect(find.text('Project catalog'), findsNothing);
    expect(repository.createSessionCalls, 0);
  });

  testWidgets('first sent message creates a general session once', (tester) async {
    final repository = _FakeRemoteCopilotRepository();

    await tester.pumpWidget(RemoteCopilotApp(repository: repository, settingsService: _FakeSettingsService(), initialThemeMode: ThemeMode.system));

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Hello from startup');
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(repository.createSessionCalls, 1);
    expect(repository.sendMessageCalls, 1);
    expect(repository.lastSentConversationId, 'conversation-1');
    expect(find.text('Hello from startup'), findsOneWidget);
  });

  testWidgets('drawer switches body to projects and shows repository workspaces', (tester) async {
    final repository = _FakeRemoteCopilotRepository();

    await tester.pumpWidget(RemoteCopilotApp(repository: repository, settingsService: _FakeSettingsService(), initialThemeMode: ThemeMode.system));

    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Projects'));
    await tester.pumpAndSettle();

    expect(find.text('Projects'), findsWidgets);
    expect(find.text('Sample Repo'), findsOneWidget);
    expect(find.text('/workspaces/sample-repo'), findsOneWidget);
  });

  testWidgets('new conversation resets the active chat state', (tester) async {
    final repository = _FakeRemoteCopilotRepository();

    await tester.pumpWidget(RemoteCopilotApp(repository: repository, settingsService: _FakeSettingsService(), initialThemeMode: ThemeMode.system));

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'First conversation');
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(repository.createSessionCalls, 1);
    expect(find.text('First conversation'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New conversation'));
    await tester.pumpAndSettle();

    expect(find.text('How can I help you?'), findsOneWidget);
    expect(find.text('First conversation'), findsNothing);

    await tester.enterText(find.byType(TextField), 'Second conversation');
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(repository.createSessionCalls, 2);
    expect(repository.lastSentConversationId, 'conversation-2');
    expect(find.text('Second conversation'), findsOneWidget);
  });

  testWidgets('chat history reopens an existing session', (tester) async {
    final repository = _FakeRemoteCopilotRepository();

    await tester.pumpWidget(RemoteCopilotApp(repository: repository, settingsService: _FakeSettingsService(), initialThemeMode: ThemeMode.system));

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Persisted message');
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Chats'));
    await tester.pumpAndSettle();

    expect(find.text('General conversation'), findsOneWidget);

    await tester.tap(find.text('General conversation'));
    await tester.pumpAndSettle();

    expect(find.text('Persisted message'), findsOneWidget);
    expect(repository.createSessionCalls, 1);
  });

  testWidgets('chat history entries can be deleted', (tester) async {
    final repository = _FakeRemoteCopilotRepository();

    await tester.pumpWidget(RemoteCopilotApp(repository: repository, settingsService: _FakeSettingsService(), initialThemeMode: ThemeMode.system));

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Delete me');
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Chats'));
    await tester.pumpAndSettle();

    expect(find.text('General conversation'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete chat'));
    await tester.pumpAndSettle();

    expect(find.text('Delete General conversation'), findsOneWidget);

    await tester.tap(find.text('Delete chat'));
    await tester.pumpAndSettle();

    expect(find.text('General conversation'), findsNothing);
    expect(repository.deletedSessionIds, ['session-1']);
  });
}

class _FakeRemoteCopilotRepository implements RemoteCopilotRepository {
  final List<WorkspaceDefinition> _workspaces = [
    WorkspaceDefinition(
      id: 'sample-repo',
      name: 'Sample Repo',
      mountedPath: '/workspaces/sample-repo',
      sourceKind: 'volume',
      createdAt: DateTime(2026),
    ),
  ];

  int createSessionCalls = 0;
  int sendMessageCalls = 0;
  final List<String> deletedSessionIds = [];
  String? lastSentConversationId;
  RemoteSessionBundle? _lastBundle;

  @override
  String baseUrl = 'http://localhost:8080';

  @override
  Future<WorkspaceDefinition> createWorkspace({required String name}) async {
    final workspace = WorkspaceDefinition(id: name, name: name, mountedPath: '/workspaces/$name', sourceKind: 'volume', createdAt: DateTime(2026));
    _workspaces.add(workspace);
    return workspace;
  }

  @override
  Future<RemoteSessionBundle> createSession({String? workspaceId, String? title}) async {
    createSessionCalls += 1;
    final now = DateTime(2026);
    final bundle = RemoteSessionBundle(
      session: RemoteSession(
        id: 'session-$createSessionCalls',
        title: title ?? 'General conversation',
        status: 'active',
        createdAt: now,
        updatedAt: now,
        workspaceId: workspaceId,
      ),
      conversation: ConversationThread(
        id: 'conversation-$createSessionCalls',
        sessionId: 'session-$createSessionCalls',
        title: 'General conversation',
        createdAt: now,
        updatedAt: now,
      ),
    );
    _lastBundle = bundle;
    return bundle;
  }

  @override
  Future<RemoteSessionBundle> getSession(String sessionId) async {
    final bundle = _lastBundle;
    if (bundle != null && bundle.session.id == sessionId) {
      return bundle;
    }

    final now = DateTime(2026);
    return RemoteSessionBundle(
      session: RemoteSession(id: sessionId, title: 'Recovered conversation', status: 'active', createdAt: now, updatedAt: now),
      conversation: ConversationThread(
        id: 'conversation-recovered',
        sessionId: sessionId,
        title: 'Recovered conversation',
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    deletedSessionIds.add(sessionId);
    if (_lastBundle?.session.id == sessionId) {
      _lastBundle = null;
    }
  }

  @override
  Future<ConversationThread> getConversation(String conversationId) async {
    return _lastBundle?.conversation ??
        ConversationThread(
          id: conversationId,
          sessionId: 'session-fallback',
          title: 'General conversation',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        );
  }

  @override
  Future<HealthSnapshot> getHealth() async {
    return const HealthSnapshot(status: 'healthy', apiVersion: '0.1.0', databaseAvailable: true, copilotServerAvailable: true);
  }

  @override
  Future<List<RemoteSession>> listSessions({String? workspaceId}) async {
    final sessions = [if (_lastBundle != null) _lastBundle!.session];

    if (workspaceId == null || workspaceId.isEmpty) {
      return sessions;
    }

    return sessions.where((item) => item.workspaceId == workspaceId).toList(growable: false);
  }

  @override
  Future<List<WorkspaceDefinition>> getWorkspaces() async {
    return List<WorkspaceDefinition>.from(_workspaces);
  }

  @override
  Future<List<WorkspaceDefinition>> syncWorkspaces() async {
    return List<WorkspaceDefinition>.from(_workspaces);
  }

  @override
  Future<WorkspaceDefinition> updateWorkspace({required String workspaceId, required String name}) async {
    final index = _workspaces.indexWhere((workspace) => workspace.id == workspaceId);
    final workspace = WorkspaceDefinition(id: name, name: name, mountedPath: '/workspaces/$name', sourceKind: 'volume', createdAt: DateTime(2026));

    if (index >= 0) {
      _workspaces[index] = workspace;
    }

    return workspace;
  }

  @override
  Future<WorkspaceDefinition> deleteWorkspace({required String workspaceId}) async {
    final workspace = _workspaces.firstWhere((item) => item.id == workspaceId);
    _workspaces.removeWhere((item) => item.id == workspaceId);
    return workspace;
  }

  @override
  Future<SendMessageResponse> sendMessage({required String conversationId, required String content, String? model}) async {
    sendMessageCalls += 1;
    lastSentConversationId = conversationId;
    final now = DateTime(2026);

    final userMessage = ConversationMessage(
      id: 'user-$sendMessageCalls',
      conversationId: conversationId,
      role: 'user',
      content: content,
      status: 'completed',
      sequence: 1,
      createdAt: now,
      updatedAt: now,
    );

    final assistantMessage = ConversationMessage(
      id: 'assistant-$sendMessageCalls',
      conversationId: conversationId,
      role: 'assistant',
      content: 'Acknowledged',
      status: 'completed',
      sequence: 2,
      createdAt: now,
      updatedAt: now,
    );

    final session =
        _lastBundle?.session ?? RemoteSession(id: 'session-1', title: 'General conversation', status: 'active', createdAt: now, updatedAt: now);

    final conversation = ConversationThread(
      id: conversationId,
      sessionId: session.id,
      title: 'General conversation',
      createdAt: now,
      updatedAt: now,
      messages: [userMessage, assistantMessage],
    );

    _lastBundle = RemoteSessionBundle(session: session, conversation: conversation);

    return SendMessageResponse(session: session, conversation: conversation, userMessage: userMessage, assistantMessage: assistantMessage);
  }

  @override
  Stream<ConversationStreamEvent> streamConversation(String conversationId) {
    return const Stream.empty();
  }

  @override
  Future<List<CopilotModelOption>> getAvailableModels() {
    return Future.value(const [CopilotModelOption(id: 'gpt-4.1', name: 'GPT-4.1')]);
  }
}

class _FakeSettingsService implements SettingsService {
  @override
  Future<String> loadBaseUrl() async => 'http://localhost:8080';

  @override
  Future<ThemeMode> loadThemeMode() async => ThemeMode.system;

  @override
  Future<void> saveBaseUrl(String value) async {}

  @override
  Future<void> saveThemeMode(ThemeMode value) async {}
}
