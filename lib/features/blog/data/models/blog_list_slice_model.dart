import 'package:social_app/core/serialization/json_reader.dart';
import 'package:social_app/features/blog/data/models/blog_model.dart';

/// Data-layer representation of one cursor-based blog list slice.
class BlogListSliceModel {
  /// Creates a [BlogListSliceModel].
  BlogListSliceModel({
    required this.items,
    required this.nextCursor,
  });

  /// Builds a blog list slice model from a backend JSON payload.
  factory BlogListSliceModel.fromJson(Map<String, dynamic> json) {
    final items = JsonReader.readList(json, 'items');

    return BlogListSliceModel(
      items: items
          .map(
            (item) => BlogModel.fromJson(JsonReader.asObject(item, 'items[]')),
          )
          .toList(),
      nextCursor: JsonReader.readNullableString(json, 'nextCursor'),
    );
  }

  /// Blogs returned in the current list slice.
  final List<BlogModel> items;

  /// Opaque cursor to request the next slice, when available.
  final String? nextCursor;
}
