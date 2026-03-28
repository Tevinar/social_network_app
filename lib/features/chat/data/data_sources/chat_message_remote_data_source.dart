import 'dart:async';

import 'package:social_app/core/constants/supabase_schema/fields/'
    'chat_message_fields.dart';
import 'package:social_app/core/constants/supabase_schema/schema_names.dart';
import 'package:social_app/core/constants/supabase_schema/tables.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/exceptions_mapper.dart';
import 'package:social_app/features/chat/data/models/chat_message_model.dart';
import 'package:social_app/features/chat/domain/entities/'
    'chat_message_change.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A chat message remote data source.
abstract interface class ChatMessageRemoteDataSource {
  /// The post chat message.
  Future<void> postChatMessage({
    required String chatId,
    required String content,
  });

  /// Fetches a paginated list of chatMessages ordered by last activity.
  Future<List<ChatMessageModel>> getChatMessagesPage(
    int pageNumber,
    String chatId,
  );

  /// Returns the total number of chatMessages in the database.
  Future<int> getChatMessagesCount(String chatId);

  /// Emits chatMessage insert/update/delete events in realtime.
  Stream<ChatMessageChange> watchChatMessageChanges();
}

/// A chat message remote data source impl.
class ChatMessageRemoteDataSourceImpl implements ChatMessageRemoteDataSource {
  /// Creates a [ChatMessageRemoteDataSourceImpl].
  ChatMessageRemoteDataSourceImpl({required this.supabaseClient});

  /// The supabase client.
  SupabaseClient supabaseClient;

  @override
  Future<List<ChatMessageModel>> getChatMessagesPage(
    int pageNumber,
    String chatId,
  ) async {
    return guardRemoteDataSourceCall(() async {
      const pageSize = 20;
      final from = (pageNumber - 1) * pageSize;
      final to = from + pageSize - 1;

      final rawChatMessages = await supabaseClient
          .from(Tables.chatMessages)
          .select()
          .eq(ChatMessageFields.chatId, chatId)
          .range(from, to)
          .order(ChatMessageFields.createdAt, ascending: false);
      return rawChatMessages.map(ChatMessageModel.fromJson).toList();
    });
  }

  @override
  Future<int> getChatMessagesCount(String chatId) async {
    return guardRemoteDataSourceCall(() async {
      final response = await supabaseClient
          .from(Tables.chatMessages)
          .select()
          .eq(ChatMessageFields.chatId, chatId)
          .count();

      return response.count;
    });
  }

  @override
  Stream<ChatMessageChange> watchChatMessageChanges() {
    late final StreamController<ChatMessageChange> controller;
    late final RealtimeChannel channel;

    controller = StreamController<ChatMessageChange>(
      onListen: () {
        channel =
            supabaseClient.realtime.channel(
                '${SchemaTypes.public}:${Tables.chatMessages}',
              )
              // No need to filter by chat here, as the RLS policies will
              // ensure that only relevant changes are sent to the client.
              ..onPostgresChanges(
                event: PostgresChangeEvent.all,
                schema: SchemaTypes.public,
                table: Tables.chatMessages,
                callback: (payload) async {
                  try {
                    switch (payload.eventType) {
                      case PostgresChangeEvent.insert:
                        final model = ChatMessageModel.fromJson(
                          payload.newRecord,
                        );
                        controller.add(
                          ChatMessageInserted(
                            chatId: model.chatId,
                            chatMessage: model.toEntity(),
                          ),
                        );

                      case PostgresChangeEvent.update:
                        final model = ChatMessageModel.fromJson(
                          payload.newRecord,
                        );

                        controller.add(
                          ChatMessageUpdated(
                            chatId: model.chatId,
                            chatMessage: model.toEntity(),
                          ),
                        );

                      case PostgresChangeEvent.delete:
                        controller.add(
                          ChatMessageDeleted(
                            chatId:
                                payload.oldRecord[ChatMessageFields.chatId]
                                    as String,
                            chatMessageId:
                                payload.oldRecord[ChatMessageFields.id]
                                    as String,
                          ),
                        );

                      case PostgresChangeEvent.all:
                        // Required for exhaustive handling
                        // but never emitted here.
                        break;
                    }
                  } on Exception catch (e, stack) {
                    controller.addError(
                      ServerException(message: e.toString()),
                      stack,
                    );
                  }
                },
              )
              ..subscribe();
      },
      onCancel: () async {
        await channel.unsubscribe();
        await controller.close();
      },
    );

    return controller.stream;
  }

  @override
  Future<void> postChatMessage({
    required String chatId,
    required String content,
  }) {
    return guardRemoteDataSourceCall(() async {
      await supabaseClient.from(Tables.chatMessages).insert({
        ChatMessageFields.chatId: chatId,
        ChatMessageFields.content: content,
      });
    });
  }
}
