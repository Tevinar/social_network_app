import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/app/bootstrap/dependencies/init_dependencies.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/core/ui/formatting/format_date.dart';
import 'package:social_app/core/ui/text/calculate_reading_time.dart';
import 'package:social_app/core/ui/widgets/loader.dart';
import 'package:social_app/features/blog/presentation/blocs/blog_viewer/blog_viewer_bloc.dart';

/// A blog viewer page widget.
class BlogViewerPage extends StatelessWidget {
  /// Creates a [BlogViewerPage].
  const BlogViewerPage({
    required this.blogId,
    super.key,
  });

  /// The blog ID.
  final String blogId;

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
      body: BlocProvider(
        create: (context) => serviceLocator<BlogViewerBloc>(),
        child: Builder(
          builder: _loadBlogContent,
        ),
      ),
    );
  }

  Widget _loadBlogContent(BuildContext context) {
    return BlocBuilder<BlogViewerBloc, BlogViewerState>(
      builder: (context, state) {
        if (state is BlogViewerInitial) {
          context.read<BlogViewerBloc>().add(
            LoadBlog(
              blogId: blogId,
            ),
          );
          return const SizedBox();
        } else if (state is BlogViewerLoading) {
          return const Loader();
        } else if (state is BlogViewerFailure) {
          return Center(
            child: Text(
              state.error,
            ),
          );
        } else {
          return _buildBlogContent(context, state as BlogViewerSuccess);
        }
      },
    );
  }

  Widget _buildBlogContent(BuildContext context, BlogViewerSuccess state) {
    final blog = state.blog;
    return FutureBuilder(
      future: _prepareBlogImage(context, state.imageFile),
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
                  _displayBlogImage(asyncSnapshot.data),
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
    );
  }

  Widget _displayBlogImage(ImageProvider<Object>? imageProvider) {
    if (imageProvider == null) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        child: const Text('Image unavailable offline'),
      );
    } else {
      return Image(
        image: imageProvider,
        errorBuilder: (_, _, _) {
          return Container(
            height: 220,
            alignment: Alignment.center,
            child: const Text('Image unavailable'),
          );
        },
      );
    }
  }

  Future<ImageProvider<Object>?> _prepareBlogImage(
    BuildContext context,
    File? imageFile,
  ) async {
    if (imageFile == null) {
      return null;
    }

    final resolvedImageProvider = FileImage(imageFile);

    if (!context.mounted) {
      return resolvedImageProvider;
    }

    await precacheImage(resolvedImageProvider, context);

    return resolvedImageProvider;
  }
}
