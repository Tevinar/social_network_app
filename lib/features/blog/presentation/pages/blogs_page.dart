import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/app/bootstrap/dependencies/init_dependencies.dart';
import 'package:social_app/app/router/routes/routes.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/core/ui/feedback/show_snackbar.dart';
import 'package:social_app/core/ui/widgets/loader.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/presentation/blocs/blog_feed/blog_feed_bloc.dart';
import 'package:social_app/features/blog/presentation/widgets/blog_card.dart';
import 'package:social_app/features/blog/presentation/widgets/blog_card_place_holder.dart';

/// Page that displays the scrollable blog feed.
class BlogsPage extends StatelessWidget {
  /// Creates a [BlogsPage].
  const BlogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<BlogFeedBloc>(),
      child: Builder(
        builder: (innerContext) {
          return Scaffold(
            appBar: AppBar(
              leading: BlocConsumer<AppUserCubit, AppUserState>(
                listener: (_, state) =>
                    _onAppUserStateChanged(innerContext, state),
                builder: (_, state) => _buildAppUserAction(innerContext, state),
              ),
              title: const Text('Blogs'),
              actions: [
                IconButton(
                  onPressed: () => _openAddBlogPage(innerContext),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            body: BlocConsumer<BlogFeedBloc, BlogFeedState>(
              listenWhen: (previous, current) =>
                  previous.refreshError != current.refreshError &&
                  current.refreshError != null,
              listener: (context, state) {
                if (state.refreshError != null) {
                  showSnackBar(context, state.refreshError!);
                }
              },
              builder: (_, state) => _buildBody(innerContext, state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppUserAction(BuildContext context, AppUserState state) {
    if (state is AppUserLoading) {
      return const Loader(size: 20);
    }

    return IconButton(
      onPressed: () => _signOut(context),
      icon: const Icon(Icons.logout, size: 20),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await context.read<AppUserCubit>().signOut();
  }

  void _onAppUserStateChanged(BuildContext context, AppUserState state) {
    if (state is AppUserFailure) {
      showSnackBar(context, state.error);
    }
  }

  Future<void> _openAddBlogPage(BuildContext context) async {
    final blogFeedBloc = context.read<BlogFeedBloc>();
    final createdBlog = await const AddNewBlogPageRoute().push<Blog>(context);

    if (createdBlog == null) {
      return;
    }

    blogFeedBloc.add(PrependCreatedBlog(createdBlog));
    await blogFeedBloc.scrollToTop();
  }

  Widget _buildBody(BuildContext context, BlogFeedState state) {
    if (state is BlogFeedLoading && state.blogs.isEmpty) {
      return _buildLoadingPlaceholders();
    }

    if (state is BlogFeedFailure && state.blogs.isEmpty) {
      return Center(child: Text(state.error));
    }

    return Column(
      children: [
        if (state.hasNewContentAvailable)
          MaterialBanner(
            content: const Text('New blogs are available'),
            actions: [
              TextButton(
                onPressed: () {
                  context.read<BlogFeedBloc>().add(const RefreshFeed());
                },
                child: const Text('Refresh'),
              ),
            ],
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<BlogFeedBloc>().add(const RefreshFeed());
            },
            child: _buildBlogsList(context, state),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingPlaceholders() {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(
          4,
          (index) => BlogCardPlaceholder(
            color: _blogCardColor(index),
          ),
        ),
      ),
    );
  }

  Widget _buildBlogsList(BuildContext context, BlogFeedState state) {
    return ListView.builder(
      controller: context.read<BlogFeedBloc>().scrollController,
      itemCount: _itemCount(state),
      itemBuilder: (context, index) => _buildBlogListItem(state, index),
    );
  }

  Widget _buildBlogListItem(BlogFeedState state, int index) {
    if (index == state.blogs.length) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Loader(size: 30),
      );
    }

    return BlogCard(
      blog: state.blogs[index],
      color: _blogCardColor(index),
    );
  }

  int _itemCount(BlogFeedState state) {
    return state.blogs.length + (state.isLoadingMore ? 1 : 0);
  }

  Color _blogCardColor(int index) {
    return index.isEven ? AppPallete.gradient1 : AppPallete.gradient2;
  }
}
