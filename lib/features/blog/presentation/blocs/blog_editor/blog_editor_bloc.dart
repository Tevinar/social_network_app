import 'dart:io';

import 'package:social_network_app/core/errors/failures.dart';
import 'package:social_network_app/features/blog/domain/entities/blog.dart';
import 'package:social_network_app/features/blog/domain/usecases/create_blog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'blog_editor_event.dart';
part 'blog_editor_state.dart';

class BlogEditorBloc extends Bloc<BlogEditorEvent, BlogEditorState> {
  final CreateBlog _uploadBlog;
  BlogEditorBloc({required CreateBlog uploadBlog})
    : _uploadBlog = uploadBlog,
      super(BlogInitial()) {
    on<BlogEditorEvent>((event, emit) => emit(BlogLoading()));
    on<AddBlog>(_onAddBlog);
  }

  void _onAddBlog(AddBlog event, Emitter<BlogEditorState> emit) async {
    Either<Failure, Blog> res = await _uploadBlog.call(
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
