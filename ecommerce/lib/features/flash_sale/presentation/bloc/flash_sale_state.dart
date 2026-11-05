part of 'flash_sale_bloc.dart';

class FlashSaleState extends Equatable {
  final Duration? duration;
  final FlashSaleModel? flashSaleModel;
  final ProductFlashSale? productFlashSale;
  final int pageIndex;

  const FlashSaleState({
    this.duration,
    this.flashSaleModel,
    this.productFlashSale,
    this.pageIndex = 0,
  });

  FlashSaleState copyWith({
    Duration? duration,
    FlashSaleModel? flashSaleModel,
    ProductFlashSale? productFlashSale,
    int? pageIndex,
    bool clearFlashSaleModel = false,
    bool clearProductFlashSale = false,
  }) {
    return FlashSaleState(
      duration: duration ?? this.duration,
      flashSaleModel: clearFlashSaleModel
          ? null
          : (flashSaleModel ?? this.flashSaleModel),
      productFlashSale: clearProductFlashSale
          ? null
          : (productFlashSale ?? this.productFlashSale),
      pageIndex: pageIndex ?? this.pageIndex,
    );
  }

  @override
  List<Object?> get props => [
    duration,
    flashSaleModel,
    productFlashSale,
    pageIndex,
  ];
}
