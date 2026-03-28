import 'package:flutter/material.dart';
import 'package:social_app/app/router/routes/routes.dart';
import 'package:social_app/core/utils/calculate_reading_time.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';

/// A blog card widget.
class BlogCard extends StatelessWidget {
  /// Creates a [BlogCard].
  const BlogCard({required this.blog, required this.color, super.key});

  /// The blog.
  final Blog blog;

  /// The color.
  final Color color;

  @override
  /// The build.
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => BlogViewerPageRoute($extra: blog).push<void>(context),
      child: Container(
        height: 200,
        margin: const EdgeInsets.all(16).copyWith(bottom: 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: blog.topics
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsetsGeometry.all(5),
                            child: Chip(label: Text(e)),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Text(
                  blog.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text('${calculateReadingTime(blog.content)} min'),
          ],
        ),
      ),
    );
  }
}
