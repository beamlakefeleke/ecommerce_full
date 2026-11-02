import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/chat/domain/entities/conversation.dart';
import 'package:ecommerce/features/chat/domain/repositories/chat_repository.dart';

class SearchConversationUseCase implements UseCase<ConversationList, String> {
  final ChatRepository repository;
  SearchConversationUseCase(this.repository);

  @override
  Future<Either<Failure, ConversationList>> call(String params) =>
      repository.searchConversationList(params);
}
