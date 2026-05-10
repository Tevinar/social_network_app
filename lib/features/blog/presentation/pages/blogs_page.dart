import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/app/bootstrap/dependencies/init_dependencies.dart';
import 'package:social_app/app/cubits/app_user_cubit.dart';
import 'package:social_app/app/router/routes/routes.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/core/ui/feedback/show_snackbar.dart';
import 'package:social_app/core/ui/widgets/loader.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/presentation/blocs/blog_list/blog_list_bloc.dart';
import 'package:social_app/features/blog/presentation/widgets/blog_card.dart';
import 'package:social_app/features/blog/presentation/widgets/blog_card_place_holder.dart';

/// Page that displays the scrollable blog list.
class BlogsPage extends StatelessWidget {
  /// Creates a [BlogsPage].
  const BlogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<BlogListBloc>(),
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
            body: BlocConsumer<BlogListBloc, BlogListState>(
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
    final blogListBloc = context.read<BlogListBloc>();
    final createdBlog = await const AddNewBlogPageRoute().push<Blog>(context);

    if (createdBlog == null) {
      return;
    }

    blogListBloc.add(PrependCreatedBlog(createdBlog));
    await blogListBloc.scrollToTop();
  }

  Widget _buildBody(BuildContext context, BlogListState state) {
    if (state is BlogListLoading && state.blogs.isEmpty) {
      return _buildLoadingPlaceholders();
    }

    if (state is BlogListFailure && state.blogs.isEmpty) {
      return Center(child: Text(state.error));
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<BlogListBloc>().add(const RefreshList());
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

  Widget _buildBlogsList(BuildContext context, BlogListState state) {
    if (state.blogs.isEmpty) {
      return _buildEmptyState(context);
    }
    return ListView.builder(
      controller: context.read<BlogListBloc>().scrollController,
      itemCount: _itemCount(state),
      itemBuilder: (context, index) => _buildBlogListItem(state, index),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        'There are no blogs to display. Start a new one!',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  Widget _buildBlogListItem(BlogListState state, int index) {
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

  int _itemCount(BlogListState state) {
    final isLoadingMore = state is BlogListLoading && state.blogs.isNotEmpty;

    return state.blogs.length + (isLoadingMore ? 1 : 0);
  }

  Color _blogCardColor(int index) {
    return index.isEven ? AppPallete.gradient1 : AppPallete.gradient2;
  }
}
