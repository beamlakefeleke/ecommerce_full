import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/features/profile/domain/models/userinfo_model.dart';

enum ProfileStatus { initial, loading, loaded, error }

/// Outcome of the last mutating action. One-shot: the UI reacts via a
/// `BlocListener` (snackbar / pop / navigate) keyed on the transition.
enum ProfileActionStatus { none, inProgress, success, failure }

/// Which mutation produced the current [ProfileActionStatus], so the UI can
/// react differently (update pops the screen, delete navigates to sign-in).
enum ProfileActionType { none, update, changePassword, delete }

/// Single immutable state. A status enum is used (not a sealed hierarchy)
/// because the loaded [userInfoModel] + picked-image working state must survive
/// across the update / change-password / delete actions (rule 6).
class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserInfoModel? userInfoModel;
  final XFile? pickedFile;
  final Uint8List? rawFile;
  final ProfileActionStatus actionStatus;
  final ProfileActionType actionType;

  /// User-facing message for the last action (success or failure).
  final String? actionMessage;

  /// Error message for a failed info load.
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.userInfoModel,
    this.pickedFile,
    this.rawFile,
    this.actionStatus = ProfileActionStatus.none,
    this.actionType = ProfileActionType.none,
    this.actionMessage,
    this.errorMessage,
  });

  bool get isLoading => actionStatus == ProfileActionStatus.inProgress;

  ProfileState copyWith({
    ProfileStatus? status,
    UserInfoModel? userInfoModel,
    bool clearUserInfo = false,
    XFile? pickedFile,
    bool clearPickedFile = false,
    Uint8List? rawFile,
    ProfileActionStatus? actionStatus,
    ProfileActionType? actionType,
    String? actionMessage,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      userInfoModel: clearUserInfo
          ? null
          : (userInfoModel ?? this.userInfoModel),
      pickedFile: clearPickedFile ? null : (pickedFile ?? this.pickedFile),
      rawFile: clearPickedFile ? null : (rawFile ?? this.rawFile),
      actionStatus: actionStatus ?? this.actionStatus,
      actionType: actionType ?? this.actionType,
      actionMessage: actionMessage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    userInfoModel,
    pickedFile,
    rawFile,
    actionStatus,
    actionType,
    actionMessage,
    errorMessage,
  ];
}
