import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/item/domain/models/basic_campaign_model.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';

/// A banner entry (promo image that may link to a store, item, campaign or URL).
///
/// `store`/`item` reference the still-GetX item/store feature models; they will
/// become entities when those features are migrated.
class BannerEntry extends Equatable {
  final int? id;
  final String? title;
  final String? type;
  final String? image;
  final String? link;
  final Store? store;
  final Item? item;

  const BannerEntry({
    this.id,
    this.title,
    this.type,
    this.image,
    this.link,
    this.store,
    this.item,
  });

  @override
  List<Object?> get props => [id, title, type, image, link, store, item];
}

/// The main banner payload: promotional campaigns + banner entries.
class BannerCollection extends Equatable {
  final List<BasicCampaignModel> campaigns;
  final List<BannerEntry> banners;

  const BannerCollection({this.campaigns = const [], this.banners = const []});

  @override
  List<Object?> get props => [campaigns, banners];
}
