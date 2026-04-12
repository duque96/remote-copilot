class HealthSnapshot {
  const HealthSnapshot({
    required this.status,
    required this.apiVersion,
    required this.databaseAvailable,
    required this.copilotServerAvailable,
  });

  factory HealthSnapshot.fromJson(Map<String, dynamic> json) {
    return HealthSnapshot(
      status: json['status'] as String? ?? 'unknown',
      apiVersion: json['apiVersion'] as String? ?? 'unknown',
      databaseAvailable: json['databaseAvailable'] as bool? ?? false,
      copilotServerAvailable: json['copilotServerAvailable'] as bool? ?? false,
    );
  }

  final String status;
  final String apiVersion;
  final bool databaseAvailable;
  final bool copilotServerAvailable;
}
