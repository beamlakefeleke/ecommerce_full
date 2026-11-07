import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/item/domain/models/basic_campaign_model.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/item/domain/usecases/campaign_usecases.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';

part 'campaign_event.dart';
part 'campaign_state.dart';

class CampaignBloc extends Bloc<CampaignEvent, CampaignState> {
  final GetBasicCampaignListUseCase getBasicCampaignListUseCase;
  final GetCampaignDetailsUseCase getCampaignDetailsUseCase;
  final GetItemCampaignListUseCase getItemCampaignListUseCase;

  CampaignBloc({
    required this.getBasicCampaignListUseCase,
    required this.getCampaignDetailsUseCase,
    required this.getItemCampaignListUseCase,
  }) : super(const CampaignState()) {
    on<BasicCampaignListRequested>(_onBasicListRequested);
    on<CampaignDetailsRequested>(_onDetailsRequested);
    on<ItemCampaignListRequested>(_onItemListRequested);
    on<CampaignCurrentIndexChanged>(_onCurrentIndexChanged);
    on<ItemCampaignCleared>(_onItemCampaignCleared);
  }

  Future<void> _onBasicListRequested(
    BasicCampaignListRequested event,
    Emitter<CampaignState> emit,
  ) async {
    if (state.basicCampaignList != null && !event.reload) return;
    final result = await getBasicCampaignListUseCase(const NoParams());
    result.fold(
      (failure) {},
      (list) => emit(state.copyWith(basicCampaignList: list)),
    );
  }

  Future<void> _onDetailsRequested(
    CampaignDetailsRequested event,
    Emitter<CampaignState> emit,
  ) async {
    emit(state.copyWith(clearBasicCampaign: true));
    final result = await getCampaignDetailsUseCase(
      CampaignIdParams(event.campaignID.toString()),
    );
    result.fold(
      (failure) {},
      (campaign) => emit(state.copyWith(basicCampaign: campaign)),
    );
  }

  Future<void> _onItemListRequested(
    ItemCampaignListRequested event,
    Emitter<CampaignState> emit,
  ) async {
    if (state.itemCampaignList != null && !event.reload) return;
    final result = await getItemCampaignListUseCase(const NoParams());
    result.fold((failure) {}, (list) {
      final List<Item> filtered = [];
      for (var c in list) {
        if (!Get.find<SplashController>()
                .getModuleConfig(c.moduleType)
                .newVariation! ||
            c.variations!.isEmpty ||
            c.foodVariations!.isNotEmpty) {
          filtered.add(c);
        }
      }
      emit(state.copyWith(itemCampaignList: filtered));
    });
  }

  void _onCurrentIndexChanged(
    CampaignCurrentIndexChanged event,
    Emitter<CampaignState> emit,
  ) {
    emit(state.copyWith(currentIndex: event.index));
  }

  void _onItemCampaignCleared(
    ItemCampaignCleared event,
    Emitter<CampaignState> emit,
  ) {
    emit(state.copyWith(clearItemCampaignList: true));
  }
}
