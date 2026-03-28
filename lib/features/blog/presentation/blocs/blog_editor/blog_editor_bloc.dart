import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/blog/domain/usecases/create_blog.dart';

part 'blog_editor_event.dart';
part 'blog_editor_state.dart';

/// A blog editor bloc.
class BlogEditorBloc extends Bloc<BlogEditorEvent, BlogEditorState> {
  /// Creates a [BlogEditorBloc].
  BlogEditorBloc({required CreateBlog uploadBlog})
    : _uploadBlog = uploadBlog,
      super(BlogInitial()) {
    on<BlogEditorEvent>((event, emit) => emit(BlogLoading()));
    on<AddBlog>(_onAddBlog);
  }
  final CreateBlog _uploadBlog;

  Future<void> _onAddBlog(AddBlog event, Emitter<BlogEditorState> emit) async {
    final res = await _uploadBlog.call(
      CreateBlogParams(
        posterId: event.posterId,
        title: event.title,
        content: event.content,
        image: event.image,
        topics: event.topics,
      ),
    );
    res.fold(
      (l) => emit(BlogFailure(l.message)),
      (r) => emit(BlogUploadSuccess()),
    );
  }
}
