class ConversationStreamEvent {
  const ConversationStreamEvent({
    required this.type,
    required this.conversationId,
    required this.timestamp,
    this.messageId,
    this.id,
    this.parentId,
    this.ephemeral = false,
    this.source = 'sdk',
    this.data,
  });

  factory ConversationStreamEvent.fromJson(Map<String, dynamic> json) {
    return ConversationStreamEvent(
      type: _readString(json, 'type', fallback: 'unknown'),
      conversationId: _readString(json, 'conversationId'),
      timestamp: _readDateTime(json, 'timestamp'),
      messageId: _readNullableString(json, 'messageId'),
      id: _readNullableString(json, 'eventId'),
      parentId: _readNullableString(json, 'parentEventId'),
      ephemeral: _readBool(json, 'ephemeral'),
      source: _readString(json, 'source', fallback: 'sdk'),
      data: _readNullableMap(json, 'data'),
    );
  }

  static String _readString(Map<String, dynamic> json, String key, {String fallback = ''}) {
    final value = json[key];
    if (value is String) {
      return value;
    }

    return value?.toString() ?? fallback;
  }

  static String? _readNullableString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) {
      return value;
    }

    return value?.toString();
  }

  static bool _readBool(Map<String, dynamic> json, String key, {bool fallback = false}) {
    final value = json[key];
    if (value is bool) {
      return value;
    }
    if (value is String) {
      return value.toLowerCase() == 'true';
    }

    return fallback;
  }

  static Map<String, dynamic>? _readNullableMap(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((mapKey, mapValue) => MapEntry(mapKey.toString(), mapValue));
    }

    return null;
  }

  static DateTime _readDateTime(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }

    return DateTime.now().toUtc();
  }

  final String type;
  final String conversationId;
  final String? messageId;
  final DateTime timestamp;
  final String? id;
  final String? parentId;
  final bool ephemeral;
  final String source;
  final Map<String, dynamic>? data;
}
