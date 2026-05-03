import 'package:social_app/core/serialization/json_reader.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/value_objects/blog_topic.dart';

/// Data-layer representation of one blog payload returned by the backend.
class BlogModel {
  /// Creates a [BlogModel].
  BlogModel({
    required this.id,
    required this.posterId,
    required this.posterName,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.topics,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Builds a [BlogModel] from a backend JSON payload.
  factory BlogModel.fromJson(Map<String, dynamic> json) {
    final poster = JsonReader.readObject(json, 'poster');

    return BlogModel(
      id: JsonReader.readString(json, 'id'),
      posterId: JsonReader.readString(poster, 'id'),
      posterName: JsonReader.readString(poster, 'name'),
      title: JsonReader.readString(json, 'title'),
      content: JsonReader.readString(json, 'content'),
      imageUrl: JsonReader.readString(json, 'imageUrl'),
      topics: JsonReader.readStringList(
        json,
        'topics',
      ).map(BlogTopic.fromValue).toList(),
      createdAt: JsonReader.readDateTime(json, 'createdAt'),
      updatedAt: JsonReader.readDateTime(json, 'updatedAt'),
    );
  }

  /// Stable blog identifier.
  final String id;

  /// Stable identifier of the user who created the blog.
  final String posterId;

  /// Display name of the blog author.
  final String posterName;

  /// Blog title shown in lists and detail pages.
  final String title;

  /// Main textual content of the blog.
  final String content;

  /// Absolute image URL returned by the backend.
  final String imageUrl;

  /// Topics associated with the blog.
  final List<BlogTopic> topics;

  /// Blog creation timestamp.
  final DateTime createdAt;

  /// Blog last-update timestamp.
  final DateTime updatedAt;

  /// Returns a copy of this model with the provided fields replaced.
  BlogModel copyWith({
    String? id,
    String? posterId,
    String? posterName,
    String? title,
    String? content,
    String? imageUrl,
    List<BlogTopic>? topics,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BlogModel(
      id: id ?? this.id,
      posterId: posterId ?? this.posterId,
      posterName: posterName ?? this.posterName,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      topics: topics ?? this.topics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts the data model into the domain [Blog] entity.
  Blog toEntity() {
    return Blog(
      id: id,
      posterId: posterId,
      posterName: posterName,
      title: title,
      content: content,
      imageUrl: imageUrl,
      topics: topics,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
