import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:ecommerce/common/models/transaction_model.dart';
import 'package:ecommerce/features/loyalty/domain/entities/loyalty_transaction.dart';
import 'package:ecommerce/features/loyalty/presentation/bloc/loyalty_bloc.dart';
import 'package:ecommerce/features/loyalty/presentation/bloc/loyalty_state.dart';
import 'package:ecommerce/common/widgets/history_item_widget.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/no_data_screen.dart';

class LoyaltyHistoryWidget extends StatelessWidget {
  const LoyaltyHistoryWidget({super.key});

  /// Adapt the pure domain entities to the shared wire model consumed by the
  /// common [HistoryItemWidget] (still used by the unmigrated wallet feature).
  List<Transaction> _toTransactionList(List<LoyaltyTransaction> items) {
    return items
        .map(
          (t) => Transaction(
            userId: t.userId,
            transactionId: t.transactionId,
            credit: t.credit,
            debit: t.debit,
            adminBonus: t.adminBonus,
            balance: t.balance,
            transactionType: t.transactionType,
            reference: t.reference,
            createdAt: t.createdAt,
            updatedAt: t.updatedAt,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoyaltyBloc, LoyaltyState>(
      builder: (context, state) {
        final transactions = state.transactions;
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: ResponsiveHelper.isDesktop(context)
                    ? Dimensions.paddingSizeExtraSmall
                    : Dimensions.paddingSizeExtraLarge,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'point_history'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  ),

                  const SizedBox(),
                ],
              ),
            ),
            transactions != null
                ? transactions.isNotEmpty
                      ? GridView.builder(
                          key: UniqueKey(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisSpacing: 50,
                                mainAxisSpacing:
                                    ResponsiveHelper.isDesktop(context)
                                    ? Dimensions.paddingSizeSmall
                                    : 0.01,
                                childAspectRatio:
                                    ResponsiveHelper.isDesktop(context)
                                    ? 7
                                    : 4.45,
                                crossAxisCount:
                                    ResponsiveHelper.isMobile(context) ? 1 : 1,
                              ),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: transactions.length,
                          padding: EdgeInsets.only(
                            top: ResponsiveHelper.isDesktop(context) ? 28 : 25,
                          ),
                          itemBuilder: (context, index) {
                            return HistoryItemWidget(
                              index: index,
                              fromWallet: false,
                              data: _toTransactionList(transactions),
                            );
                          },
                        )
                      : NoDataScreen(text: 'no_data_found'.tr)
                : const WalletShimmer(),

            state.isLoadingMore
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : const SizedBox(),
          ],
        );
      },
    );
  }
}

class WalletShimmer extends StatelessWidget {
  const WalletShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: UniqueKey(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 50,
        mainAxisSpacing: ResponsiveHelper.isDesktop(context)
            ? Dimensions.paddingSizeLarge
            : 0.01,
        childAspectRatio: ResponsiveHelper.isDesktop(context) ? 5 : 3.8,
        crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 1,
      ),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 10,
      padding: EdgeInsets.only(
        top: ResponsiveHelper.isDesktop(context) ? 28 : 25,
      ),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeSmall,
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 10,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 10,
                          width: 70,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 10,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 10,
                          width: 70,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: Dimensions.paddingSizeLarge,
                  ),
                  child: Divider(color: Theme.of(context).disabledColor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
