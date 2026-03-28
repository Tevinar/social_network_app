/// Domain entity representing a blog post displayed in the app.
class Blog {
  /// Creates a [Blog].
  const Blog({
    required this.id,
    required this.posterId,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.topics,
    required this.updatedAt,
    this.posterName,
  });

  /// Unique blog identifier.
  final String id;

  /// Identifier of the user who created the blog.
  final String posterId;

  /// Blog title shown in lists and detail views.
  final String title;

  /// Main text content of the blog post.
  final String content;

  /// Public URL of the blog cover image.
  final String imageUrl;

  /// Topics associated with the blog.
  final List<String> topics;

  /// Last update date used for ordering and display.
  final DateTime updatedAt;

  /// Optional poster name resolved for display purposes.
  final String? posterName;
}
