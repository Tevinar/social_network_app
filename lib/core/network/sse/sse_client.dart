import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/features/auth/data/data_sources/auth_session_store.dart';

abstract interface class SseClient {
  Stream<SseEvent> connect(String path);
}

class SseEvent {
  const SseEvent({
    required this.data,
    this.type,
    this.id,
  });

  final String? type;
  final String? id;
  final Map<String, dynamic> data;
}
