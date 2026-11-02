import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:ecommerce/features/chat/domain/entities/conversation.dart';
import 'package:ecommerce/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ConversationList>> getConversationList(
    int offset,
    String type,
  ) => _guard(
    () async =>
        (await remoteDataSource.getConversationList(offset, type)).toEntity(),
  );

  @override
  Future<Either<Failure, ConversationList>> searchConversationList(
    String name,
  ) => _guard(
    () async =>
        (await remoteDataSource.searchConversationList(name)).toEntity(),
  );

  @override
  Future<Either<Failure, ChatMessages>> getMessages(
    int offset,
    int? userId,
    String userType,
    int? conversationId,
  ) => _guard(
    () async => (await remoteDataSource.getMessages(
      offset,
      userId,
      userType,
      conversationId,
    )).toEntity(),
  );

  @override
  Future<Either<Failure, ChatMessages>> sendMessage(
    String message,
    List<MultipartBody> images,
    int? userId,
    String userType,
    int? conversationId,
  ) => _guard(
    () async => (await remoteDataSource.sendMessage(
      message,
      images,
      userId,
      userType,
      conversationId,
    )).toEntity(),
  );

  @override
  Future<XFile> compressImage(XFile file) =>
      remoteDataSource.compressImage(file);

  @override
  List<MultipartBody> processMultipartBody(List<XFile> images) =>
      remoteDataSource.processMultipartBody(images);

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Right(await body());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
