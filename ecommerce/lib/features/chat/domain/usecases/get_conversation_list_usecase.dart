import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/chat/domain/entities/conversation.dart';
import 'package:ecommerce/features/chat/domain/repositories/chat_repository.dart';

class GetConversationListParams extends Equatable {
  final int offset;
  final String type;
  const GetConversationListParams({required this.offset, this.type = ''});
  @override
  List<Object?> get props => [offset, type];
}

class GetConversationListUseCase
    implements UseCase<ConversationList, GetConversationListParams> {
  final ChatRepository repository;
  GetConversationListUseCase(this.repository);

  @override
  Future<Either<Failure, ConversationList>> call(
    GetConversationListParams params,
  ) => repository.getConversationList(params.offset, params.type);
}
