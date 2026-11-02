import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get_connect/connect.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/features/chat/data/models/chat_model.dart';
import 'package:ecommerce/features/chat/data/models/conversation_model.dart';
import 'package:ecommerce/features/chat/enums/user_type_enum.dart';
import 'package:ecommerce/util/app_constants.dart';

abstract class ChatRemoteDataSource {
  Future<ConversationsModel> getConversationList(int offset, String type);
  Future<ConversationsModel> searchConversationList(String name);
  Future<ChatModel> getMessages(
    int offset,
    int? userId,
    String userType,
    int? conversationId,
  );
  Future<ChatModel> sendMessage(
    String message,
    List<MultipartBody> images,
    int? userId,
    String userType,
    int? conversationId,
  );
  Future<XFile> compressImage(XFile file);
  List<MultipartBody> processMultipartBody(List<XFile> images);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient apiClient;
  ChatRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ConversationsModel> getConversationList(
    int offset,
    String type,
  ) async {
    final Response response = await apiClient.getData(
      '${AppConstants.conversationListUri}?limit=10&offset=$offset&type=$type',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return ConversationsModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<ConversationsModel> searchConversationList(String name) async {
    final Response response = await apiClient.getData(
      '${AppConstants.searchConversationListUri}?name=$name&limit=20&offset=1',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return ConversationsModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<ChatModel> getMessages(
    int offset,
    int? userId,
    String userType,
    int? conversationId,
  ) async {
    final String query = conversationId != null
        ? 'conversation_id=$conversationId'
        : userType == UserType.admin.name
        ? 'admin_id=$userId'
        : userType == UserType.vendor.name
        ? 'vendor_id=$userId'
        : 'delivery_man_id=$userId';
    final Response response = await apiClient.getData(
      '${AppConstants.messageListUri}?$query&offset=$offset&limit=10',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return ChatModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<ChatModel> sendMessage(
    String message,
    List<MultipartBody> images,
    int? userId,
    String userType,
    int? conversationId,
  ) async {
    final Map<String, String> fields = {
      'message': message,
      'receiver_type': userType,
      'offset': '1',
      'limit': '10',
    };
    if (conversationId != null) {
      fields['conversation_id'] = conversationId.toString();
    } else {
      fields['receiver_id'] = userId.toString();
    }
    final Response response = await apiClient.postMultipartData(
      AppConstants.sendMessageUri,
      fields,
      images,
      handleError: false,
    );
    if (response.statusCode == 200) {
      return ChatModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<XFile> compressImage(XFile file) async {
    try {
      final Uint8List? result = await FlutterImageCompress.compressWithFile(
        file.path,
        quality: 40,
      );
      if (result != null) {
        return XFile.fromData(result);
      }
    } catch (_) {}
    return file;
  }

  @override
  List<MultipartBody> processMultipartBody(List<XFile> images) {
    return images.map((img) => MultipartBody('image[]', img)).toList();
  }

  Exception _exceptionFor(Response response) {
    if (response.statusCode == null ||
        response.statusCode == 0 ||
        response.statusCode == 1) {
      return NetworkException(response.statusText ?? 'No internet connection');
    }
    return ServerException(response.statusText ?? 'Server error');
  }
}
