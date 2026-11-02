import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/chat/domain/entities/conversation.dart';
import 'package:ecommerce/features/chat/domain/repositories/chat_repository.dart';

class GetMessagesParams extends Equatable {
  final int offset;
  final int? userId;
  final String userType;
  final int? conversationId;
  const GetMessagesParams({
    required this.offset,
    this.userId,
    required this.userType,
    this.conversationId,
  });
  @override
  List<Object?> get props => [offset, userId, userType, conversationId];
}

class GetMessagesUseCase implements UseCase<ChatMessages, GetMessagesParams> {
  final ChatRepository repository;
  GetMessagesUseCase(this.repository);

  @override
  Future<Either<Failure, ChatMessages>> call(GetMessagesParams params) =>
      repository.getMessages(
        params.offset,
        params.userId,
        params.userType,
        params.conversationId,
      );
}
