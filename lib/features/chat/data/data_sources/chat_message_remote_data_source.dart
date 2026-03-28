import 'dart:async';

import 'package:social_app/core/constants/supabase_schema/fields/chat_message_fields.dart';
import 'package:social_app/core/constants/supabase_schema/schema_names.dart';
import 'package:social_app/core/constants/supabase_schema/tables.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/exceptions_mapper.dart';
import 'package:social_app/features/chat/data/models/chat_message_model.dart';
import 'package:social_app/features/chat/domain/entities/chat_message_change.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ChatMessageRemoteDataSource {
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

class ChatMessageRemoteDataSourceImpl implements ChatMessageRemoteDataSource {
  SupabaseClient supabaseClient;

  ChatMessageRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<ChatMessageModel>> getChatMessagesPage(
    int pageNumber,
    String chatId,
  ) async {
    return guardRemoteDataSourceCall(() async {
      const int pageSize = 20;
      final int from = (pageNumber - 1) * pageSize;
      final int to = from + pageSize - 1;

      final List<Map<String, dynamic>> rawChatMessages = await supabaseClient
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
      final PostgrestResponse<PostgrestList> response = await supabaseClient
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
        channel = supabaseClient.realtime.channel(
          '${SchemaTypes.public}:${Tables.chatMessages}',
        );

        /// No need to filter by chat here, as the RLS policies will ensure that
        /// only relevant changes are sent to the client.
        channel.onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: SchemaTypes.public,
          table: Tables.chatMessages,
          callback: (payload) async {
            try {
              switch (payload.eventType) {
                case PostgresChangeEvent.insert:
                  controller.add(
                    ChatMessageInserted(
                      ChatMessageModel.fromJson(payload.newRecord).toEntity(),
                    ),
                  );
                  break;

                case PostgresChangeEvent.update:
                  controller.add(
                    ChatMessageUpdated(
                      ChatMessageModel.fromJson(payload.newRecord).toEntity(),
                    ),
                  );
                  break;

                case PostgresChangeEvent.delete:
                  final String deletedMessageId = payload.oldRecord[ChatMessageFields.id] as String;
                  controller.add(
                    ChatMessageDeleted(deletedMessageId),
                  );
                  break;

                case PostgresChangeEvent.all:
                  // Not emitted as a payload event, but required for exhaustiveness
                  break;
              }
            } catch (e, stack) {
              controller.addError(
                ServerException(message: e.toString()),
                stack,
              );
            }
          },
        );

        channel.subscribe();
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
