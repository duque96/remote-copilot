import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:remote_copilot_app/domain/model/conversation_stream_event.dart';
import 'package:remote_copilot_app/infrastructure/services/api_client.dart';

class SseClient {
  const SseClient(this._client);

  final http.Client _client;

  Stream<ConversationStreamEvent> connect(Uri uri) async* {
    final request = http.Request('GET', uri)
      ..headers['Accept'] = 'text/event-stream';

    final response = await _client.send(request);
    if (response.statusCode != 200) {
      throw ApiException('Unable to open event stream: ${response.statusCode}.');
    }

    String? currentEventType;
    await for (final line in response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      if (line.isEmpty) {
        currentEventType = null;
        continue;
      }

      if (line.startsWith('event:')) {
        currentEventType = line.substring(6).trim();
        continue;
      }

      if (!line.startsWith('data:')) {
        continue;
      }

      final payload = jsonDecode(line.substring(5).trim()) as Map<String, dynamic>;
      if (currentEventType != null) {
        payload['type'] = currentEventType;
      }

      yield ConversationStreamEvent.fromJson(payload);
    }
  }
}
