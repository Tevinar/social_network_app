import 'package:social_app/features/blog/domain/entities/blog.dart';

/// A blog model.
class BlogModel {
  /// Creates a [BlogModel].
  BlogModel({
    required this.id,
    required this.posterId,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.topics,
    required this.updatedAt,
    this.posterName,
  });

  /// Creates a [BlogModel].
  factory BlogModel.fromJson(Map<String, dynamic> map) {
    return BlogModel(
      id: (map['id'] as String?) ?? '',
      posterId: (map['poster_id'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      content: (map['content'] as String?) ?? '',
      imageUrl: (map['image_url'] as String?) ?? '',
      topics: List<String>.from((map['topics'] as List<dynamic>?) ?? []),
      updatedAt: map['updated_at'] == null
          ? DateTime.now()
          : DateTime.parse(map['updated_at'] as String),
    );
  }

  /// The id.
  final String id;

  /// The poster id.
  final String posterId;

  /// The title.
  final String title;

  /// The content.
  final String content;

  /// The image url.
  final String imageUrl;

  /// The topics.
  final List<String> topics;

  /// The updated at.
  final DateTime updatedAt;

  /// The poster name.
  final String? posterName;

  /// The to json.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'poster_id': posterId,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'topics': topics,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// The copy with.
  BlogModel copyWith({
    /// The id.
    String? id,

    /// The poster id.
    String? posterId,

    /// The title.
    String? title,

    /// The content.
    String? content,

    /// The image url.
    String? imageUrl,

    /// The topics.
    List<String>? topics,

    /// The updated at.
    DateTime? updatedAt,

    /// The poster name.
    String? posterName,
  }) {
    return BlogModel(
      id: id ?? this.id,
      posterId: posterId ?? this.posterId,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      topics: topics ?? this.topics,
      updatedAt: updatedAt ?? this.updatedAt,
      posterName: posterName ?? this.posterName,
    );
  }

  /// The to entity.
  Blog toEntity() {
    return Blog(
      id: id,
      posterId: posterId,
      title: title,
      content: content,
      imageUrl: imageUrl,
      topics: topics,
      updatedAt: updatedAt,
      posterName: posterName,
    );
  }
}
