import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/profile/domain/entities/user_info.dart';
import 'package:image_picker/image_picker.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final UserInfo userInfo;
  final XFile? avatar;
  final String token;

  const UpdateProfileEvent(this.userInfo, this.avatar, this.token);

  @override
  List<Object?> get props => [userInfo, avatar, token];
}

class ChangePasswordEvent extends ProfileEvent {
  final UserInfo userInfo;

  const ChangePasswordEvent(this.userInfo);

  @override
  List<Object?> get props => [userInfo];
}

class DeleteUserEvent extends ProfileEvent {}

class PickImageEvent extends ProfileEvent {}
