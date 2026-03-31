import 'package:flutter/material.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/core/utils/calculate_reading_time.dart';
import 'package:social_app/core/utils/format_date.dart';
import 'package:social_app/core/widgets/loader.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';

/// A blog viewer page widget.
class BlogViewerPage extends StatelessWidget {
  /// Creates a [BlogViewerPage].
  const BlogViewerPage({
    required this.blog,
    this.imageProvider,
    this.precacheImageCallback,
    super.key,
  });

  /// The blog.
  final Blog blog;

  /// The image provider used to render the blog image.
  ///
  /// This is mainly useful in tests to avoid real network image loading.
  final ImageProvider<Object>? imageProvider;

  /// The callback used to precache the image before rendering the page body.
  ///
  /// This is mainly useful in tests to control or bypass image precaching.
  final Future<void> Function(BuildContext, ImageProvider<Object>)?
  precacheImageCallback;

  ImageProvider<Object> get _resolvedImageProvider =>
      imageProvider ?? NetworkImage(blog.imageUrl);

  /// Builds the blog viewer page.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: FutureBuilder(
        future:
            precacheImageCallback?.call(context, _resolvedImageProvider) ??
            precacheImage(_resolvedImageProvider, context),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          return Scrollbar(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      blog.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'By ${blog.posterName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${formatToDay(blog.updatedAt)} . '
                      '${calculateReadingTime(blog.content)} min',
                      style: const TextStyle(
                        color: AppPallete.greyColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(10),
                      child: Image(image: _resolvedImageProvider),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      blog.content,
                      style: const TextStyle(fontSize: 16, height: 2),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
