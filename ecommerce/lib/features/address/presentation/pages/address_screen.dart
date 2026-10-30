import 'package:ecommerce/features/address/data/models/address_model.dart';
import 'package:ecommerce/features/address/domain/entities/address.dart';
import 'package:ecommerce/features/address/presentation/bloc/address_bloc.dart';
import 'package:ecommerce/features/address/presentation/bloc/address_event.dart';
import 'package:ecommerce/features/address/presentation/bloc/address_state.dart';
import 'package:ecommerce/features/address/presentation/widgets/address_confirmation_dialogue.dart';
import 'package:ecommerce/common/widgets/address_widget.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_app_bar.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';
import 'package:ecommerce/common/widgets/no_data_screen.dart';
import 'package:ecommerce/common/widgets/not_logged_in_screen.dart';
import 'package:ecommerce/common/widgets/web_page_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

/// Migrated to Clean Architecture + BLoC. Reads the app-wide [AddressBloc]
/// provided in `main.dart`. The widget's public API
/// (`AddressScreen({fromDashboard})`) is unchanged so routing and the
/// dashboard embed keep working.
class AddressScreen extends StatefulWidget {
  final bool fromDashboard;
  const AddressScreen({super.key, this.fromDashboard = false});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    if (AuthHelper.isLoggedIn()) {
      context.read<AddressBloc>().add(const AddressListRequested());
    }
  }

  void _confirmDelete(Address address, int index) {
    if (Get.isSnackbarOpen) {
      Get.back();
    }
    final bloc = context.read<AddressBloc>();
    Get.dialog(
      AddressConfirmDialogue(
        icon: Images.locationConfirm,
        title: 'are_you_sure'.tr,
        description: 'you_want_to_delete_this_location'.tr,
        onYesPressed: () {
          bloc.add(AddressDeleted(id: address.id, index: index));
          Get.back();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = AuthHelper.isLoggedIn();
    return BlocConsumer<AddressBloc, AddressState>(
      listenWhen: (prev, curr) =>
          prev.actionStatus != curr.actionStatus &&
          (curr.actionStatus == AddressActionStatus.success ||
              curr.actionStatus == AddressActionStatus.failure),
      listener: (context, state) {
        if (state.actionMessage != null) {
          showCustomSnackBar(
            state.actionMessage,
            isError: state.actionStatus == AddressActionStatus.failure,
          );
        }
      },
      builder: (context, state) {
        final List<Address> addressList = state.addresses;
        final bool loaded = state.status == AddressStatus.loaded;
        final bool showList = loaded || state.status == AddressStatus.error;
        return Scaffold(
          appBar: CustomAppBar(
            title: 'my_address'.tr,
            backButton: widget.fromDashboard ? false : true,
          ),
          endDrawer: const MenuDrawer(),
          endDrawerEnableOpenDragGesture: false,
          floatingActionButton:
              ResponsiveHelper.isDesktop(context) || !isLoggedIn
              ? null
              : (loaded && addressList.isEmpty)
              ? null
              : FloatingActionButton(
                  backgroundColor: Theme.of(context).primaryColor,
                  onPressed: () => Get.toNamed(
                    RouteHelper.getAddAddressRoute(
                      false,
                      false,
                      0,
                      isNavbar: true,
                    ),
                  ),
                  child: Icon(Icons.add, color: Theme.of(context).cardColor),
                ),
          floatingActionButtonLocation: ResponsiveHelper.isDesktop(context)
              ? FloatingActionButtonLocation.centerFloat
              : null,
          body: Container(
            height: context.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  ResponsiveHelper.isDesktop(context)
                      ? Images.addressCity
                      : Images.city,
                ),
                alignment: ResponsiveHelper.isDesktop(context)
                    ? Alignment.center
                    : Alignment.bottomCenter,
                fit: BoxFit.fitWidth,
              ),
            ),
            child: isLoggedIn
                ? RefreshIndicator(
                    onRefresh: () async {
                      context.read<AddressBloc>().add(
                        const AddressListRequested(),
                      );
                    },
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          WebScreenTitleWidget(title: 'address'.tr),
                          Center(
                            child: FooterView(
                              child: SizedBox(
                                width: Dimensions.webMaxWidth,
                                child: Column(
                                  children: [
                                    ResponsiveHelper.isDesktop(context)
                                        ? const SizedBox(
                                            height: Dimensions.paddingSizeSmall,
                                          )
                                        : const SizedBox(),

                                    showList
                                        ? addressList.isNotEmpty
                                              ? _buildGrid(context, addressList)
                                              : NoDataScreen(
                                                  text: 'no_saved_address_found'
                                                      .tr,
                                                  fromAddress: true,
                                                )
                                        : const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : NotLoggedInScreen(
                    callBack: (value) {
                      _reload();
                      setState(() {});
                    },
                  ),
          ),
          bottomNavigationBar: widget.fromDashboard
              ? Container(height: GetPlatform.isIOS ? 80 : 65)
              : const SizedBox(),
        );
      },
    );
  }

  Widget _buildGrid(BuildContext context, List<Address> addressList) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Padding(
      padding: ResponsiveHelper.isMobile(context)
          ? const EdgeInsets.all(Dimensions.paddingSizeSmall)
          : EdgeInsets.zero,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: Dimensions.paddingSizeLarge,
          mainAxisSpacing: isDesktop ? Dimensions.paddingSizeLarge : 0.01,
          childAspectRatio: isDesktop ? 4 : 4.8,
          crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 3,
        ),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: isDesktop ? (addressList.length + 1) : addressList.length,
        itemBuilder: (context, index) {
          if (isDesktop && index == addressList.length) {
            return _buildAddCard(context);
          }
          final address = addressList[index];
          final model = AddressModel.fromEntity(address);
          return AddressWidget(
            address: model,
            fromAddress: true,
            onTap: () {
              Get.toNamed(RouteHelper.getMapRoute(model, 'address', false));
            },
            onEditPressed: () {
              Get.toNamed(RouteHelper.getEditAddressRoute(model));
            },
            onRemovePressed: () => _confirmDelete(address, index),
          );
        },
      ),
    );
  }

  Widget _buildAddCard(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(RouteHelper.getAddAddressRoute(false, false, 0)),
      child: Container(
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              'add_new_address'.tr,
              style: robotoRegular.copyWith(
                color: Theme.of(context).primaryColor,
                fontSize: Dimensions.fontSizeSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
