import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/app/bootstrap/dependencies/init_dependencies.dart';
import 'package:social_app/core/local_storage/image_file_cache.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/core/utils/calculate_reading_time.dart';
import 'package:social_app/core/utils/format_date.dart';
import 'package:social_app/core/widgets/loader.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
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
      future: _prepareBlogImage(context, blog),
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
                  _displayBlogImage(context, asyncSnapshot.data, blog),
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

  Widget _displayBlogImage(
    BuildContext context,
    ImageProvider<Object>? imageProvider,
    Blog blog,
  ) {
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

  Future<ImageProvider<Object>?> _resolveBlogImage(Blog blog) async {
    final downloadedFile = await serviceLocator<ImageFileCache>().getOrDownload(
      cacheKey: blog.id,
      imageUrl: blog.imageUrl,
    );

    if (downloadedFile == null) {
      return null;
    }

    return FileImage(downloadedFile);
  }

  Future<ImageProvider<Object>?> _prepareBlogImage(
    BuildContext context,
    Blog blog,
  ) async {
    final resolvedImageProvider = await _resolveBlogImage(blog);
    if (resolvedImageProvider == null) {
      return null;
    }
    if (!context.mounted) {
      return resolvedImageProvider;
    }

    await precacheImage(resolvedImageProvider, context);

    return resolvedImageProvider;
  }
}
