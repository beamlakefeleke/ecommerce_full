import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/profile/domain/usecases/get_user_info_usecase.dart';
import 'package:ecommerce/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:ecommerce/features/profile/domain/usecases/change_password_usecase.dart';
import 'package:ecommerce/features/profile/domain/usecases/delete_user_usecase.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_event.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_state.dart';
import 'package:ecommerce/helper/network_info.dart';
import 'package:image_picker/image_picker.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserInfoUseCase getUserInfoUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final DeleteUserUseCase deleteUserUseCase;

  ProfileBloc({
    required this.getUserInfoUseCase,
    required this.updateProfileUseCase,
    required this.changePasswordUseCase,
    required this.deleteUserUseCase,
  }) : super(const ProfileState()) {
    on<FetchProfileEvent>(_onFetchProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<ChangePasswordEvent>(_onChangePassword);
    on<DeleteUserEvent>(_onDeleteUser);
    on<PickImageEvent>(_onPickImage);
  }

  Future<void> _onFetchProfile(FetchProfileEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    final result = await getUserInfoUseCase();
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (userInfo) => emit(state.copyWith(isLoading: false, userInfo: userInfo)),
    );
  }

  Future<void> _onUpdateProfile(UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    final result = await updateProfileUseCase(event.userInfo, event.avatar, event.token);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (userInfo) => emit(state.copyWith(
        isLoading: false, 
        isSuccess: true, 
        successMessage: 'Profile updated successfully',
        userInfo: userInfo,
        clearPickedFile: true,
      )),
    );
  }

  Future<void> _onChangePassword(ChangePasswordEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    final result = await changePasswordUseCase(event.userInfo);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (_) => emit(state.copyWith(isLoading: false, isSuccess: true, successMessage: 'Password changed successfully')),
    );
  }

  Future<void> _onDeleteUser(DeleteUserEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    final result = await deleteUserUseCase();
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (_) => emit(state.copyWith(isLoading: false, isSuccess: true, successMessage: 'User deleted successfully')),
    );
  }

  Future<void> _onPickImage(PickImageEvent event, Emitter<ProfileState> emit) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final compressedFile = await NetworkInfo.compressImage(pickedFile);
      final rawFile = await compressedFile.readAsBytes();
      emit(state.copyWith(pickedFile: compressedFile, rawFile: rawFile));
    }
  }
}
