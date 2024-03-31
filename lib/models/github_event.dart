class GithubEvent {
  final String id;
  final String type;
  final String actorName;
  final String createdAt;
  final String payloadDescription;

  GithubEvent({
    required this.id,
    required this.type,
    required this.actorName,
    required this.createdAt,
    required this.payloadDescription,
  });

  factory GithubEvent.fromJson(Map<String, dynamic> json) {
    return GithubEvent(
      id: json['id'] as String,
      type: json['type'] as String,
      actorName: (json['actor'] as Map<String, dynamic>)['login'] as String,
      createdAt: json['created_at'] as String,
      payloadDescription: json['payload']['description'] ?? 'No description',
    );
  }
}
