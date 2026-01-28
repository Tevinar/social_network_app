import 'package:bloc_app/app_navigation_bar.dart';
import 'package:bloc_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:bloc_app/core/common/widgets/loader.dart';
import 'package:bloc_app/core/theme/app_pallete.dart';
import 'package:bloc_app/core/utils/show_snackbar.dart';
import 'package:bloc_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bloc_app/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:bloc_app/features/blog/presentation/widgets/blog_card.dart';
import 'package:bloc_app/routing/router_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  @override
  void initState() {
    super.initState();
    context.read<BlogBloc>().add(BlogGetAll());
    BlocProvider.of<AppUserCubit>(context).state;
  }

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
              onPressed: () {
                BlocProvider.of<AuthBloc>(context).add(AuthSignOut());
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
        title: const Text('Blog App'),
        actions: [
          IconButton(
            onPressed: () {
              const AddNewBlogPageRoute().go(context);
            },
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogFailure) {
            showSnackBar(context, state.error);
          }
        },
        builder: (context, state) {
          if (state is BlogLoading) {
            return const Loader();
          } else if (state is BlogsDisplaySuccess) {
            return ListView.builder(
              itemCount: state.blogs.length,
              itemBuilder: (context, index) {
                final blog = state.blogs[index];
                return BlogCard(
                  blog: blog,
                  color: index % 2 == 0
                      ? AppPallete.gradient1
                      : AppPallete.gradient2,
                );
              },
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
