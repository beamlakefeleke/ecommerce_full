import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/profile/domain/entities/user_info.dart';
import 'package:image_picker/image_picker.dart';

class ProfileState extends Equatable {
  final bool isLoading;
  final UserInfo? userInfo;
  final String? error;
  final bool isSuccess;
  final String? successMessage;
  final XFile? pickedFile;
  final Uint8List? rawFile;

  const ProfileState({
    this.isLoading = false,
    this.userInfo,
    this.error,
    this.isSuccess = false,
    this.successMessage,
    this.pickedFile,
    this.rawFile,
  });

  ProfileState copyWith({
    bool? isLoading,
    UserInfo? userInfo,
    String? error,
    bool? isSuccess,
    String? successMessage,
    XFile? pickedFile,
    Uint8List? rawFile,
    bool clearPickedFile = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      userInfo: userInfo ?? this.userInfo,
      error: clearError ? null : (error ?? this.error),
      isSuccess: clearSuccess ? false : (isSuccess ?? this.isSuccess),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      pickedFile: clearPickedFile ? null : (pickedFile ?? this.pickedFile),
      rawFile: clearPickedFile ? null : (rawFile ?? this.rawFile),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        userInfo,
        error,
        isSuccess,
        successMessage,
        pickedFile,
        rawFile,
      ];
}
