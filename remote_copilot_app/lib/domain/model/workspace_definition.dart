class WorkspaceDefinition {
  const WorkspaceDefinition({
    required this.id,
    required this.name,
    required this.mountedPath,
    required this.sourceKind,
    required this.createdAt,
    this.lastUsedAt,
  });

  factory WorkspaceDefinition.fromJson(Map<String, dynamic> json) {
    return WorkspaceDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      mountedPath: json['mountedPath'] as String,
      sourceKind: json['sourceKind'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsedAt: json['lastUsedAt'] == null
          ? null
          : DateTime.parse(json['lastUsedAt'] as String),
    );
  }

  final String id;
  final String name;
  final String mountedPath;
  final String sourceKind;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
}
