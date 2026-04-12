class RemoteSessionBundle {
  const RemoteSessionBundle({required this.session, required this.conversation});

  factory RemoteSessionBundle.fromJson(Map<String, dynamic> json) {
    return RemoteSessionBundle(
      session: RemoteSession.fromJson(json['session'] as Map<String, dynamic>),
      conversation: ConversationThread.fromJson(json['conversation'] as Map<String, dynamic>),
    );
  }

  final RemoteSession session;
  final ConversationThread conversation;
}

class RemoteSession {
  const RemoteSession({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.workspaceId,
    this.copilotSessionId,
  });

  factory RemoteSession.fromJson(Map<String, dynamic> json) {
    return RemoteSession(
      id: _readString(json, 'id'),
      title: _readString(json, 'title', fallback: 'Untitled session'),
      status: _readString(json, 'status'),
      createdAt: _readDateTime(json, 'createdAt'),
      updatedAt: _readDateTime(json, 'updatedAt'),
      workspaceId: _readNullableString(json, 'workspaceId'),
      copilotSessionId: _readNullableString(json, 'copilotSessionId'),
    );
  }

  final String id;
  final String title;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? workspaceId;
  final String? copilotSessionId;
}

class ConversationThread {
  const ConversationThread({
    required this.id,
    required this.sessionId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
  });

  factory ConversationThread.fromJson(Map<String, dynamic> json) {
    return ConversationThread(
      id: _readString(json, 'id'),
      sessionId: _readString(json, 'sessionId'),
      title: _readString(json, 'title', fallback: 'Conversation'),
      createdAt: _readDateTime(json, 'createdAt'),
      updatedAt: _readDateTime(json, 'updatedAt'),
      messages: (json['messages'] as List<dynamic>? ?? []).map((item) => ConversationMessage.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  final String id;
  final String sessionId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ConversationMessage> messages;

  ConversationThread copyWith({
    String? id,
    String? sessionId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ConversationMessage>? messages,
  }) {
    return ConversationThread(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
    );
  }
}

class ConversationMessage {
  const ConversationMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.status,
    required this.sequence,
    required this.createdAt,
    required this.updatedAt,
    this.error,
  });

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      id: _readString(json, 'id'),
      conversationId: _readString(json, 'conversationId'),
      role: _readString(json, 'role'),
      content: _readString(json, 'content'),
      status: _readString(json, 'status'),
      sequence: _readInt(json, 'sequence'),
      createdAt: _readDateTime(json, 'createdAt'),
      updatedAt: _readDateTime(json, 'updatedAt'),
      error: _readNullableString(json, 'error'),
    );
  }

  final String id;
  final String conversationId;
  final String role;
  final String content;
  final String status;
  final int sequence;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? error;

  ConversationMessage copyWith({
    String? id,
    String? conversationId,
    String? role,
    String? content,
    String? status,
    int? sequence,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? error,
  }) {
    return ConversationMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      status: status ?? this.status,
      sequence: sequence ?? this.sequence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      error: error ?? this.error,
    );
  }
}

String _readString(Map<String, dynamic> json, String key, {String fallback = ''}) {
  final value = json[key];
  if (value is String) {
    return value;
  }

  return value?.toString() ?? fallback;
}

String? _readNullableString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String) {
    return value;
  }

  return value?.toString();
}

int _readInt(Map<String, dynamic> json, String key, {int fallback = 0}) {
  final value = json[key];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }

  return fallback;
}

DateTime _readDateTime(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return parsed;
    }
  }

  return DateTime.now().toUtc();
}
