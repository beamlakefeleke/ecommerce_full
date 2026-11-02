import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/chat/domain/entities/conversation.dart';
import 'package:ecommerce/features/chat/domain/repositories/chat_repository.dart';

class SendMessageParams extends Equatable {
  final String message;
  final List<XFile> images;
  final int? userId;
  final String userType;
  final int? conversationId;
  final int? index;
  const SendMessageParams({
    required this.message,
    required this.images,
    this.userId,
    required this.userType,
    this.conversationId,
    this.index,
  });
  @override
  List<Object?> get props => [message, userId, userType, conversationId];
}

class SendMessageUseCase implements UseCase<ChatMessages, SendMessageParams> {
  final ChatRepository repository;
  SendMessageUseCase(this.repository);

  @override
  Future<Either<Failure, ChatMessages>> call(SendMessageParams params) {
    final List<MultipartBody> multiparts = repository.processMultipartBody(
      params.images,
    );
    return repository.sendMessage(
      params.message,
      multiparts,
      params.userId,
      params.userType,
      params.conversationId,
    );
  }
}
