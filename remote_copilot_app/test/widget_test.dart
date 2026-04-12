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
  testWidgets('startup page renders remote copilot shell', (tester) async {
    await tester.pumpWidget(
      RemoteCopilotApp(repository: _FakeRemoteCopilotRepository(), settingsService: _FakeSettingsService(), initialThemeMode: ThemeMode.system),
    );

    await tester.pumpAndSettle();

    expect(find.text('Remote Copilot'), findsOneWidget);
    expect(find.textContaining('Sample Repo'), findsOneWidget);
    expect(find.text('Open general conversation'), findsOneWidget);
    expect(find.text('Open workspace conversation'), findsOneWidget);
  });
}

class _FakeRemoteCopilotRepository implements RemoteCopilotRepository {
  @override
  String baseUrl = 'http://localhost:8080';

  @override
  Future<RemoteSessionBundle> createSession({String? workspaceId, String? title}) async {
    throw UnimplementedError();
  }

  @override
  Future<ConversationThread> getConversation(String conversationId) async {
    throw UnimplementedError();
  }

  @override
  Future<HealthSnapshot> getHealth() async {
    return const HealthSnapshot(status: 'healthy', apiVersion: '0.1.0', databaseAvailable: true, copilotServerAvailable: true);
  }

  @override
  Future<List<WorkspaceDefinition>> getWorkspaces() async {
    return [
      WorkspaceDefinition(
        id: 'sample-repo',
        name: 'Sample Repo',
        mountedPath: '/workspaces/sample-repo',
        sourceKind: 'volume',
        createdAt: DateTime(2026),
      ),
    ];
  }

  @override
  Future<SendMessageResponse> sendMessage({required String conversationId, required String content, String? model}) async {
    throw UnimplementedError();
  }

  @override
  Stream<ConversationStreamEvent> streamConversation(String conversationId) {
    return const Stream.empty();
  }

  @override
  Future<List<CopilotModelOption>> getAvailableModels() {
    throw UnimplementedError();
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
