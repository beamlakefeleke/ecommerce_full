import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/profile/domain/usecases/profile_usecases.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_event.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_state.dart';
import 'package:ecommerce/helper/network_info.dart';

/// App-wide bloc: [ProfileState.userInfoModel] is read across checkout, chat,
/// loyalty, menu, home and the profile screens. Input is only via `add(Event)`;
/// no navigation/snackbars live here (the UI reacts to [actionStatus] /
/// [actionType] through a `BlocListener`).
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserInfoUseCase getUserInfo;
  final UpdateProfileUseCase updateProfile;
  final ChangePasswordUseCase changePassword;
  final DeleteUserUseCase deleteUser;

  ProfileBloc({
    required this.getUserInfo,
    required this.updateProfile,
    required this.changePassword,
    required this.deleteUser,
  }) : super(const ProfileState()) {
    on<ProfileInfoRequested>(_onInfoRequested);
    on<ProfileImageReset>(_onImageReset);
    on<ProfileImagePicked>(_onImagePicked);
    on<ProfileUpdated>(_onUpdated);
    on<ProfilePasswordChanged>(_onPasswordChanged);
    on<ProfileAccountDeleted>(_onAccountDeleted);
    on<ProfileCleared>(_onCleared);
  }

  Future<void> _onInfoRequested(
    ProfileInfoRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading, clearPickedFile: true));
    final result = await getUserInfo(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(
        state.copyWith(status: ProfileStatus.loaded, userInfoModel: user),
      ),
    );
  }

  void _onImageReset(ProfileImageReset event, Emitter<ProfileState> emit) {
    emit(state.copyWith(clearPickedFile: true));
  }

  Future<void> _onImagePicked(
    ProfileImagePicked event,
    Emitter<ProfileState> emit,
  ) async {
    XFile? picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      picked = await NetworkInfo.compressImage(picked);
      final raw = await picked.readAsBytes();
      emit(state.copyWith(pickedFile: picked, rawFile: raw));
    }
  }

  Future<void> _onUpdated(
    ProfileUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        actionStatus: ProfileActionStatus.inProgress,
        actionType: ProfileActionType.update,
      ),
    );
    final result = await updateProfile(
      UpdateProfileParams(
        userInfoModel: event.updatedUser,
        pickedImage: state.pickedFile,
      ),
    );
    await result.fold(
      (failure) async => emit(
        state.copyWith(
          actionStatus: ProfileActionStatus.failure,
          actionType: ProfileActionType.update,
          actionMessage: failure.message,
        ),
      ),
      (response) async {
        if (response.isSuccess) {
          emit(
            state.copyWith(
              actionStatus: ProfileActionStatus.success,
              actionType: ProfileActionType.update,
              actionMessage: response.message,
              clearPickedFile: true,
            ),
          );
          // Refresh the cached user after a successful update.
          final refreshed = await getUserInfo(const NoParams());
          refreshed.fold(
            (_) {},
            (user) => emit(
              state.copyWith(status: ProfileStatus.loaded, userInfoModel: user),
            ),
          );
        } else {
          emit(
            state.copyWith(
              actionStatus: ProfileActionStatus.failure,
              actionType: ProfileActionType.update,
              actionMessage: response.message,
            ),
          );
        }
      },
    );
  }

  Future<void> _onPasswordChanged(
    ProfilePasswordChanged event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        actionStatus: ProfileActionStatus.inProgress,
        actionType: ProfileActionType.changePassword,
      ),
    );
    final result = await changePassword(event.updatedUser);
    result.fold(
      (failure) => emit(
        state.copyWith(
          actionStatus: ProfileActionStatus.failure,
          actionType: ProfileActionType.changePassword,
          actionMessage: failure.message,
        ),
      ),
      (response) => emit(
        state.copyWith(
          actionStatus: response.isSuccess
              ? ProfileActionStatus.success
              : ProfileActionStatus.failure,
          actionType: ProfileActionType.changePassword,
          actionMessage: response.message,
        ),
      ),
    );
  }

  Future<void> _onAccountDeleted(
    ProfileAccountDeleted event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        actionStatus: ProfileActionStatus.inProgress,
        actionType: ProfileActionType.delete,
      ),
    );
    final result = await deleteUser(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          actionStatus: ProfileActionStatus.failure,
          actionType: ProfileActionType.delete,
          actionMessage: failure.message,
        ),
      ),
      (response) => emit(
        state.copyWith(
          actionStatus: response.isSuccess
              ? ProfileActionStatus.success
              : ProfileActionStatus.failure,
          actionType: ProfileActionType.delete,
          actionMessage: response.message,
          clearUserInfo: response.isSuccess,
        ),
      ),
    );
  }

  void _onCleared(ProfileCleared event, Emitter<ProfileState> emit) {
    emit(state.copyWith(clearUserInfo: true, clearPickedFile: true));
  }
}
