class Comment {
  final String? id;
  final String videoId;
  final String userId;
  final String commentText;
  final DateTime createdAt;

  Comment({
    this.id,
    required this.videoId,
    required this.userId,
    required this.commentText,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String?,
      videoId: json['video_id'] as String,
      userId: json['user_id'] as String,
      commentText: json['comment_text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'video_id': videoId,
        'user_id': userId,
        'comment_text': commentText,
        'created_at': createdAt.toIso8601String(),
      };

  /// <--- Add this copyWith method
  Comment copyWith({
    String? id,
    String? videoId,
    String? userId,
    String? commentText,
    DateTime? createdAt,
  }) {
    return Comment(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      userId: userId ?? this.userId,
      commentText: commentText ?? this.commentText,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}