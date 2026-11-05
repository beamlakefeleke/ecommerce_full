import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/coupon/data/models/coupon_model.dart';
import 'package:ecommerce/features/coupon/domain/usecases/apply_coupon_usecase.dart';
import 'package:ecommerce/features/coupon/domain/usecases/apply_taxi_coupon_usecase.dart';
import 'package:ecommerce/features/coupon/domain/usecases/get_coupon_list_usecase.dart';
import 'package:ecommerce/features/coupon/domain/usecases/get_taxi_coupon_list_usecase.dart';
import 'package:ecommerce/helper/price_converter.dart';

part 'coupon_event.dart';
part 'coupon_state.dart';

class CouponBloc extends Bloc<CouponEvent, CouponState> {
  final GetCouponListUseCase getCouponListUseCase;
  final GetTaxiCouponListUseCase getTaxiCouponListUseCase;
  final ApplyCouponUseCase applyCouponUseCase;
  final ApplyTaxiCouponUseCase applyTaxiCouponUseCase;

  CouponBloc({
    required this.getCouponListUseCase,
    required this.getTaxiCouponListUseCase,
    required this.applyCouponUseCase,
    required this.applyTaxiCouponUseCase,
  }) : super(const CouponState()) {
    on<CouponListRequested>(_onCouponListRequested);
    on<TaxiCouponListRequested>(_onTaxiCouponListRequested);
    on<CouponCurrentIndexChanged>(_onCurrentIndexChanged);
    on<CouponApplied>(_onCouponApplied);
    on<TaxiCouponApplied>(_onTaxiCouponApplied);
    on<CouponDataRemoved>(_onCouponDataRemoved);
  }

  Future<void> _onCouponListRequested(
    CouponListRequested event,
    Emitter<CouponState> emit,
  ) async {
    final result = await getCouponListUseCase(const NoParams());
    result.fold(
      (failure) {},
      (coupons) => emit(state.copyWith(couponList: coupons)),
    );
  }

  Future<void> _onTaxiCouponListRequested(
    TaxiCouponListRequested event,
    Emitter<CouponState> emit,
  ) async {
    final result = await getTaxiCouponListUseCase(const NoParams());
    result.fold(
      (failure) {},
      (coupons) => emit(state.copyWith(taxiCouponList: coupons)),
    );
  }

  void _onCurrentIndexChanged(
    CouponCurrentIndexChanged event,
    Emitter<CouponState> emit,
  ) {
    emit(state.copyWith(currentIndex: event.index));
  }

  Future<void> _onCouponApplied(
    CouponApplied event,
    Emitter<CouponState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, discount: 0, clearMessage: true));
    final result = await applyCouponUseCase(
      ApplyCouponParams(couponCode: event.couponCode, storeId: event.storeId),
    );
    result.fold(
      (failure) {
        emit(
          state.copyWith(isLoading: false, discount: 0.0, clearMessage: true),
        );
      },
      (coupon) {
        if (coupon.couponType == 'free_delivery') {
          _processFreeDeliveryCoupon(
            emit,
            coupon,
            event.deliveryCharge!,
            event.order,
          );
        } else {
          _processCoupon(emit, coupon, event.order);
        }
      },
    );
  }

  void _processFreeDeliveryCoupon(
    Emitter<CouponState> emit,
    CouponModel coupon,
    double deliveryCharge,
    double order,
  ) {
    if (deliveryCharge > 0) {
      if (coupon.minPurchase! <= order) {
        emit(
          state.copyWith(
            coupon: coupon,
            discount: 0,
            freeDelivery: true,
            isLoading: false,
            clearMessage: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            clearCoupon: true,
            discount: 0,
            isLoading: false,
            message:
                '${'the_minimum_item_purchase_amount_for_this_coupon_is'.tr} '
                '${PriceConverter.convertPrice(coupon.minPurchase)} '
                '${'but_you_have'.tr} ${PriceConverter.convertPrice(order)}',
            messageIsError: true,
          ),
        );
      }
    } else {
      emit(
        state.copyWith(
          coupon: coupon,
          isLoading: false,
          message: 'invalid_code_or'.tr,
          messageIsError: true,
        ),
      );
    }
  }

  void _processCoupon(
    Emitter<CouponState> emit,
    CouponModel coupon,
    double order,
  ) {
    if (coupon.minPurchase != null && coupon.minPurchase! <= order) {
      double discount;
      if (coupon.discountType == 'percent') {
        if (coupon.maxDiscount != null && coupon.maxDiscount! > 0) {
          discount = (coupon.discount! * order / 100) < coupon.maxDiscount!
              ? (coupon.discount! * order / 100)
              : coupon.maxDiscount!;
        } else {
          discount = coupon.discount! * order / 100;
        }
      } else {
        discount = coupon.discount!;
      }
      emit(
        state.copyWith(
          coupon: coupon,
          discount: discount,
          isLoading: false,
          clearMessage: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          coupon: coupon,
          discount: 0.0,
          isLoading: false,
          message:
              '${'the_minimum_item_purchase_amount_for_this_coupon_is'.tr} '
              '${PriceConverter.convertPrice(coupon.minPurchase)} '
              '${'but_you_have'.tr} ${PriceConverter.convertPrice(order)}',
          messageIsError: true,
        ),
      );
    }
  }

  Future<void> _onTaxiCouponApplied(
    TaxiCouponApplied event,
    Emitter<CouponState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, discount: 0, clearMessage: true));
    final result = await applyTaxiCouponUseCase(
      ApplyTaxiCouponParams(
        couponCode: event.couponCode,
        providerId: event.providerId,
      ),
    );
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, discount: 0.0)),
      (coupon) {
        double discount = 0.0;
        if (coupon.minPurchase != null &&
            coupon.minPurchase! < event.orderAmount) {
          if (coupon.discountType == 'percent') {
            if (coupon.maxDiscount != null && coupon.maxDiscount! > 0) {
              discount =
                  (coupon.discount! * event.orderAmount / 100) <
                      coupon.maxDiscount!
                  ? (coupon.discount! * event.orderAmount / 100)
                  : coupon.maxDiscount!;
            } else {
              discount = coupon.discount! * event.orderAmount / 100;
            }
          } else {
            discount = coupon.discount!;
          }
        }
        emit(
          state.copyWith(coupon: coupon, discount: discount, isLoading: false),
        );
      },
    );
  }

  void _onCouponDataRemoved(
    CouponDataRemoved event,
    Emitter<CouponState> emit,
  ) {
    emit(
      state.copyWith(
        clearCoupon: true,
        isLoading: false,
        discount: 0.0,
        freeDelivery: false,
        clearMessage: true,
      ),
    );
  }
}
