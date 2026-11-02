import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/chat/domain/entities/conversation.dart';

/// Abstract contract for the chat feature. Implemented in the data layer.
abstract class ChatRepository {
  Future<Either<Failure, ConversationList>> getConversationList(
    int offset,
    String type,
  );

  Future<Either<Failure, ConversationList>> searchConversationList(String name);

  Future<Either<Failure, ChatMessages>> getMessages(
    int offset,
    int? userId,
    String userType,
    int? conversationId,
  );

  Future<Either<Failure, ChatMessages>> sendMessage(
    String message,
    List<MultipartBody> images,
    int? userId,
    String userType,
    int? conversationId,
  );

  /// Image helpers delegated to the data source (compression + multipart
  /// packaging). Kept on the repository so usecases stay data-agnostic.
  Future<XFile> compressImage(XFile file);
  List<MultipartBody> processMultipartBody(List<XFile> images);
}
