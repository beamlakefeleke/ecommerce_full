import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/profile/domain/models/userinfo_model.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or refresh) the signed-in user's info.
class ProfileInfoRequested extends ProfileEvent {
  const ProfileInfoRequested();
}

/// Reset the picked-image working state (old `initData`).
class ProfileImageReset extends ProfileEvent {
  const ProfileImageReset();
}

/// Pick + compress a new avatar from the gallery.
class ProfileImagePicked extends ProfileEvent {
  const ProfileImagePicked();
}

/// Submit edited profile fields (uses the currently picked image, if any).
class ProfileUpdated extends ProfileEvent {
  final UserInfoModel updatedUser;

  const ProfileUpdated(this.updatedUser);

  @override
  List<Object?> get props => [updatedUser];
}

class ProfilePasswordChanged extends ProfileEvent {
  final UserInfoModel updatedUser;

  const ProfilePasswordChanged(this.updatedUser);

  @override
  List<Object?> get props => [updatedUser];
}

class ProfileAccountDeleted extends ProfileEvent {
  const ProfileAccountDeleted();
}

/// Clear the cached user info (logout).
class ProfileCleared extends ProfileEvent {
  const ProfileCleared();
}
