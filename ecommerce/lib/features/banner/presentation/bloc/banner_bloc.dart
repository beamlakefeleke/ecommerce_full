import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/banner/domain/entities/banner.dart';
import 'package:ecommerce/features/banner/domain/repositories/banner_repository.dart';
import 'package:ecommerce/features/banner/domain/usecases/get_banners_usecase.dart';
import 'package:ecommerce/features/banner/domain/usecases/get_featured_banners_usecase.dart';
import 'package:ecommerce/features/banner/domain/usecases/get_parcel_other_banners_usecase.dart';
import 'package:ecommerce/features/banner/domain/usecases/get_promotional_banners_usecase.dart';
import 'package:ecommerce/features/banner/domain/usecases/get_taxi_banners_usecase.dart';
import 'package:ecommerce/features/banner/presentation/bloc/banner_event.dart';
import 'package:ecommerce/features/banner/presentation/bloc/banner_state.dart';

class BannerBloc extends Bloc<BannerEvent, BannerState> {
  final GetBannersUseCase getBanners;
  final GetFeaturedBannersUseCase getFeaturedBanners;
  final GetTaxiBannersUseCase getTaxiBanners;
  final GetParcelOtherBannersUseCase getParcelOtherBanners;
  final GetPromotionalBannersUseCase getPromotionalBanners;
  final BannerRepository repository;

  BannerBloc({
    required this.getBanners,
    required this.getFeaturedBanners,
    required this.getTaxiBanners,
    required this.getParcelOtherBanners,
    required this.getPromotionalBanners,
    required this.repository,
  }) : super(const BannerState()) {
    on<BannerListRequested>(_onBannerList);
    on<FeaturedBannerRequested>(_onFeaturedBanner);
    on<TaxiBannerListRequested>(_onTaxiBannerList);
    on<ParcelOtherBannerRequested>(_onParcelOtherBanner);
    on<PromotionalBannerRequested>(_onPromotionalBanner);
    on<BannerIndexChanged>(_onIndexChanged);
  }

  Future<void> _onBannerList(
    BannerListRequested event,
    Emitter<BannerState> emit,
  ) async {
    if (state.bannerImageList != null && !event.reload) return;
    final result = await getBanners(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (collection) {
        final images = <String?>[];
        final data = <dynamic>[];
        _flatten(collection, images, data, moduleFilter: null);
        emit(state.copyWith(bannerImageList: images, bannerDataList: data));
      },
    );
  }

  Future<void> _onFeaturedBanner(
    FeaturedBannerRequested event,
    Emitter<BannerState> emit,
  ) async {
    final result = await getFeaturedBanners(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (collection) {
        final images = <String?>[];
        final data = <dynamic>[];
        _flatten(
          collection,
          images,
          data,
          moduleFilter: repository.moduleIds(),
        );
        emit(
          state.copyWith(
            featuredBannerList: images,
            featuredBannerDataList: data,
          ),
        );
      },
    );
  }

  Future<void> _onTaxiBannerList(
    TaxiBannerListRequested event,
    Emitter<BannerState> emit,
  ) async {
    if (state.taxiBannerImageList != null && !event.reload) return;
    final result = await getTaxiBanners(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (collection) {
        final images = <String?>[];
        final data = <dynamic>[];
        _flatten(collection, images, data, moduleFilter: null);
        if (event.isDesktop && images.isNotEmpty && images.length % 2 != 0) {
          images.add(images[0]);
          data.add(data[0]);
        }
        emit(
          state.copyWith(taxiBannerImageList: images, taxiBannerDataList: data),
        );
      },
    );
  }

  Future<void> _onParcelOtherBanner(
    ParcelOtherBannerRequested event,
    Emitter<BannerState> emit,
  ) async {
    if (state.parcelOtherBanner != null && !event.reload) return;
    final result = await getParcelOtherBanners(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (banner) => emit(state.copyWith(parcelOtherBanner: banner)),
    );
  }

  Future<void> _onPromotionalBanner(
    PromotionalBannerRequested event,
    Emitter<BannerState> emit,
  ) async {
    if (state.promotionalBanner != null && !event.reload) return;
    final result = await getPromotionalBanners(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (banner) => emit(state.copyWith(promotionalBanner: banner)),
    );
  }

  void _onIndexChanged(BannerIndexChanged event, Emitter<BannerState> emit) {
    emit(state.copyWith(currentIndex: event.index));
  }

  /// Flattens campaigns + banner entries into parallel image/data lists,
  /// mirroring the legacy controller. When [moduleFilter] is provided (featured
  /// banners), item/store entries are only included if their module is reachable.
  void _flatten(
    BannerCollection collection,
    List<String?> images,
    List<dynamic> data, {
    List<int?>? moduleFilter,
  }) {
    for (final campaign in collection.campaigns) {
      images.add(campaign.image);
      data.add(campaign);
    }
    for (final banner in collection.banners) {
      images.add(banner.image);
      if (banner.item != null &&
          (moduleFilter == null ||
              moduleFilter.contains(banner.item!.moduleId))) {
        data.add(banner.item);
      } else if (banner.store != null &&
          (moduleFilter == null ||
              moduleFilter.contains(banner.store!.moduleId))) {
        data.add(banner.store);
      } else if (banner.type == 'default') {
        data.add(banner.link);
      } else {
        data.add(null);
      }
    }
  }
}
