import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/entities/blog_topic.dart';

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
    required this.posterName,
  });

  /// Creates a [BlogModel] from a JSON map returned by Supabase.
  factory BlogModel.fromSupabaseJson(Map<String, dynamic> map) {
    return BlogModel(
      id: (map['id'] as String?) ?? '',
      posterId: (map['poster_id'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      content: (map['content'] as String?) ?? '',
      imageUrl: (map['image_url'] as String?) ?? '',
      topics: ((map['topics'] as List<dynamic>?) ?? [])
          .map((topic) => BlogTopic.fromValue(topic as String))
          .toList(),
      updatedAt: map['updated_at'] == null
          ? DateTime.now()
          : DateTime.parse(map['updated_at'] as String),
      posterName: map['poster_name'] as String? ?? '',
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
  final List<BlogTopic> topics;

  /// The updated at.
  final DateTime updatedAt;

  /// The poster name.
  final String posterName;

  /// Converts the blog model to a JSON map for Supabase insertion.
  Map<String, dynamic> toSupabaseInsertJson() {
    return <String, dynamic>{
      'id': id,
      'poster_id': posterId,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'topics': topics.map((topic) => topic.value).toList(),
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
    List<BlogTopic>? topics,

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
