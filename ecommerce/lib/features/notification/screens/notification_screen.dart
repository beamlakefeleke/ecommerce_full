import 'package:ecommerce/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:ecommerce/features/notification/presentation/bloc/notification_event.dart';
import 'package:ecommerce/features/notification/presentation/bloc/notification_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/date_converter.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_app_bar.dart';
import 'package:ecommerce/common/widgets/custom_image.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';
import 'package:ecommerce/common/widgets/no_data_screen.dart';
import 'package:ecommerce/common/widgets/not_logged_in_screen.dart';
import 'package:ecommerce/features/notification/widgets/notification_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatefulWidget {
  final bool fromNotification;
  const NotificationScreen({super.key, this.fromNotification = false});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  void _loadData() async {
    getIt<NotificationBloc>().add(const NotificationCleared());
    if(Get.find<SplashController>().configModel == null) {
      await Get.find<SplashController>().getConfigData();
    }
    if(AuthHelper.isLoggedIn()) {
      getIt<NotificationBloc>().add(const NotificationListFetched());
    }
  }

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if(widget.fromNotification) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        } else {
          return;
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'notification'.tr, onBackPressed: () {
          if(widget.fromNotification){
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }else{
            Get.back();
          }
        }),
        endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
        body: AuthHelper.isLoggedIn() ? BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
          if(state.notifications != null) {
            getIt<NotificationBloc>().add(NotificationSeenCountSaved(state.notifications!.length));
          }
          List<DateTime> dateTimeList = [];
          return state.notifications != null ? state.notifications!.isNotEmpty ? RefreshIndicator(
            onRefresh: () async {
              getIt<NotificationBloc>().add(const NotificationListFetched());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: FooterView(
                child: SizedBox(width: Dimensions.webMaxWidth, child: ListView.builder(
                  itemCount: state.notifications!.length,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    DateTime originalDateTime = DateConverter.dateTimeStringToDate(state.notifications![index].createdAt!);
                    DateTime convertedDate = DateTime(originalDateTime.year, originalDateTime.month, originalDateTime.day);
                    bool addTitle = false;
                    if(!dateTimeList.contains(convertedDate)) {
                      addTitle = true;
                      dateTimeList.add(convertedDate);
                    }
                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      addTitle ? Padding(
                        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
                        child: Text(DateConverter.dateTimeStringToDateOnly(state.notifications![index].createdAt!)),
                      ) : const SizedBox(),

                      InkWell(
                        onTap: () {
                          showDialog(context: context, builder: (BuildContext context) {
                            return NotificationDialogWidget(notificationModel: state.notifications![index]);
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                          child: Row(children: [

                            ClipOval(child: CustomImage(
                              isNotification: true,
                              height: 40, width: 40, fit: BoxFit.cover,
                              image: '${Get.find<SplashController>().configModel!.baseUrls!.notificationImageUrl}'
                                  '/${state.notifications![index].data!.image}',
                            )),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(
                                state.notifications![index].data!.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                              ),
                              Text(
                                state.notifications![index].data!.description ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                              ),
                            ])),

                          ]),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 50),
                        child: Divider(color: Theme.of(context).disabledColor, thickness: 1),
                      ),

                    ]);
                  },
                )),
              ),
            ),
          ) : NoDataScreen(text: 'no_notification_found'.tr, showFooter: true) : const Center(child: CircularProgressIndicator());
        }) :  NotLoggedInScreen(callBack: (value){
          _loadData();
          setState(() {});
        }),
      ),
    );
  }
}
