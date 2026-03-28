import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/app/router/routes/routes.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/core/utils/show_snackbar.dart';
import 'package:social_app/core/widgets/loader.dart';
import 'package:social_app/features/blog/presentation/blocs/blogs/blogs_bloc.dart';
import 'package:social_app/features/blog/presentation/widgets/blog_card.dart';
import 'package:social_app/features/blog/presentation/widgets/blog_card_place_holder.dart';

class BlogsPage extends StatelessWidget {
  const BlogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BlocConsumer<AppUserCubit, AppUserState>(
          builder: (context, state) {
            if (state is AppUserLoading) {
              return const Loader(size: 20);
            }
            return IconButton(
              onPressed: () async {
                await context.read<AppUserCubit>().signOut();
              },
              icon: const Icon(Icons.logout, size: 20),
            );
          },
          listener: (context, state) {
            if (state is AppUserFailure) {
              showSnackBar(context, state.error);
            }
          },
        ),
        title: const Text('Blogs'),
        actions: [
          IconButton(
            onPressed: () async {
              final blogsBloc = context.read<BlogsBloc>();

              final created = await const AddNewBlogPageRoute().push<bool>(
                context,
              );

              if (created == true) {
                await blogsBloc.scrollToTop();
                blogsBloc.add(
                  RefreshBlogsView(),
                ); // Usefull for keeping the itemCount of the listview updated after adding a new blog
              }
            },

            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: BlocBuilder<BlogsBloc, BlogsState>(
        builder: (context, state) {
          if (state is BlogsFailure) {
            return const Center(child: Text('Error loading blogs'));
          }
          // Show loading placeholders when blogs are being fetched for the first time
          else if (state is BlogsLoading && state.blogs.isEmpty) {
            return SingleChildScrollView(
              child: Column(
                children: List.generate(
                  4,
                  (index) => BlogCardPlaceholder(
                    color: index % 2 == 0
                        ? AppPallete.gradient1
                        : AppPallete.gradient2,
                  ),
                ),
              ),
            );
          } else {
            return ListView.builder(
              controller: context.read<BlogsBloc>().scrollController,
              itemCount: state.blogs.length == state.totalBlogsInDatabase
                  ? state.blogs.length
                  : state.blogs.length + 1,
              itemBuilder: (context, index) {
                if (index == state.blogs.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Loader(size: 30),
                  );
                } else {
                  return BlogCard(
                    blog: state.blogs[index],
                    color: index % 2 == 0
                        ? AppPallete.gradient1
                        : AppPallete.gradient2,
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
