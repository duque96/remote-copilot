import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:remote_copilot_app/domain/model/conversation_stream_event.dart';
import 'package:remote_copilot_app/infrastructure/services/sse_client.dart';

class ApiClient {
  ApiClient({
    required http.Client client,
    required SseClient sseClient,
    required String baseUrl,
  })  : _client = client,
        _sseClient = sseClient,
        _baseUrl = _normalizeBaseUrl(baseUrl);

  final http.Client _client;
  final SseClient _sseClient;
  String _baseUrl;

  String get baseUrl => _baseUrl;

  set baseUrl(String value) => _baseUrl = _normalizeBaseUrl(value);

  Future<Map<String, dynamic>> getJson(String path) async {
    final response = await _client.get(_buildUri(path));
    return _decodeObject(response);
  }

  Future<List<dynamic>> getJsonList(String path) async {
    final response = await _client.get(_buildUri(path));
    return _decodeList(response);
  }

  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body) async {
    final response = await _client.post(
      _buildUri(path),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decodeObject(response);
  }

  Stream<ConversationStreamEvent> openConversationStream(String conversationId) {
    return _sseClient.connect(
      _buildUri('/api/conversations/$conversationId/events'),
    );
  }

  Uri _buildUri(String path) => Uri.parse(_baseUrl).resolve(path);

  Map<String, dynamic> _decodeObject(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'The server returned ${response.statusCode}: ${response.body}',
      );
    }

    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  List<dynamic> _decodeList(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'The server returned ${response.statusCode}: ${response.body}',
      );
    }

    return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
  }

  static String _normalizeBaseUrl(String rawValue) {
    final trimmed = rawValue.trim();
    return trimmed.endsWith('/') ? trimmed.substring(0, trimmed.length - 1) : trimmed;
  }
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
