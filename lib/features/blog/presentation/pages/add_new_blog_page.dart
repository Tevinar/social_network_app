import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/core/utils/pick_image.dart';
import 'package:social_app/core/utils/show_snackbar.dart';
import 'package:social_app/core/widgets/loader.dart';
import 'package:social_app/features/blog/domain/entities/blog_topic.dart';
import 'package:social_app/features/blog/presentation/blocs/blog_editor/blog_editor_bloc.dart';
import 'package:social_app/features/blog/presentation/widgets/blog_editor.dart';

/// A add new blog page widget.
class AddNewBlogPage extends StatefulWidget {
  /// Creates a [AddNewBlogPage].
  const AddNewBlogPage({super.key});

  @override
  State<AddNewBlogPage> createState() => _AddNewBlogPageState();
}

class _AddNewBlogPageState extends State<AddNewBlogPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<BlogTopic> selectedTopics = [];
  File? image;
  bool _isImagePickerLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          _buildBlocAction(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                _buildImageSection(),
                const SizedBox(height: 20),
                _buildTopicsSelector(),
                const SizedBox(height: 10),
                BlogEditor(controller: titleController, hintText: 'Blog title'),
                const SizedBox(height: 10),
                BlogEditor(
                  controller: contentController,
                  hintText: 'Blog content',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlocAction() {
    return BlocConsumer<BlogEditorBloc, BlogEditorState>(
      listener: (context, state) {
        if (state is BlogFailure) {
          showSnackBar(context, state.error);
        } else if (state is BlogUploadSuccess) {
          context.pop(true);
        }
      },
      builder: (context, state) {
        if (state is BlogLoading) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Loader(size: 20),
          );
        }
        return IconButton(
          onPressed: _uploadBlog,
          icon: const Icon(Icons.done_rounded),
        );
      },
    );
  }

  void _uploadBlog() {
    if (image == null) {
      showSnackBar(context, 'Please select an image');
      return;
    }
    if (selectedTopics.isEmpty) {
      showSnackBar(context, 'Please select at least one topic');
      return;
    }
    if (!formKey.currentState!.validate()) {
      return;
    }
    final state = context.read<AppUserCubit>().state;
    if (state is! AppUserSignedIn) {
      showSnackBar(context, 'You must be signed in to add a blog');
      return;
    }

    context.read<BlogEditorBloc>().add(
      AddBlog(
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        topics: selectedTopics,
        image: image!,
        posterId: state.user.id,
        posterName: state.user.name,
      ),
    );
  }

  Widget _buildImageSection() {
    if (image != null) {
      return GestureDetector(
        onTap: _selectImage,
        child: SizedBox(
          height: 150,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(10),
            child: _isImagePickerLoading
                ? const Loader()
                : Image.file(image!, fit: BoxFit.cover),
          ),
        ),
      );
    } else {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _selectImage,
        child: DottedBorder(
          options: const RoundedRectDottedBorderOptions(
            dashPattern: [10, 4],
            color: AppPallete.borderColor,
            radius: Radius.circular(10),
            strokeCap: StrokeCap.round,
          ),
          child: SizedBox(
            height: 150,
            width: double.infinity,
            child: _isImagePickerLoading
                ? const Loader()
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 40),
                      SizedBox(height: 15),
                      Text(
                        'Select your image',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
          ),
        ),
      );
    }
  }

  Future<void> _selectImage() async {
    if (_isImagePickerLoading) return;

    setState(() {
      _isImagePickerLoading = true;
    });

    try {
      final pickedImage = await pickImage();

      if (!mounted) return;

      if (pickedImage != null) {
        setState(() {
          image = pickedImage;
        });
      }
    } on Exception catch (error, stackTrace) {
      appLogger.error(
        'Failed to pick image from gallery',
        error: error,
        stackTrace: stackTrace,
      );

      if (mounted) {
        showSnackBar(context, 'Failed to pick image');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImagePickerLoading = false;
        });
      }
    }
  }

  Widget _buildTopicsSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: BlogTopic.values
            .map(
              (e) => Padding(
                padding: const EdgeInsetsGeometry.all(5),
                child: GestureDetector(
                  onTap: () {
                    if (selectedTopics.contains(e)) {
                      selectedTopics.remove(e);
                    } else {
                      selectedTopics.add(e);
                    }
                    setState(() {});
                  },
                  child: Chip(
                    label: Text(e.value),
                    color: selectedTopics.contains(e)
                        ? const WidgetStatePropertyAll(
                            AppPallete.gradient1,
                          )
                        : null,
                    side: selectedTopics.contains(e)
                        ? null
                        : const BorderSide(
                            color: AppPallete.borderColor,
                          ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
