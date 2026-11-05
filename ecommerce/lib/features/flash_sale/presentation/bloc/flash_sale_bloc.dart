import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/flash_sale/data/models/flash_sale_model.dart';
import 'package:ecommerce/features/flash_sale/data/models/product_flash_sale.dart';
import 'package:ecommerce/features/flash_sale/domain/usecases/get_flash_sale_usecase.dart';
import 'package:ecommerce/features/flash_sale/domain/usecases/get_flash_sale_with_id_usecase.dart';

part 'flash_sale_event.dart';
part 'flash_sale_state.dart';

class FlashSaleBloc extends Bloc<FlashSaleEvent, FlashSaleState> {
  final GetFlashSaleUseCase getFlashSaleUseCase;
  final GetFlashSaleWithIdUseCase getFlashSaleWithIdUseCase;

  StreamSubscription<int>? _tickerSub;

  FlashSaleBloc({
    required this.getFlashSaleUseCase,
    required this.getFlashSaleWithIdUseCase,
  }) : super(const FlashSaleState()) {
    on<FlashSaleRequested>(_onRequested);
    on<FlashSaleWithIdRequested>(_onWithIdRequested);
    on<FlashSalePageIndexChanged>(_onPageIndexChanged);
    on<FlashSaleEmptied>(_onEmptied);
    on<FlashSaleTicked>(_onTicked);
  }

  void _startTicker() {
    _tickerSub?.cancel();
    _tickerSub = Stream<int>.periodic(
      const Duration(seconds: 1),
      (x) => x,
    ).listen((_) => add(const FlashSaleTicked()));
  }

  void _onTicked(FlashSaleTicked event, Emitter<FlashSaleState> emit) {
    if (state.duration != null) {
      emit(
        state.copyWith(duration: state.duration! - const Duration(seconds: 1)),
      );
    }
  }

  Future<void> _onRequested(
    FlashSaleRequested event,
    Emitter<FlashSaleState> emit,
  ) async {
    if (state.flashSaleModel != null && !event.reload) return;

    emit(state.copyWith(clearFlashSaleModel: true));
    final result = await getFlashSaleUseCase(const NoParams());
    result.fold((failure) {}, (flashSaleModel) {
      emit(state.copyWith(flashSaleModel: flashSaleModel));
      if (flashSaleModel.endDate != null) {
        final DateTime endTime = DateFormat(
          'yyyy-MM-ddTHH:mm:ss.SSS',
        ).parse(flashSaleModel.endDate!, true).toLocal();
        emit(state.copyWith(duration: endTime.difference(DateTime.now())));
        _startTicker();
      }
    });
  }

  Future<void> _onWithIdRequested(
    FlashSaleWithIdRequested event,
    Emitter<FlashSaleState> emit,
  ) async {
    if (event.reload) {
      emit(state.copyWith(clearProductFlashSale: true));
    }
    final result = await getFlashSaleWithIdUseCase(
      FlashSaleWithIdParams(id: event.id, offset: event.offset),
    );
    result.fold((failure) {}, (productFlashSale) {
      ProductFlashSale merged;
      if (event.offset == 1 || state.productFlashSale == null) {
        merged = productFlashSale;
      } else {
        // Append subsequent pages onto the existing list.
        final existing = state.productFlashSale!;
        merged = ProductFlashSale(
          totalSize: productFlashSale.totalSize,
          limit: existing.limit,
          offset: productFlashSale.offset,
          flashSale: productFlashSale.flashSale,
          products: [
            ...(existing.products ?? []),
            ...(productFlashSale.products ?? []),
          ],
        );
      }
      emit(state.copyWith(productFlashSale: merged));

      if (merged.flashSale?.endDate != null) {
        final DateTime endTime = DateFormat(
          'yyyy-MM-ddTHH:mm:ss.SSS',
        ).parse(merged.flashSale!.endDate!, true).toLocal();
        emit(state.copyWith(duration: endTime.difference(DateTime.now())));
        _startTicker();
      }
    });
  }

  void _onPageIndexChanged(
    FlashSalePageIndexChanged event,
    Emitter<FlashSaleState> emit,
  ) {
    emit(state.copyWith(pageIndex: event.index));
  }

  void _onEmptied(FlashSaleEmptied event, Emitter<FlashSaleState> emit) {
    if (event.fromModule) {
      emit(state.copyWith(clearFlashSaleModel: true));
    }
  }

  @override
  Future<void> close() {
    _tickerSub?.cancel();
    return super.close();
  }
}
