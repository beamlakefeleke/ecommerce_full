import 'package:flutter/foundation.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/html/presentation/bloc/html_bloc.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/html_type.dart';
import 'package:ecommerce/common/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';
import 'package:ecommerce/common/widgets/web_page_title_widget.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher_string.dart';

class HtmlViewerScreen extends StatelessWidget {
  final HtmlType htmlType;
  const HtmlViewerScreen({super.key, required this.htmlType});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HtmlBloc>(
      create: (_) => getIt<HtmlBloc>()..add(HtmlTextRequested(htmlType)),
      child: _HtmlViewerView(htmlType: htmlType),
    );
  }
}

class _HtmlViewerView extends StatelessWidget {
  final HtmlType htmlType;
  const _HtmlViewerView({required this.htmlType});

  String _title() {
    return htmlType == HtmlType.termsAndCondition
        ? 'terms_conditions'.tr
        : htmlType == HtmlType.aboutUs
        ? 'about_us'.tr
        : htmlType == HtmlType.privacyPolicy
        ? 'privacy_policy'.tr
        : htmlType == HtmlType.shippingPolicy
        ? 'shipping_policy'.tr
        : htmlType == HtmlType.refund
        ? 'refund_policy'.tr
        : htmlType == HtmlType.cancellation
        ? 'cancellation_policy'.tr
        : 'no_data_found'.tr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: _title()),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: BlocBuilder<HtmlBloc, HtmlState>(
        builder: (context, htmlController) {
          return Center(
            child: htmlController.htmlText != null
                ? SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        WebScreenTitleWidget(title: _title()),

                        FooterView(
                          child: Ink(
                            width: Dimensions.webMaxWidth,
                            color: Theme.of(context).cardColor,
                            padding: const EdgeInsets.all(
                              Dimensions.paddingSizeSmall,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                (htmlController.htmlText!.contains('<ol>') ||
                                        htmlController.htmlText!.contains(
                                          '<ul>',
                                        ))
                                    ? HtmlWidget(
                                        htmlController.htmlText ?? '',
                                        key: Key(htmlType.toString()),
                                        onTapUrl: (String url) {
                                          return launchUrlString(
                                            url,
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        },
                                      )
                                    : SelectableHtml(
                                        data: htmlController.htmlText,
                                        shrinkWrap: true,
                                        onLinkTap:
                                            (
                                              String? url,
                                              RenderContext context,
                                              Map<String, String> attributes,
                                              element,
                                            ) {
                                              if (url!.startsWith('www.')) {
                                                url = 'https://$url';
                                              }
                                              if (kDebugMode) {
                                                print('Redirect to url: $url');
                                              }
                                              html.window.open(url, "_blank");
                                            },
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
