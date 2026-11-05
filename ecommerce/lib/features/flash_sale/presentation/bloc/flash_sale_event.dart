part of 'flash_sale_bloc.dart';

sealed class FlashSaleEvent extends Equatable {
  const FlashSaleEvent();

  @override
  List<Object?> get props => [];
}

class FlashSaleRequested extends FlashSaleEvent {
  final bool reload;

  const FlashSaleRequested({this.reload = false});

  @override
  List<Object?> get props => [reload];
}

class FlashSaleWithIdRequested extends FlashSaleEvent {
  final int offset;
  final bool reload;
  final int id;

  const FlashSaleWithIdRequested({
    required this.offset,
    required this.reload,
    required this.id,
  });

  @override
  List<Object?> get props => [offset, reload, id];
}

class FlashSalePageIndexChanged extends FlashSaleEvent {
  final int index;

  const FlashSalePageIndexChanged(this.index);

  @override
  List<Object?> get props => [index];
}

class FlashSaleEmptied extends FlashSaleEvent {
  final bool fromModule;

  const FlashSaleEmptied({this.fromModule = false});

  @override
  List<Object?> get props => [fromModule];
}

/// Internal: fired once per second to decrement the countdown.
class FlashSaleTicked extends FlashSaleEvent {
  const FlashSaleTicked();
}
