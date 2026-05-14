class TraceLog {
  final int step;
  final String title;
  final String description;
  final String timestamp;
  final String status;

  const TraceLog({
    required this.step,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.status,
  });

  factory TraceLog.fromMap(Map<String, dynamic> map) {
    return TraceLog(
      step: map['step'] ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      timestamp: map['timestamp'] ?? '',
      status: map['status'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'step': step,
      'title': title,
      'description': description,
      'timestamp': timestamp,
      'status': status,
    };
  }
}
