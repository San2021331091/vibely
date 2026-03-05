class Video {
  final String? id;
  final String? artistSongName;
  final String? descriptionTags;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? userId;
  final int? likesCount;
  final int? commentsCount;
  final DateTime? createdAt;

  Video({
    this.id,
    this.artistSongName,
    this.descriptionTags,
    this.videoUrl,
    this.thumbnailUrl,
    this.userId,
    this.likesCount,
    this.commentsCount,
    this.createdAt,
  });

  /// Convert Supabase JSON → Dart Object
  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      artistSongName: json['artist_song_name'] ?? '',
      descriptionTags: json['description_tags'] ?? '',
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      userId: json['user_id'] ?? '',
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// Convert Dart Object → JSON for Supabase insert
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "artist_song_name": artistSongName,
      "description_tags": descriptionTags,
      "video_url": videoUrl,
      "thumbnail_url": thumbnailUrl,
      "user_id": userId,
      "likes_count": likesCount,
      "comments_count": commentsCount,
      "created_at": createdAt?.toIso8601String(),
    };
  }
}