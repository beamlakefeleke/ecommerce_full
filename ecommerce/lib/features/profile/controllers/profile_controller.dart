import 'dart:typed_data';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_bloc.dart';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_event.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/chat/domain/models/conversation_model.dart';
import 'package:ecommerce/common/models/response_model.dart';
import 'package:ecommerce/features/profile/data/models/userinfo_model.dart';
import 'package:ecommerce/features/profile/domain/repositories/profile_repository.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:ecommerce/helper/network_info.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';

class ProfileController extends GetxController implements GetxService {
  final ProfileRepository profileRepository;
  ProfileController({required this.profileRepository});

  UserInfoModel? _userInfoModel;
  UserInfoModel? get userInfoModel => _userInfoModel;

  XFile? _pickedFile;
  XFile? get pickedFile => _pickedFile;

  Uint8List? _rawFile;
  Uint8List? get rawFile => _rawFile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> getUserInfo() async {
    _pickedFile = null;
    _rawFile = null;
    final result = await profileRepository.getUserInfo();
    result.fold(
      (failure) {
        // Handle failure if necessary
      },
      (userInfo) {
        _userInfoModel = userInfo as UserInfoModel;
      }
    );
    update();
  }

  void setForceFullyUserEmpty() {
    _userInfoModel = null;
    update();
  }

  Future<ResponseModel> updateUserInfo(UserInfoModel updateUserModel, String token) async {
    _isLoading = true;
    update();
    final result = await profileRepository.updateProfile(updateUserModel, _pickedFile, token);
    
    late ResponseModel responseModel;
    result.fold(
      (failure) {
        responseModel = ResponseModel(false, failure.message);
      },
      (userInfo) {
        Get.back();
        responseModel = ResponseModel(true, 'Profile updated successfully');
        _pickedFile = null;
        _rawFile = null;
        getUserInfo();
      }
    );
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> changePassword(UserInfoModel updatedUserModel) async {
    _isLoading = true;
    update();
    final result = await profileRepository.changePassword(updatedUserModel);
    
    late ResponseModel responseModel;
    result.fold(
      (failure) {
        responseModel = ResponseModel(false, failure.message);
      },
      (_) {
        responseModel = ResponseModel(true, 'Password changed successfully');
      }
    );
    _isLoading = false;
    update();
    return responseModel;
  }

  void updateUserWithNewData(User? user) {
    if (_userInfoModel != null) {
      _userInfoModel = UserInfoModel(
        id: _userInfoModel!.id,
        fName: _userInfoModel!.fName,
        lName: _userInfoModel!.lName,
        email: _userInfoModel!.email,
        image: _userInfoModel!.image,
        phone: _userInfoModel!.phone,
        createdAt: _userInfoModel!.createdAt,
        password: _userInfoModel!.password,
        orderCount: _userInfoModel!.orderCount,
        memberSinceDays: _userInfoModel!.memberSinceDays,
        walletBalance: _userInfoModel!.walletBalance,
        loyaltyPoint: _userInfoModel!.loyaltyPoint,
        refCode: _userInfoModel!.refCode,
        socialId: _userInfoModel!.socialId,
        userInfo: user,
      );
      update();
    }
  }

  void pickImage() async {
    _pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if(_pickedFile != null) {
      _pickedFile = await NetworkInfo.compressImage(_pickedFile!);
      _rawFile = await _pickedFile!.readAsBytes();
    }
    update();
  }

  void initData({bool isUpdate = false}) {
    _pickedFile = null;
    _rawFile = null;
    if(isUpdate){
      update();
    }
  }

  Future deleteUser() async {
    _isLoading = true;
    update();
    final result = await profileRepository.deleteUser();
    
    result.fold(
      (failure) {
        Get.back();
        showCustomSnackBar(failure.message, isError: true);
      },
      (_) {
        showCustomSnackBar('User deleted successfully', isError: false);
        Get.find<AuthController>().clearSharedData();
        getIt<FavouriteBloc>().add(const FavouriteLocalCleared());
        Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
      }
    );
    
    _isLoading = false;
    update();
  }

  void clearUserInfo() {
    _userInfoModel = null;
    update();
  }
}
