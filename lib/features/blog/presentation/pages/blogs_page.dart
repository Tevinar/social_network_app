import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/app/bootstrap/dependencies/init_dependencies.dart';
import 'package:social_app/app/router/routes/routes.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/core/utils/show_snackbar.dart';
import 'package:social_app/core/widgets/loader.dart';
import 'package:social_app/features/blog/presentation/blocs/blogs/'
    'blogs_bloc.dart';
import 'package:social_app/features/blog/presentation/widgets/blog_card.dart';
import 'package:social_app/features/blog/presentation/widgets/'
    'blog_card_place_holder.dart';

/// A blogs page widget.
class BlogsPage extends StatelessWidget {
  /// Creates a [BlogsPage].
  const BlogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<BlogsBloc>(),
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
            body: BlocBuilder<BlogsBloc, BlogsState>(
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
    final blogsBloc = context.read<BlogsBloc>();

    final created = await const AddNewBlogPageRoute().push<bool>(context);

    if (created != true) {
      return;
    }

    await blogsBloc.scrollToTop();
    // Refreshes the list size after a newly created blog is added.
    blogsBloc.add(
      RefreshBlogsView(),
    );
  }

  Widget _buildBody(BuildContext context, BlogsState state) {
    if (state is BlogsFailure) {
      return const Center(child: Text('Error loading blogs'));
    }

    if (state is BlogsLoading && state.blogs.isEmpty) {
      return _buildLoadingPlaceholders();
    }

    return _buildBlogsList(context, state);
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

  Widget _buildBlogsList(BuildContext context, BlogsState state) {
    return ListView.builder(
      controller: context.read<BlogsBloc>().scrollController,
      itemCount: _itemCount(state),
      itemBuilder: (context, index) => _buildBlogListItem(state, index),
    );
  }

  Widget _buildBlogListItem(BlogsState state, int index) {
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

  int _itemCount(BlogsState state) {
    return state.blogs.length == state.totalBlogsInDatabase
        ? state.blogs.length
        : state.blogs.length + 1;
  }

  Color _blogCardColor(int index) {
    return index.isEven ? AppPallete.gradient1 : AppPallete.gradient2;
  }
}
